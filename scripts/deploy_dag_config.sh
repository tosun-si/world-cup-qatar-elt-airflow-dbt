#!/usr/bin/env bash

set -e
set -o pipefail
set -u

echo "############# Deploying the data config variables of module ${DAG_ROOT_FOLDER} to composer"

# deploy variables
gcloud composer environments storage data import \
  --source ${CONFIG_FOLDER_NAME}/variables/${ENV}/variables.json \
  --destination "${DAG_ROOT_FOLDER}"/config \
  --environment ${COMPOSER_ENVIRONMENT} \
  --location ${LOCATION} \
  --project ${PROJECT_ID}

gcloud beta composer environments run ${COMPOSER_ENVIRONMENT} \
  --project ${PROJECT_ID} \
  --location ${LOCATION} \
  variables import \
  -- /home/airflow/gcs/data/"${DAG_ROOT_FOLDER}"/config/variables.json

echo "############# Variables of ${DAG_ROOT_FOLDER} are well imported in environment ${COMPOSER_ENVIRONMENT} for project ${PROJECT_ID}"
