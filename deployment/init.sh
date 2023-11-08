# get the absolute parent directory of this file
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/../envs/postgres.env # load envs needed for airfblow backend upgrade, from sqlite to postgresql 
source $SCRIPT_DIR/../envs/airflow.static.env # load static airflow envs

AIRFLOW_HEALTH="$($SCRIPT_DIR/health.sh|grep -q "Failed to connect to")"
if [ $? -eq 0 ]; then 
    echo "airflow is not healthy"
else
    echo "airflow is healthy"
    read -e -p "Do you want to kill running airflow webserver and scheduler, and re-initialize ? " choice
    [[ "$choice" == [Yy]* ]] && echo "Re-initilize airflow webserver and scheduler" || exit 0
    $SCRIPT_DIR/kill.sh

echo "Installing/Upgrading linux dependencies..."
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install libpq-dev -y
sudo apt install python3-tk -y
# sudo apt-get install postgresql postgresql-contrib -y

# python3 -m venv airflow
echo "Installing necessary pip packages, from: $SCRIPT_DIR/requirements.txt"
pip3 install \
    --no-cache-dir \
    -r $SCRIPT_DIR/requirements.txt \
    --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.7.3/constraints-3.10.txt"

echo "Initializing postgres server (for airflow-backend), using docker compose, with: $SCRIPT_DIR/docker-compose.yaml"
docker compose -f $SCRIPT_DIR/docker-compose.yaml up -d # initialize the postgres server
$SCRIPT_DIR/wait-postgres-healthy.sh # wait for postgres server to be healthy

export AIRFLOW_HOME="${AIRFLOW_HOME:-$(pwd)/src}" 
export AIRFLOW_CONFIG="${AIRFLOW_CONFIG:-$AIRFLOW_HOME/airflow.cfg}"
export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="postgresql+psycopg2://${POSTGRES_USER}:${POSTGRES_PASSWORD}@0.0.0.0:${POSTGRES_EXPOSE_PORT}/${POSTGRES_DB}"
echo ">> AIRFLOW_HOME: $AIRFLOW_HOME"
echo ">> AIRFLOW_CONFIG: $AIRFLOW_CONFIG"

echo "Initializing airflow-backend ..."
airflow db init

echo "Creating '$_AIRFLOW_WWW_USER_ROLE' user: user: $_AIRFLOW_WWW_USER_USERNAME, $_AIRFLOW_WWW_USER_FIRSTNAME $_AIRFLOW_WWW_USER_LASTNAME"
airflow users create \
        --username $_AIRFLOW_WWW_USER_USERNAME \
        --firstname $_AIRFLOW_WWW_USER_FIRSTNAME \
        --lastname $_AIRFLOW_WWW_USER_LASTNAME \
        --role $_AIRFLOW_WWW_USER_ROLE \
        --email $_AIRFLOW_WWW_USER_EMAIL \
        --password $_AIRFLOW_WWW_USER_PASSWORD