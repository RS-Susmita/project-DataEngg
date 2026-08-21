from kafka import KafkaProducer
import os
producer = KafkaProducer(bootstrap_servers='localhost:9092')
for filename in os.listdir('files'):
    path = os.path.join('files', filename)
    if os.path.isfile(path):
        with open(path, 'rb') as f:
            data = f.read()
        producer.send(
            'multiplefiles',
            key=filename.encode(),
            value=data
        )
        print('Sent:', filename)
producer.flush()