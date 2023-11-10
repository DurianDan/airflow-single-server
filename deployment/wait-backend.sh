#! /usr/bin/bash
# get the absolute parent directory of this file
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Name of the service you want to wait for
SERVICE_NAME="airflow-backend"

# Maximum number of retries (adjust as needed)
MAX_RETRIES=60

# Sleep duration between retries (adjust as needed)
SLEEP_DURATION=5

DOCKER_COMPOSE_FILE="$SCRIPT_DIR/../config/docker-compose.yaml"

# Command to check if the service is healthy
HEALTH_CHECK_COMMAND="docker compose -f $DOCKER_COMPOSE_FILE ps -q $SERVICE_NAME | xargs docker inspect -f '{{.State.Health.Status}}'"

# Counter for retries
retries=0

echo "Waiting for service $SERVICE_NAME to become healthy..."

# Loop until the service is healthy or the maximum retries are reached
while true; do
    status=$(eval $HEALTH_CHECK_COMMAND)

    if [ "$status" == "healthy" ]; then
        echo "Service $SERVICE_NAME is healthy."
        break
    fi

    if [ "$retries" -ge "$MAX_RETRIES" ]; then
        echo "Service $SERVICE_NAME did not become healthy after $MAX_RETRIES retries."
        exit 1
    fi

    retries=$((retries + 1))
    echo "Service $SERVICE_NAME is not yet healthy. Retry $retries of $MAX_RETRIES..."
    sleep $SLEEP_DURATION
done
