import csv
import json
import os

from confluent_kafka import Producer


def check_delivery(error, message):
    if error:
        raise RuntimeError(error)


producer = Producer({
    "bootstrap.servers": os.environ["KAFKA_BOOTSTRAP_SERVERS"]
})
topic = os.environ["KAFKA_TOPIC"]
count = 0

with open(os.environ["CSV_PATH"], newline="", encoding="utf-8") as file:
    for row in csv.DictReader(file):
        for column in ("amount", "lat", "lon", "merchant_lat", "merchant_lon"):
            row[column] = float(row[column])
        for column in ("population_city", "target"):
            row[column] = int(row[column])

        producer.produce(
            topic,
            value=json.dumps(row, ensure_ascii=False).encode("utf-8"),
            on_delivery=check_delivery,
        )
        producer.poll(0)
        count += 1

producer.flush()
print(f"отправлено {count} сообщений")