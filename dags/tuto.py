from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta


default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": datetime(2019, 11, 14),
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

dag = DAG("tutorial", default_args=default_args, schedule_interval=timedelta(1))

t1 = BashOperator(task_id="print_date", bash_command="date", dag=dag)
t2 = BashOperator(task_id="print_hello", bash_command="echo Hello World", dag=dag)

t1 >> t2
