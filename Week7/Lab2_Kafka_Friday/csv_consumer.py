from kafka import KafkaConsumer
consumer = KafkaConsumer(
    'csv_files',
    bootstrap_servers='localhost:9092',
    auto_offset_reset='earliest'
)
for message in consumer:
    with open('received_nba.csv', 'wb') as file:
        file.write(message.value)
    print('CSV received')
    break