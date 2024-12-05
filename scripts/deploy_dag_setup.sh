#!/usr/bin/env bash

set -e
set -o pipefail
set -u

gcloud composer environments storage dags import \
  --source dags_setup/setup.py \
  --environment ${COMPOSER_ENVIRONMENT} \
  --location ${LOCATION} \
  --project ${PROJECT_ID}

echo "############# DAGs setup.py file is well imported in environment ${COMPOSER_ENVIRONMENT} for project ${PROJECT_ID}"
