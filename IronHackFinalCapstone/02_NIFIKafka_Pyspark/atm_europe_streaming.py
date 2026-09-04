"""
Step 5 - PySpark Structured Streaming Program
Real-Time ATM Transaction Monitoring in Europe

Reads from Kafka topic 'EuropeATMtTransactions', parses the JSON payload,
computes real-time KPIs, and flags suspicious high-value withdrawals.

Run with (adjust versions to match your installed Spark/Scala):
    spark-submit --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.0 atm_europe_streaming.py
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, from_json, avg, count, sum as _sum
from pyspark.sql.types import StructType, StructField, StringType, DoubleType

# ---------------------------------------------------------------------------
# 1. Spark session
# ---------------------------------------------------------------------------
spark = (
    SparkSession.builder
    .appName("ATM_Europe_Streaming")
    .getOrCreate()
)

spark.sparkContext.setLogLevel("WARN")

# ---------------------------------------------------------------------------
# 2. Read raw stream from Kafka
# ---------------------------------------------------------------------------
raw_stream = (
    spark.readStream
    .format("kafka")
    .option("kafka.bootstrap.servers", "localhost:9092")
    .option("subscribe", "EuropeATMTransaction")
    .option("startingOffsets", "latest")
    .load()
)

# Kafka gives us key/value as bytes - the JSON payload is in "value"
raw_json = raw_stream.selectExpr("CAST(value AS STRING) AS json_value")

# ---------------------------------------------------------------------------
# 3. Define schema and parse JSON, cast amount to numeric
# ---------------------------------------------------------------------------
atm_schema = StructType([
    StructField("transaction_id", StringType()),
    StructField("atm_id", StringType()),
    StructField("country", StringType()),
    StructField("city", StringType()),
    StructField("amount", StringType()),          # arrives as string from NiFi
    StructField("transaction_type", StringType()),
])

parsed = (
    raw_json
    .select(from_json(col("json_value"), atm_schema).alias("data"))
    .select("data.*")
    .withColumn("amount", col("amount").cast(DoubleType()))
)

# ---------------------------------------------------------------------------
# 4. Real-Time KPIs: total transactions, total & average withdrawal amount
# ---------------------------------------------------------------------------
withdrawals = parsed.filter(col("transaction_type") == "Withdrawal")

kpis = withdrawals.agg(
    count("*").alias("total_transactions"),
    _sum("amount").alias("total_withdrawal_amount"),
    avg("amount").alias("avg_withdrawal_amount"),
)

kpi_query = (
    kpis.writeStream
    .outputMode("complete")     # aggregates over the whole stream so far
    .format("console")
    .option("truncate", False)
    .queryName("kpi_console")
    .start()
)

# ---------------------------------------------------------------------------
# 5. Fraud Detection: flag withdrawals above 3000
# ---------------------------------------------------------------------------
FRAUD_THRESHOLD = 4000

fraud_alerts = withdrawals.filter(col("amount") > FRAUD_THRESHOLD).select(
    col("transaction_id"),
    col("country"),
    col("city"),
    col("amount"),
)

fraud_query = (
    fraud_alerts.writeStream
    .outputMode("append")       # each new suspicious row, once
    .format("console")
    .option("truncate", False)
    .queryName("fraud_console")
    .start()
)

# ---------------------------------------------------------------------------
# 6. Keep the app running
# ---------------------------------------------------------------------------
spark.streams.awaitAnyTermination()
