# Entity-relationship diagram

Derived from `sql/schema/*.sql` — see `docs/data_dictionary.md` for full
column-level notes. This is documentation only; the schema files remain
the source of truth.

```mermaid
erDiagram
    customers ||--o{ orders : places
    orders ||--o{ order_details : contains
    products ||--o{ order_details : "line item for"
    products ||--o{ inventory_logs : "stock change for"

    customers {
        int customer_id PK
        varchar first_name
        varchar last_name
        varchar email
        varchar phone
        varchar customer_tier "Bronze/Silver/Gold, written only by trg_update_customer_tier"
        timestamp created_at
    }

    products {
        int product_id PK
        varchar product_name
        varchar category
        decimal price "CHECK >= 0"
        int stock_quantity "CHECK >= 0, decremented by trg_reduce_stock"
        int reorder_level "default 10"
        timestamp created_at
        timestamp updated_at
    }

    orders {
        int order_id PK
        int customer_id FK
        timestamp order_date
        decimal total_amount "recalculated by trg_update_order_total"
        varchar status "default PENDING"
    }

    order_details {
        int order_detail_id PK
        int order_id FK
        int product_id FK
        int quantity "CHECK > 0"
        decimal unit_price "snapshotted from products.price at insert time"
        decimal discount "bulk-quantity discount %, set by add_order_item"
    }

    inventory_logs {
        int log_id PK
        int product_id FK
        int previous_quantity
        int new_quantity
        int quantity_change
        varchar reason "ORDER_PLACED / REPLENISHMENT / STOCK UPDATE"
        timestamp created_at
    }
```

## Notes

- All foreign keys are `RESTRICT` on delete (no `CASCADE`) — a customer,
  order, or product with dependent rows can never be silently deleted
  along with its history. See the comments in `sql/schema/orders.sql`,
  `order_details.sql`, and `inventory_logs.sql`.
- `customers.customer_tier` is not directly writable by application
  code — it's recomputed by `trg_update_customer_tier` from lifetime
  spend every time an order's `total_amount`/`status` changes.
- `order_details.unit_price` is a snapshot taken at insert time, not a
  live join to `products.price` — so historical orders keep their
  original price even if `products.price` changes later.
