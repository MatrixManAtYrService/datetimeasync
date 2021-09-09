from airflow.decorators import dag, task
from airflow.sensors.date_time import DateTimeSensor, DateTimeSensorAsync
from airflow.utils.dates import days_ago


@task
def before():
    print("before")


@task
def after():
    print("after")


@dag(
    schedule_interval="*/5 * * * *",
    start_date=days_ago(1),
    default_args={"owner": "airflow"},
    catchup=False,
)
def each_five_wait_two_async():
    """
    Execute after each five-minute interval, and
    finish no earlier than two minutes after that interval starts.
    """

    (
        before()
        >> DateTimeSensorAsync(
            task_id="wait_exec_plus_two",
            target_time="{{ execution_date.add(minutes=2) }}",
        )
        >> after()
    )


the_async_dag = each_five_wait_two_async()