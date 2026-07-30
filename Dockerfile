FROM python:3.12-slim

# default-mysql-client provides the `mysql` CLI the pipeline shells out to
# for every SQL file (see src/pipeline/mysql_runner.py).
RUN apt-get update \
    && apt-get install -y --no-install-recommends default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "scripts/run_pipeline.py", "--env", "docker"]
