"""Integration tests against a real MySQL database.

Unlike test_pipeline.py (orchestration logic only, no DB), these exercise
the actual stored procedures/triggers/views defined in sql/, built fresh
into the disposable `test` environment (config/test.yaml ->
inventory_management_test). mysql_runner.run_sql_file() rewrites each
file's hardcoded `USE inventory_management;` to the configured db_name
before sourcing it, so this never touches the dev database.

If MySQL isn't reachable or the test database can't be (re)built, the
whole module is skipped with an explanatory reason, so `python -m pytest`
still passes with no DB configured -- same guarantee test_pipeline.py
already makes.
"""
import uuid

import pytest

mysql_connector = pytest.importorskip("mysql.connector")

from pipeline.config import load_config
from pipeline.pipeline import run_pipeline


@pytest.fixture(scope="module")
def db_config():
    return load_config("test")


@pytest.fixture(scope="module", autouse=True)
def built_test_database(db_config):
    try:
        run_pipeline(db_config)
    except Exception as exc:  # noqa: BLE001 - any failure means "skip", not "fail"
        pytest.skip(
            "Test database unavailable -- could not build inventory_management_test "
            f"(env=test). Run `python scripts/run_pipeline.py --env test` manually and "
            f"ensure MySQL is reachable. Underlying error: {exc}"
        )


@pytest.fixture()
def conn(db_config):
    connection = mysql_connector.connect(
        host=db_config.db_host,
        port=db_config.db_port,
        user=db_config.db_user,
        password=db_config.db_password,
        database=db_config.db_name,
        autocommit=False,
        # The C-extension backend crashes the interpreter with an access
        # violation on some Windows/Python 3.13 builds -- the pure-Python
        # implementation avoids that native code path entirely.
        use_pure=True,
    )
    yield connection
    connection.rollback()
    connection.close()


def callproc(cursor, name, args):
    cursor.callproc(name, args)
    for result in cursor.stored_results():
        result.fetchall()


def insert_customer(cursor):
    cursor.execute(
        "INSERT INTO customers (first_name, last_name, email) VALUES (%s, %s, %s)",
        ("Test", "Customer", f"test.{uuid.uuid4().hex}@example.com"),
    )
    return cursor.lastrowid


def insert_product(cursor, price=100.00, stock_quantity=100, reorder_level=10):
    cursor.execute(
        "INSERT INTO products (product_name, category, price, stock_quantity, reorder_level) "
        "VALUES (%s, %s, %s, %s, %s)",
        ("Test Product", "Test", price, stock_quantity, reorder_level),
    )
    return cursor.lastrowid


def create_order(cursor, customer_id):
    callproc(cursor, "create_order", (customer_id,))
    cursor.execute("SELECT LAST_INSERT_ID()")
    return cursor.fetchone()[0]


# --- Validation / edge cases -------------------------------------------------


def test_add_order_item_rejects_nonexistent_product(conn):
    cursor = conn.cursor()
    customer_id = insert_customer(cursor)
    order_id = create_order(cursor, customer_id)
    with pytest.raises(mysql_connector.Error, match="Product does not exist"):
        callproc(cursor, "add_order_item", (order_id, 999999, 1))


def test_add_order_item_rejects_insufficient_stock(conn):
    cursor = conn.cursor()
    customer_id = insert_customer(cursor)
    product_id = insert_product(cursor, stock_quantity=5)
    order_id = create_order(cursor, customer_id)
    with pytest.raises(mysql_connector.Error, match="Insufficient stock available"):
        callproc(cursor, "add_order_item", (order_id, product_id, 6))


def test_add_order_item_rejects_non_positive_quantity(conn):
    cursor = conn.cursor()
    customer_id = insert_customer(cursor)
    product_id = insert_product(cursor)
    order_id = create_order(cursor, customer_id)
    with pytest.raises(mysql_connector.Error, match="Quantity must be greater than zero"):
        callproc(cursor, "add_order_item", (order_id, product_id, -2))


def test_create_order_rejects_nonexistent_customer(conn):
    cursor = conn.cursor()
    with pytest.raises(mysql_connector.Error, match="Customer does not exist"):
        callproc(cursor, "create_order", (999999,))


def test_place_bulk_order_rejects_empty_items(conn):
    cursor = conn.cursor()
    customer_id = insert_customer(cursor)
    with pytest.raises(mysql_connector.Error, match="Items list must not be empty"):
        callproc(cursor, "place_bulk_order", (customer_id, "[]"))


def test_replenish_stock_rejects_negative_quantity(conn):
    cursor = conn.cursor()
    product_id = insert_product(cursor)
    with pytest.raises(
        mysql_connector.Error, match="Replenishment quantity must be greater than zero"
    ):
        callproc(cursor, "replenish_stock", (product_id, -10))


# --- Business logic -----------------------------------------------------


@pytest.mark.parametrize(
    "quantity,expected_discount",
    [(1, 0.00), (5, 5.00), (10, 10.00)],
)
def test_add_order_item_bulk_discount_tiers(conn, quantity, expected_discount):
    cursor = conn.cursor()
    customer_id = insert_customer(cursor)
    product_id = insert_product(cursor, stock_quantity=100)
    order_id = create_order(cursor, customer_id)
    callproc(cursor, "add_order_item", (order_id, product_id, quantity))

    cursor.execute(
        "SELECT discount FROM order_details WHERE order_id = %s AND product_id = %s",
        (order_id, product_id),
    )
    assert float(cursor.fetchone()[0]) == expected_discount


def test_trg_reduce_stock_decrements_product_stock(conn):
    cursor = conn.cursor()
    customer_id = insert_customer(cursor)
    product_id = insert_product(cursor, stock_quantity=100)
    order_id = create_order(cursor, customer_id)
    callproc(cursor, "add_order_item", (order_id, product_id, 10))

    cursor.execute("SELECT stock_quantity FROM products WHERE product_id = %s", (product_id,))
    assert cursor.fetchone()[0] == 90


@pytest.mark.parametrize(
    "quantity,expected_tier",
    [(4, "Bronze"), (6, "Silver"), (25, "Gold")],
)
def test_trg_update_customer_tier_upgrades_with_spend(conn, quantity, expected_tier):
    cursor = conn.cursor()
    customer_id = insert_customer(cursor)
    product_id = insert_product(cursor, price=100.00, stock_quantity=1000)
    order_id = create_order(cursor, customer_id)
    callproc(cursor, "add_order_item", (order_id, product_id, quantity))

    cursor.execute("SELECT customer_tier FROM customers WHERE customer_id = %s", (customer_id,))
    assert cursor.fetchone()[0] == expected_tier


def test_trg_update_customer_tier_ignores_cancelled_orders(conn):
    cursor = conn.cursor()
    customer_id = insert_customer(cursor)
    product_id = insert_product(cursor, price=100.00, stock_quantity=1000)
    order_id = create_order(cursor, customer_id)
    callproc(cursor, "add_order_item", (order_id, product_id, 25))  # would be Gold if counted
    cursor.execute("UPDATE orders SET status = 'CANCELLED' WHERE order_id = %s", (order_id,))

    cursor.execute("SELECT customer_tier FROM customers WHERE customer_id = %s", (customer_id,))
    assert cursor.fetchone()[0] == "Bronze"


def test_vw_low_stock_reflects_reorder_level(conn):
    cursor = conn.cursor()
    low_stock_id = insert_product(cursor, stock_quantity=5, reorder_level=10)
    healthy_id = insert_product(cursor, stock_quantity=50, reorder_level=10)

    cursor.execute("SELECT product_id FROM vw_low_stock WHERE product_id IN (%s, %s)", (low_stock_id, healthy_id))
    ids_in_view = {row[0] for row in cursor.fetchall()}

    assert low_stock_id in ids_in_view
    assert healthy_id not in ids_in_view
