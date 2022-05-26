"""
DAG to summary the orders data
"""
from airflow import DAG
from airflow.operators.mysql_operator import MySqlOperator

default_arg = {
    'owner': 'vj', 
    'start_date': '2022-03-22', 
    'catchup': False
}

dag = DAG(
    'generate-stats',
    default_args=default_arg,
    schedule_interval='0 */30 * * *',
    catchup=False,
)

mysql_task = MySqlOperator(
    dag=dag,
    mysql_conn_id='mysql_default', 
    task_id='order_summary',
    sql='sqls/orders_summary.sql',
)

mysql_task