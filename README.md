<div align="center">
    <img width="100" src="https://airflow.apache.org/docs/apache-airflow/1.10.11/_images/pin_large.png" alt="Image 1">
    <img width="100" src="https://raw.githubusercontent.com/odb/official-bash-logo/master/assets/Logos/Icons/PNG/512x512.png" alt="Image 2">
</div>

# Airflow on a single server
     Simply deploy and manage airflow on a small server or personal computer, with bash scripts

# 0. Quickstart
- If [docker][1], **python** and [pip][3] have been installed, you can deploy airflow inside any Ubuntu-based system (or WSL), with these command:
```bash
cd deployment # go to the `deployment` folder
chmod +x health.sh init.sh kill.sh run.sh wait-backend.sh # allow these scripts to be executed
./init.sh # Initilize postgres server, and create default user "Admin"
./run.sh # Run and connect airflow to postgres server.
```
- The installed **Airflow version** will be **2.7.3**, and be **hosted** at the port **8080**
- To **login as admin user**, the user name is `"airflow"`, and password is `"airflow"`
- Example **dags** and **plugins** have been created for you in the folder `src/`
- For more **customization** and **management**, see the below steps.
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
#### 1.1.2. Customize Airflow to your needs
- `config/requirements.txt` is for you, to add **custom 📦 python packages** needed for your **DAG**
- `config/airflow.secret.env` is for:
     - 🤓 User **login** credential
     - 📚 Airflow versions.
     - 📂 Path to your airflow **source folder** (that will hold *dags, plugins, logs, etc.*). default is `src/`
     - 📂 Path to `airflow.cfg` folder. default is `config/airflow.cfg`
     - 🔗 Airflow exposed **ports**
     - 🔐 Your *Fernet Key* for airflow to **encrypt sensitive info**
- `config/airflow.cfg` is for [common configurations][2] (without secrets) for airflow, Examples: 🌏timezone
     ```yaml
     [core]
     default_timezone = 	Asia/Ho_Chi_Minh # timezone of your apps
     [webserver]
     default_ui_timezone = Asia/Ho_Chi_Minh #timezone of the web UI
     ```
- `config/postgres.env`, is for **postgresql** database credential, This will be used by `docker compose` to create a containerized **Postgres server**, to be used as airflow backend.
- `config/docker-compose.yaml` is for building **postgres server container**.

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
- To **kill** airflow **scheduler** and **webserver** (without deleting data): `./deployment/kill.sh`
- to **check health** of airflow (using airflow **exposed ports**, setup in `config/airflow.secret.env`): `./deployment/health.sh`
- to fully remove the **postgres server** (airflow backend):
     ```bash
     cd deployment
     docker compose down # remove the server
     ```

[1]:https://docs.docker.com/engine/install/
[2]:https://airflow.apache.org/docs/apache-airflow/stable/configurations-ref.html
[3]:https://pip.pypa.io/en/stable/installation/