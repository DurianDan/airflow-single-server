<div align="center">
    <img width="100" src="https://airflow.apache.org/docs/apache-airflow/1.10.11/_images/pin_large.png" alt="Image 1">
    <img width="100" src="https://raw.githubusercontent.com/odb/official-bash-logo/master/assets/Logos/Icons/PNG/512x512.png" alt="Image 2">
</div>

# Airflow on a single server
     Simplify deployment and management, for airflow 2.7.3 on a single server, with bash scripts
# 1. Deployment.
## 1.1. Setup Environment.
#### 1.1.1. Install Prerequisites.
- *Using a **python virtual environment** is **recommended**, you can use the commands below to quickly create and use a **python venv**
     ```bash
     python3 -m venv airflow-venv # create a virtual env called: airflow-venv
     source ./airflow-venv/bin/activate # activate the virtual environment.
     ```
- Please install [docker (and docker compose)][1] in your system/server.
- Allow bash cripts to be executed, using `chmod`:
     ```bash
     cd deployment
     chmod +x health.sh init.sh kill.sh run.sh wait-backend.sh
     ```
#### 1.1.2. Add Your Secrets (User credential, secret keys, app ports, etc.)
- *You might want to take a look at `config/airflow.cfg`, it contains common configuration for airflow, Examples:
     ```yaml
     [core]
     default_timezone = 	Asia/Ho_Chi_Minh # timezone of your apps
     [webserver]
     default_ui_timezone = Asia/Ho_Chi_Minh #timezone of the web UI
     ```
- You must setup every variables (secrets, admin user info, ports) in 2 files:
     - `config/airflow.secret.env`. Check out the [docs][2], to know the function of each variable.
     - `config/postgres.env`. This will be used by `docker compose` to create a containerized **Postgres server**, to be used as airflow backend.

## 1.2. Initialize `airflow backend`
Execute the command: `./deployment/init.sh`, to perform these tasks:
- Install neccessary **linux packages**
- Create the **airflow backend** (postgres server).
- Connect **Airflow** to **airflow backend**
- Create **Admin** user.

## 1.3. Run the `Airflow Webserver` and `Scheduler`
Execute `./deployment/run.sh`, to:
- Run the `airflow scheduler` in the backgound
- Run the `airflow webserver` in the backgound

## 2. Management
- To **kill** airflow **scheduler** and **webserver**: `./deployment/kill.sh`
- to **check health** of airflow (using airflow **exposed ports**, setup in `config/airflow.secret.env`): `./deployment/health.sh`


[1]:https://docs.docker.com/engine/install/
[2]:https://airflow.apache.org/docs/apache-airflow/stable/configurations-ref.html
