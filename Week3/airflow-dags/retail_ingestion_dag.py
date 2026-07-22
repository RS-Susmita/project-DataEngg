#
from airflow import DAG
from airflow.providers.standard.operators.python import PythonOperator
from airflow.providers.standard.sensors.filesystem import FileSensor
from datetime import datetime
import pandas as pd
import os
import csv

RAW_FILE = "/opt/airflow/data/raw/daily_sales.csv"
PROCESSED_FILE = "/opt/airflow/data/processed/cleaned_sales.csv"

default_args = {
    "owner": "susmita",
    "retries": 1,
}

def create_sales_data():
    os.makedirs("/opt/airflow/data/raw", exist_ok=True)
    os.makedirs("/opt/airflow/data/processed", exist_ok=True)

    data = [
        ["Order_ID", "Product", "Quantity", "Price", "City"],
        [101, "Laptop", 10, 2500, "Paris"],
        [102, "Mouse", 10, 5500, "Madrid"],
        [103, "Keyboard", 20, 31500, "Munich"],
        [104, "Monitor", 100, 12000, "Delhi"],
    ]
    with open(RAW_FILE, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerows(data)
    print("daily_sales.csv created")

def validate_sales_data():
    df = pd.read_csv(RAW_FILE)
    if df.isnull().values.any():
        raise ValueError("Null values detected!")
    if (df["Price"] < 0).any():
        raise ValueError("Negative prices found!")
    print("Validation successful!")

def transform_sales_data():
    df = pd.read_csv(RAW_FILE)
    df["Total_Sales"] = df["Quantity"] * df["Price"]
    df.to_csv(PROCESSED_FILE, index=False)
    print("Transformation completed!")

with DAG(
    dag_id="retail_ingestion_dag",
    start_date=datetime(2025, 1, 1),
    schedule="@daily",
    catchup=False,
    default_args=default_args,
) as dag:

    create_file_task = PythonOperator(
        task_id="create_sales_data",
        python_callable=create_sales_data,
    )

    validate_task = PythonOperator(
        task_id="validate_sales_data",
        python_callable=validate_sales_data,
    )

    transform_task = PythonOperator(
        task_id="transform_sales_data",
        python_callable=transform_sales_data,
    )

    create_file_task >> validate_task >> transform_task