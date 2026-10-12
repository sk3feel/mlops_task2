CREATE TABLE IF NOT EXISTS transactions_v2_summary (
    us_state String,
    cat_id String,
    max_amount Float64
)
ENGINE = MergeTree
ORDER BY us_state;

CREATE TABLE IF NOT EXISTS transactions_v2_kafka (
    transaction_time String,
    merch String,
    cat_id String,
    amount Float64,
    name_1 String,
    name_2 String,
    gender String,
    street String,
    one_city String,
    us_state String,
    post_code String,
    lat Float64,
    lon Float64,
    population_city UInt32,
    jobs String,
    merchant_lat Float64,
    merchant_lon Float64,
    target UInt8
)
ENGINE = Kafka
SETTINGS
    kafka_broker_list = 'kafka:9092',
    kafka_topic_list = 'transactions_v2',
    kafka_group_name = 'clickhouse_hw2_v2',
    kafka_format = 'JSONEachRow';

CREATE MATERIALIZED VIEW IF NOT EXISTS transactions_v2_summary_mv
TO transactions_v2_summary AS
SELECT
    us_state,
    argMax(cat_id, amount) AS cat_id,
    max(amount) AS max_amount
FROM transactions_v2_kafka
GROUP BY us_state;
