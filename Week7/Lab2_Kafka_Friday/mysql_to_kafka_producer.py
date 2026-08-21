import mysql.connector
from kafka import KafkaProducer
import json

conn = mysql.connector.connect(
    host='localhost',
    user='local_user',
    password='MySecurePassword123!',
    database='my_local_db'
)
cursor = conn.cursor(dictionary=True)

cursor.execute("SELECT * FROM your_table")
rows = cursor.fetchall()

producer = KafkaProducer(
    bootstrap_servers='localhost:9092',
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

for row in rows:
    producer.send('mysql-topic', value=row)

producer.flush()
print("Data sent to Kafka successfully.")

cursor.close()
conn.close()