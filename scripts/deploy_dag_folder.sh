#!/usr/bin/env bash

set -e
set -o pipefail
set -u

# Remove current DAG folder.
gcloud composer environments storage dags delete \
  ${DAG_ROOT_FOLDER} \
  -q \
  --environment ${COMPOSER_ENVIRONMENT} \
  --location ${LOCATION} \
  --project ${PROJECT_ID}

echo "############# Current existing DAG folder ${DAG_ROOT_FOLDER} is well deleted in environment ${COMPOSER_ENVIRONMENT} for project ${PROJECT_ID}"

#  Then replace it.
gcloud composer environments storage dags import \
  --source ${DAG_ROOT_FOLDER} \
  --environment ${COMPOSER_ENVIRONMENT} \
  --location ${LOCATION} \
  --project ${PROJECT_ID}

echo "############# DAG folder ${DAG_ROOT_FOLDER} is well imported in environment ${COMPOSER_ENVIRONMENT} for project ${PROJECT_ID}"
