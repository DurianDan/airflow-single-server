#! /usr/bin/bash
# get the absolute parent directory of this file
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/../config/airflow.secret.env

CHECK_WEBSERVER="http://localhost:$AIRFLOW__WEBSERVER__WEB_SERVER_PORT/health"

# Send an HTTP request and store the JSON response
echo "Checking Airflow Health at $CHECK_WEBSERVER"
CHECK_WEBSERVER_OUTPUT="$(curl -f $CHECK_WEBSERVER)"
echo $CHECK_WEBSERVER_OUTPUT
