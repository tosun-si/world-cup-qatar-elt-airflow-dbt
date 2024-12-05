#!/usr/bin/env bash

set -e
set -o pipefail
set -u

echo "############# Deploying the data config variables of module ${FEATURE_NAME} to composer"

# deploy variables
gcloud composer environments storage data import \
  --source ${CONFIG_FOLDER_NAME}/variables/${ENV}/variables.json \
  --destination "${FEATURE_NAME}"/config \
  --environment ${COMPOSER_ENVIRONMENT} \
  --location ${LOCATION} \
  --project ${PROJECT_ID}

gcloud beta composer environments run ${COMPOSER_ENVIRONMENT} \
  --project ${PROJECT_ID} \
  --location ${LOCATION} \
  variables import \
  -- /home/airflow/gcs/data/"${FEATURE_NAME}"/config/variables.json

echo "############# Variables of ${FEATURE_NAME} are well imported in environment ${COMPOSER_ENVIRONMENT} for project ${PROJECT_ID}"
