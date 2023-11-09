from airflow.decorators import task, dag, task_group # for defining dags
import pendulum # to replace `datetime` module

# using `custom_modules`, inside the /src/plugins folder
# Importing anything inside the plugins folder like a regular python function.
from custom_modules.say_hello import say_hello
from airflow.models import Variable # to loads airflow variables, with be str
from typing import Literal, Dict # for type hinting

OWNER = "HuyVuNguyen"

@dag(
    schedule="0 0 1 * *", # scheduling using cron string
    start_date=pendulum.datetime(2023, 1, 1),
    catchup=False,
    dag_id="test_dag",
    default_args={"owner": OWNER}, # owner column in the DAGs tab of Airflow UI
    owner_links={
        OWNER: "https://github.com/DurianDan", # hyperlink in the owner column
    },
    tags=[ # tags for this DAG
        "test",
        "airflow",
        "dag"
    ],
)
def handler():

    MESSAGES = Dict[Literal["message1", "message2"], str]
    @task(
        show_return_value_in_logs=False, # if `True`, the output of this task will be logged in task log (Not XCOM log)
        multiple_outputs=True # if the returned values is a dictionary with keys, this needs to be parsed as `True`
    )
    def generate_messages() -> MESSAGES:
        print("this is the first task")
        return {
            "message1": "This is the first message from the first DAG",
            "message2": "This is the second message from the first DAG"
            }

    @task(show_return_value_in_logs=False)
    def what_is_message1(msg1: Dict[str, str]) -> None:
        print(f"This is `message1` from the first dag{msg1}")

    @task(show_return_value_in_logs=False)
    def what_is_message2(msg2: Dict[str, str]) -> str:
        print(f"This is `message2` from the first dag{msg2}")
        return f"Done printing messages in {pendulum.now()}"

    @task_group
    def print_messages(msgs: MESSAGES) -> str:
        what_is_message1(msgs['message1'])
        return what_is_message2(msgs["message2"])

    @task(show_return_value_in_logs=False)
    def say_hello_using_airflow_variable(print_messages_result: str):
        # Set custom airflow variables, like environment variables
        # for more info: https://docs.astronomer.io/learn/airflow-variables
        Variable.set("dag.test.my_name", "Huy Vu Nguyen")

        my_name = Variable.get("dag.test.my_name")
        print(print_messages_result)
        say_hello(my_name)

    messages = generate_messages()
    print_messages_result = print_messages(messages)
    say_hello_using_airflow_variable(print_messages_result)

handler()