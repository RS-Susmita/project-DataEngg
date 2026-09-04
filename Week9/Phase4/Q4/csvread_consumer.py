from kafka import KafkaConsumer
consumer = KafkaConsumer(
    'FinalCapstone',
    bootstrap_servers='localhost:9092',
    auto_offset_reset='earliest'
)
for message in consumer:
    with open('received_nba.csv', 'wb') as file:
        file.write(message.value)
    print('NBA CSV received from FinalCapstone')
    break