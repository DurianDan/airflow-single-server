#! /usr/bin/bash
# get the absolute parent directory of this file
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_DIR="$SCRIPT_DIR/.."
export CONFIG_FOLDER_PATH="$PROJECT_DIR/config"
source $CONFIG_FOLDER_PATH/postgres.env # load env variables needed for airfblow backend upgrade
source $CONFIG_FOLDER_PATH/airflow.secret.env # load airflow secret variables

#______________Check health of existing airflow app (if any) 
AIRFLOW_HEALTH="$($SCRIPT_DIR/health.sh|grep -q "Failed to connect to")"
if [ $? -eq 0 ]; then 
    echo "airflow is healthy"
    read -e -p "Do you want to kill running airflow webserver and scheduler, and re-initialize ? " choice
    [[ "$choice" == [Yy]* ]] && echo "Re-initilize airflow webserver and scheduler" || exit 0
    $SCRIPT_DIR/kill.sh
else
    echo "airflow is not healthy"
fi

# _____________Install linux dependencies
echo "Installing/Upgrading linux dependencies..."
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install libpq-dev -y
sudo apt install python3-tk -y

# ______________Install pip dependencies
PIP_REQUIREMENTS_PATH="$CONFIG_FOLDER_PATH/requirements.txt"
PYTHON_ENVIRONMENT_VERSION="$(python3 python_minor_version.py)"
PIP_CONSTRAINT_FILE_URL="https://raw.githubusercontent.com/apache/airflow/constraints-$AIRFLOW_INSTALL_VERSION/constraints-$PYTHON_ENVIRONMENT_VERSION.txt"
echo "Installing necessary pip packages, from: $PIP_REQUIREMENTS_PATH"
echo "> PYTHON_ENVIRONMENT_VERSION: $PYTHON_ENVIRONMENT_VERSION"
echo "> AIRFLOW_INSTALL_VERSION: $AIRFLOW_INSTALL_VERSION"
echo "==> PIP_CONSTRAINT_FILE_URL: $PIP_CONSTRAINT_FILE_URL"
pip3 install --no-cache-dir apache-airflow[postgres]==$AIRFLOW_INSTALL_VERSION
pip3 install \
    --no-cache-dir \
    -r $PIP_REQUIREMENTS_PATH \
    --constraint $PIP_CONSTRAINT_FILE_URL

#______________Create and run postgres server
DOCKER_COMPOSE_FILE_PATH="$CONFIG_FOLDER_PATH/docker-compose.yaml"
echo "Initializing postgres server (for airflow-backend), using docker compose, with: $DOCKER_COMPOSE_FILE_PATH"
docker compose -f $DOCKER_COMPOSE_FILE_PATH up -d # initialize the postgres server
$SCRIPT_DIR/wait-backend.sh # wait for postgres server to be healthy

#______________Config Airflow to recognise postgres server as airflow-backend 
export AIRFLOW_HOME="${AIRFLOW_HOME:-$PROJECT_DIR/src}" 
export AIRFLOW_CONFIG="${AIRFLOW_CONFIG:-$CONFIG_FOLDER_PATH/airflow.cfg}"
export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="postgresql+psycopg2://${POSTGRES_USER}:${POSTGRES_PASSWORD}@0.0.0.0:${POSTGRES_EXPOSE_PORT}/${POSTGRES_DB}"
echo ">> AIRFLOW_HOME: $AIRFLOW_HOME"
echo ">> AIRFLOW_CONFIG: $AIRFLOW_CONFIG"

#______________Airflow create backend in the postgres-server 
echo "Initializing airflow-backend ..."
airflow db init

#______________Add user
echo "Creating '$_AIRFLOW_WWW_USER_ROLE' user: user: $_AIRFLOW_WWW_USER_USERNAME, $_AIRFLOW_WWW_USER_FIRSTNAME $_AIRFLOW_WWW_USER_LASTNAME"
airflow users create \
        --username $_AIRFLOW_WWW_USER_USERNAME \
        --firstname $_AIRFLOW_WWW_USER_FIRSTNAME \
        --lastname $_AIRFLOW_WWW_USER_LASTNAME \
        --role $_AIRFLOW_WWW_USER_ROLE \
        --email $_AIRFLOW_WWW_USER_EMAIL \
        --password $_AIRFLOW_WWW_USER_PASSWORD
