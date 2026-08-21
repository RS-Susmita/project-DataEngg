from kafka import KafkaConsumer
consumer = KafkaConsumer(
    'multiplefiles',
    bootstrap_servers='localhost:9092',
    auto_offset_reset='earliest'
)
for message in consumer:
    filename = message.key.decode()
    with open('received_' + filename, 'wb') as f:
        f.write(message.value)
    print('Received:', filename)
    

