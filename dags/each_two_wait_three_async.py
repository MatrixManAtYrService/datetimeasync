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
    schedule_interval="*/2 * * * *",
    start_date=days_ago(1),
    default_args={"owner": "airflow"},
    catchup=False,
)
def each_two_wait_three_async():
    """
    Execute after each two-minute interval, and
    finish no earlier than three minutes after that interval starts.
    """

    (
        before()
        >> DateTimeSensorAsync(
            task_id="wait_exec_plus_three",
            target_time="{{ execution_date.add(minutes=3) }}",
        )
        >> after()
    )


the_async_dag = each_two_wait_three_async()
