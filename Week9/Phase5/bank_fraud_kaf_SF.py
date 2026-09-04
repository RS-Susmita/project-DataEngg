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
    'BankFraud',
    bootstrap_servers='127.0.0.1:9092',
    group_id='bank_fraud_snowflake_demo',
    auto_offset_reset='earliest',
    value_deserializer=lambda x: x.decode('utf-8')
)

# ---------------------------------------------------
# 2. Snowflake Connection
# ---------------------------------------------------

conn = snowflake.connector.connect(
    user='SUSMITA',
    password='Sr@Snowflake16',
    account='RRNKABO-HU88041',
    warehouse='COMPUTE_WH',
    database='ATM_STREAMING_DB',
    schema='ATM_DATA',
    role='ACCOUNTADMIN'
)

cursor = conn.cursor()

print("Listening to BankFraud kafka TOPIC...")

# ---------------------------------------
# 3. Read Kafka and insert into Snowflake
# ---------------------------------------

for message in consumer:

   # try:

    #    data = json.loads (message.value)
    print(repr(message.value))
    try:
        # One Kafka message may contain multiple JSON records
        records = message.value.strip().splitlines()

        for record in records:

            if not record.strip():
                continue

            data = json.loads(record)


        sql = """
        INSERT INTO BANK_FRAUD
        (
            TRANSACTION_ID,
            CUSTOMER_ID,
            TRANSACTION_DATE,
            TRANSACTION_TIME,
            HOUR_OF_DAY,
            IS_WEEKEND,
            IS_NIGHT_TRANSACTION,
            COUNTRY,
            CITY,
            MERCHANT_CATEGORY,
            PAYMENT_METHOD,
            DEVICE_TYPE,
            CUSTOMER_AGE,
            CREDIT_SCORE,
            ACCOUNT_AGE_YEARS,
            ACCOUNT_BALANCE,
            TRANSACTION_AMOUNT,
            NUM_PREV_TRANSACTIONS,
            TRANSACTION_FREQ_MONTHLY,
            DISTANCE_FROM_HOME_KM,
            TIME_SINCE_LAST_TXN_HRS,
            IS_INTERNATIONAL,
            FAILED_ATTEMPTS,
            PIN_CHANGED_RECENTLY,
            IS_FRAUD,
            FRAUD_TYPE
        )
        VALUES (
            %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
            %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
            %s, %s, %s, %s, %s, %s
        )
        """


        cursor.execute(
            sql,
            (
                data['transaction_id'],
                data['customer_id'],
                data['transaction_date'],
                data['transaction_time'],
                data['hour_of_day'],
                data['is_weekend'],
                data['is_night_transaction'],
                data['country'],
                data['city'],
                data['merchant_category'],
                data['payment_method'],
                data['device_type'],
                data['customer_age'],
                data['credit_score'],
                data['account_age_years'],
                data['account_balance'],
                data['transaction_amount'],
                data['num_prev_transactions'],
                data['transaction_freq_monthly'],
                data['distance_from_home_km'],
                data['time_since_last_txn_hrs'],
                data['is_international'],
                data['failed_attempts'],
                data['pin_changed_recently'],
                data['is_fraud'],
                data['fraud_type']
            )
        )
        

        conn.commit()

        print("Inserted into Snowflake:", data)

    except Exception as e:

        print("ERROR:", e)