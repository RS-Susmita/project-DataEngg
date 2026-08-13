from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
 
DBT_PROJECT_DIR = '/opt/airflow/dbt_project'
DBT_PROFILES_DIR = '/opt/airflow/dbt_project'
 
default_args = {
    'owner': 'data-team',
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}
 
DBT_FLAGS = f'--project-dir {DBT_PROJECT_DIR} --profiles-dir {DBT_PROFILES_DIR}'
 
with DAG(
    dag_id='dbt_snowflake_pipeline',
    description='Seed, run, test, and snapshot a dbt project against Snowflake',
    default_args=default_args,
    start_date=datetime(2026, 1, 1),
    schedule='@daily',
    catchup=False,
    tags=['dbt', 'snowflake'],
) as dag:
    DBT_BIN = '/home/airflow/.local/bin/dbt'

    dbt_seed = BashOperator(
        task_id='dbt_seed',
        bash_command=f' {DBT_BIN} seed {DBT_FLAGS}',
    )
 
    dbt_run = BashOperator(
        task_id='dbt_run',
        bash_command=f' {DBT_BIN} run {DBT_FLAGS}',
    )
 
    dbt_test = BashOperator(
        task_id='dbt_test',
        bash_command=f'{DBT_BIN} test {DBT_FLAGS}',
    )
 
    dbt_snapshot = BashOperator(
        task_id='dbt_snapshot',
        bash_command=f'{DBT_BIN} snapshot {DBT_FLAGS}',
    )
 
    dbt_seed >> dbt_run >> dbt_test >> dbt_snapshot
 
