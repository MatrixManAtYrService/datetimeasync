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
def each_five_wait_two():
    """
    Execute every five minutes, finish no earlier than two minutes later.
    """

    (
        before()
        >> DateTimeSensor(
            task_id="wait_exec_plus_two",
            target_time="{{ execution_date.add(minutes=2) }}",
        )
        >> after()
    )


the_dag = each_five_wait_two()

@dag(
    schedule_interval="*/5 * * * *",
    start_date=days_ago(1),
    default_args={"owner": "airflow"},
    catchup=False,
)
def each_five_wait_two_async():
    """
    Execute every five minutes, finish no earlier than two minutes later.
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
