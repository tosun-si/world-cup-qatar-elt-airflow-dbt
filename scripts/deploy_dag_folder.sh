#!/usr/bin/env bash

set -e
set -o pipefail
set -u

# Remove current DAG folder.
gcloud composer environments storage dags delete \
  ${FEATURE_NAME} \
  -q \
  --environment ${COMPOSER_ENVIRONMENT} \
  --location ${LOCATION} \
  --project ${PROJECT_ID}

echo "############# Current existing DAG folder ${FEATURE_NAME} is well deleted in environment ${COMPOSER_ENVIRONMENT} for project ${PROJECT_ID}"

#  Then replace it.
gcloud composer environments storage dags import \
  --source ${FEATURE_NAME} \
  --environment ${COMPOSER_ENVIRONMENT} \
  --location ${LOCATION} \
  --project ${PROJECT_ID}

echo "############# DAG folder ${FEATURE_NAME} is well imported in environment ${COMPOSER_ENVIRONMENT} for project ${PROJECT_ID}"
