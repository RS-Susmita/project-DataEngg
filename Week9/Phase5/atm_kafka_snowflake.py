from kafka import KafkaConsumer
import snowflake.connector
import json

#---------------------------------------
# 1.  Kafka consumer
#---------------------------------------
#consumer = KafkaConsumer(
 #   'EuropeATMTransaction',
  #  bootstrap_servers='127.0.0.1:9092',
   # auto_offset_reset='earliest',
    #value_deserializer=lambda x: json.loads(x.decode('utf-8'))
#)
consumer = KafkaConsumer(
    'EuropeATMTransaction',
    bootstrap_servers='127.0.0.1:9092',
    auto_offset_reset='earliest',
    value_deserializer=lambda x: x.decode('utf-8')
)

# ---------------------------------------------------
# 2. Snowflake Connection
# ---------------------------------------------------

conn = snowflake.connector.connect(
    user='SUSMITA',
    password='*********',
    account='**********',
    warehouse='COMPUTE_WH',
    database='ATM_STREAMING_DB',
    schema='ATM_DATA',
    role='ACCOUNTADMIN'
)

cursor = conn.cursor()

print("Listening to ATM Kafka TOPIC...")

# ---------------------------------------
# 3. Read Kafka and insert into Snowflake
# ---------------------------------------

for message in consumer:

    try:

        data = json.loads (message.value)

        sql = """
        INSERT INTO ATM_TRANSACTIONS
        (
            TRANSACTION_ID,
            ATM_ID,
            COUNTRY,
            CITY,
            AMOUNT,
            TRANSACTION_TYPE
        )
        VALUES (%s, %s, %s, %s, %s, %s)
        """

        cursor.execute(
            sql,
            (
                data['transaction_id'],
                data['atm_id'],
                data['country'],
                data['city'],
                float(data['amount']),
                data['transaction_type']
            )
        )

        conn.commit()

        print("Inserted into Snowflake:", data)

    except Exception as e:

        print("ERROR:", e)
