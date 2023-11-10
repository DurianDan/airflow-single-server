#! /usr/bin/bash
# get the absolute parent directory of this file
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
AIRFLOW_HOME="${AIRFLOW_HOME:-$SCRIPT_DIR/../src}" 

source $SCRIPT_DIR/../config/airflow.secret.env

echo "> Killing webserver"
# fuser -k  "${AIRFLOW__WEBSERVER__WEB_SERVER_PORT:-8080}/tcp"
kill $(cat $AIRFLOW_HOME/airflow-webserver.pid)

echo "> Killing scheduler and worker"
fuser -k  "${AIRFLOW__LOGGING__WORKER_LOG_SERVER_PORT:-8793}/tcp"