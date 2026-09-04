from datetime import datetime
import time

from airflow.sdk import DAG
from airflow.providers.standard.operators.python import PythonOperator


def start_pipeline():
    print("Data Pipeline Started")


def wait_10_seconds():
    print("Waiting for 10 seconds...")
    time.sleep(10)


def complete_pipeline():
    print("Data Pipeline Completed")


with DAG(
    dag_id="first_pipeline",
    start_date=datetime(2026, 1, 1),
    schedule="0 8 * * *",
    catchup=False,
) as dag:

    task1 = PythonOperator(
        task_id="start_pipeline",
        python_callable=start_pipeline,
    )

    task2 = PythonOperator(
        task_id="wait_10_seconds",
        python_callable=wait_10_seconds,
    )

    task3 = PythonOperator(
        task_id="complete_pipeline",
        python_callable=complete_pipeline,
    )

    # Task execution order
    task1 >> task2 >> task3
