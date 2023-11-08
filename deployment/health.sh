#! usr/bin/bash
# get the absolute parent directory of this file
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/../envs/postgres.env

check_scheduler="http://localhost:$AIRFLOW__SCHEDULER__SCHEDULER_HEALTH_CHECK_SERVER_PORT/health"
check_webserver="http://localhost:$AIRFLOW__WEBSERVER__WEB_SERVER_PORT/health"

# Send an HTTP request and store the JSON response
echo "Checking Scheduler at $check_scheduler"
curl "$check_scheduler"

echo "Checking Scheduler at $check_webserver"
curl "$check_webserver"
