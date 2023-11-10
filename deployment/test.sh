#! /usr/bin/bash
# get the absolute parent directory of this file
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_DIR="$SCRIPT_DIR/.."
source $PROJECT_DIR/config/postgres.env # load env variables needed for airfblow backend upgrade
source $PROJECT_DIR/config/airflow.secret.env # load airflow secret variables

# ______________Install pip dependencies
PIP_REQUIREMENTS_PATH="$PROJECT_DIR/config/requirements.txt"
PYTHON_ENVIRONMENT_VERSION="$(python3 python_minor_version.py)"
PIP_CONSTRAINT_FILE_URL="https://raw.githubusercontent.com/apache/airflow/constraints-$AIRFLOW_INSTALL_VERSION/constraints-$PYTHON_ENVIRONMENT_VERSION.txt"
echo "Installing necessary pip packages, from: $PIP_REQUIREMENTS_PATH"
echo "> PYTHON_ENVIRONMENT_VERSION: $PYTHON_ENVIRONMENT_VERSION"
