import csv
import json
from kafka import KafkaProducer
from kafka.errors import KafkaError


TOPIC = "FinalCapstone"
CSV_FILE = "nba.csv"

JSONL_FILE = "nba_messages.jsonl"
JSON_FILE = "nba_messages.json"


def create_producer():
    return KafkaProducer(
        bootstrap_servers="localhost:9092",
        acks="all",
        value_serializer=lambda value: json.dumps(value).encode("utf-8")
    )


def send_csv_to_kafka():

    producer = None
    all_rows = []

    try:
        producer = create_producer()

        # Read CSV
        with open(CSV_FILE, "r", encoding="utf-8") as csv_file:

            reader = csv.DictReader(csv_file)

            # Open JSONL file
            with open(JSONL_FILE, "w", encoding="utf-8") as jsonl_file:

                for row_number, row in enumerate(reader, start=1):

                    json_data = dict(row)

                    # Keep row for the .json file
                    all_rows.append(json_data)

                    # Save one JSON object per line
                    jsonl_file.write(
                        json.dumps(json_data) + "\n"
                    )

                    try:
                        # Send each row to Kafka
                        future = producer.send(
                            TOPIC,
                            value=json_data
                        )

                        # Wait for Kafka acknowledgement
                        record_metadata = future.get(timeout=10)

                        print(
                            f"Row {row_number} sent successfully "
                            f"(partition={record_metadata.partition}, "
                            f"offset={record_metadata.offset})"
                        )

                    except KafkaError as e:
                        print(
                            f"Error sending row {row_number}: {e}"
                        )

        # Save all rows as one JSON array
        with open(JSON_FILE, "w", encoding="utf-8") as json_file:

            json.dump(
                all_rows,
                json_file,
                indent=4
            )

        # Make sure all Kafka messages are delivered
        producer.flush()

        print("\nCSV processing completed.")
        print(f"JSONL file saved: {JSONL_FILE}")
        print(f"JSON file saved:  {JSON_FILE}")

    except FileNotFoundError:
        print(f"Error: File '{CSV_FILE}' not found.")

    except Exception as e:
        print(f"Unexpected error: {e}")

    finally:
        if producer is not None:
            producer.close()


if __name__ == "__main__":
    send_csv_to_kafka()