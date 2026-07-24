# %%
from airflow import DAG
from airflow.providers.standard.operators.python import PythonOperator
from airflow.providers.standard.sensors.filesystem import FileSensor
from datetime import datetime, timedelta
from airflow.operators.email import EmailOperator
import logging
import pandas as pd
import os
import csv


# %%
def hello():
    print("Airflow is working!")
hello()


#%%
# # path 
RAW_FILE = "/opt/airflow/data/raw/daily_sales.csv"
STAGING_FILE = "/opt/airflow/data/staging/staged_sales.csv"
PROCESSED_FILE = "/opt/airflow/data/processed/cleaned_sales.csv"

logger = logging.getLogger("airflow.task")


default_args = {
    "owner": "susmita",
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
}
#%%
def extract_csv():
    """Create/extract the raw sales CSV file."""
    os.makedirs("/opt/airflow/data/raw", exist_ok=True)

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

    logger.info("daily_sales.csv extracted successfully")

#%%
def validate_sales_data():
    """Validate the extracted CSV."""
    df = pd.read_csv(RAW_FILE)

    if df.isnull().values.any():
        raise ValueError("Null values detected!")
    if (df["Price"] < 0).any():
        raise ValueError("Negative prices found!")
    if (df["Quantity"] < 0).any():
        raise ValueError("Negative quantities found!")

    logger.info("Validation successful! %d rows validated.", len(df))

#%%
def load_to_staging():
    """Load validated raw data into a staging file/table."""
    os.makedirs("/opt/airflow/data/staging", exist_ok=True)

    df = pd.read_csv(RAW_FILE)
    df.to_csv(STAGING_FILE, index=False)

    logger.info("Loaded %d rows into staging: %s", len(df), STAGING_FILE)

#%%

def trigger_transformation(**context):
    """Transform staged data and check sales, pushing alert info via XCom."""
    os.makedirs("/opt/airflow/data/processed", exist_ok=True)

    df = pd.read_csv(STAGING_FILE)
    df["Total_Sales"] = df["Quantity"] * df["Price"]
    df.to_csv(PROCESSED_FILE, index=False)

    total_sales = df["Total_Sales"].sum()
    logger.info("Transformation completed! Total Sales = %s", total_sales)

    context["ti"].xcom_push(key="total_sales", value=float(total_sales))

# %%
with DAG(
    dag_id="assignment_dag",
    start_date=datetime(2025, 1, 1),
    schedule="0 2 * * *",   # daily at 2 AM
    catchup=False,
    default_args=default_args,
    tags=["retail", "assignment"],
) as dag:

    extract_task = PythonOperator(
        task_id="extract_csv",
        python_callable=extract_csv,
    )
# %%
wait_for_file = FileSensor(
        task_id="wait_for_sales_file",
        filepath=RAW_FILE,
        poke_interval=30,
        timeout=300,
        mode="poke",
    )

validate_task = PythonOperator(
        task_id="validate_sales_data",
        python_callable=validate_sales_data,
    )

load_staging_task = PythonOperator(
        task_id="load_to_staging",
        python_callable=load_to_staging,
    )

transform_task = PythonOperator(
        task_id="trigger_transformation",
        python_callable=trigger_transformation,
    )
failure_alert = EmailOperator(
        task_id="send_failure_alert",
        to="sushrits@gmail.com",
        subject="Assignment Pipeline Failed",
        html_content="<h3>Pipeline Failure</h3><p>The assignment_dag pipeline failed. Please check the task logs.</p>",
        trigger_rule="one_failed",
    )
extract_task >> wait_for_file >> validate_task >> load_staging_task >> transform_task
[extract_task, wait_for_file, validate_task, load_staging_task, transform_task] >> failure_alert