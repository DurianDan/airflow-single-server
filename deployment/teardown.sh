#! /usr/bin/bash
# get the absolute parent directory of this file
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_DIR="$SCRIPT_DIR/.."

docker compose -f $PROJECT_DIR/config/docker-compose.yaml down
docker rm airflow-backend

$SCRIPT_DIR/kill.sh

read -e -p "Do you want to delete airflow-backend (postgres mounted volume)(yY/N)? " ALLOW_DELETE_AIRFLOW_BACKEND
[[ "$ALLOW_DELETE_AIRFLOW_BACKEND" == [Yy]* ]] && docker rmi postgres:15

read -e -p "Do you want to delete the postgres:15 docker image(yY/N)? " ALLOW_DELETE_POSTGRES_IMAGE
[[ "$ALLOW_DELETE_POSTGRES_IMAGE" == [Yy]* ]] && docker rmi postgres:15
