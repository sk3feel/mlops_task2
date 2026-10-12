set -e

dc() { docker compose -f solution/docker-compose.yml "$@"; }

dc up -d --wait kafka clickhouse
until dc exec -T clickhouse clickhouse-client \
    --query 'SELECT 1' >/dev/null 2>&1; do
    sleep 1
done

dc exec -T kafka /opt/kafka/bin/kafka-topics.sh \
    --bootstrap-server localhost:9092 --create --if-not-exists \
    --topic transactions_v2 --partitions 1 --replication-factor 1
dc exec -T clickhouse clickhouse-client --multiquery < solution/schema_v2.sql
dc run --rm producer

until [[ "$(
    dc exec -T kafka /opt/kafka/bin/kafka-consumer-groups.sh \
        --bootstrap-server localhost:9092 --describe \
        --group clickhouse_hw2_v2 2>/dev/null |
        awk '$2 == "transactions_v2" {print $6}'
)" == 0 ]]; do
    sleep 1
done
dc exec -T clickhouse clickhouse-client --format CSVWithNames \
    < solution/query_v2.sql > solution/result.csv
