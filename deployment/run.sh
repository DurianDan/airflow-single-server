#! /usr/bin/bash
# get the absolute parent directory of this file
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

source $SCRIPT_DIR/../config/postgres.env # load env variables needed for airfblow backend upgrade
source $SCRIPT_DIR/../config/airflow.secret.env # load airflow secret variables
export AIRFLOW_HOME="${AIRFLOW_HOME:-$(pwd)/src}" 
export AIRFLOW_CONFIG="${AIRFLOW_CONFIG:-$AIRFLOW_HOME/airflow.cfg}"
export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="postgresql+psycopg2://${POSTGRES_USER}:${POSTGRES_PASSWORD}@0.0.0.0:${POSTGRES_EXPOSE_PORT}/${POSTGRES_DB}"

airflow webserver &
airflow scheduler &