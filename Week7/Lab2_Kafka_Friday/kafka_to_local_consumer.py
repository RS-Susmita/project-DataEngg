import json
from kafka import KafkaConsumer

consumer = KafkaConsumer(
    'mysql-topic',
    bootstrap_servers='localhost:9092',
    auto_offset_reset='earliest',
    group_id='mysql-to-local-group',
    value_deserializer=lambda m: json.loads(m.decode('utf-8'))
)

local_path = 'local_mysql_data.json'
print("Consumer started. Waiting for messages...")

# Open file in append mode ('a') so it saves data continuously as it streams
with open(local_path, 'a', encoding='utf-8') as writer:
    for message in consumer:
        json_record = json.dumps(message.value)
        print(f"Received and saving: {json_record}")
        writer.write(json_record + '\n')
        writer.flush()  # Forces data onto the disk immediately
