# world-cup-qatar-elt-airflow-dbt

This repo via a real world use case, shows how to launch dbt models from a DAG in Apache Airflow.
Dbt is deployed in a Cloud Run job, and we present 2 use cases: 
- DAG to execute the dbt pipeline and models via a `CloudRunJobOperator`
- DAG that executes and materializes the dbt models as Airflow tasks, via the `cosmos` library. The executor is Cloud Run for this example. This technic allows to retry and launch a dbt model directly in Airflow

## Prerequisites

- Python 3.13.11
- [uv](https://docs.astral.sh/uv/) as Python package manager
- [direnv](https://direnv.net/) for automatic environment management

## Setup

Install dependencies:

```bash
uv sync
```

The `.envrc` file automatically creates and activates a virtual environment via `uv venv` when entering the project directory with direnv.

## Docker image for dbt

The Dockerfile uses a separate `dbt_requirements.txt` (containing only `dbt-core` and `dbt-bigquery`) to keep the container image lean — Airflow, Cosmos, and pytest are not needed in the dbt Cloud Run job container.

## Install the Astronomer Cosmos package in Cloud Composer (PyPi package)

```
astronomer-cosmos>=1.14.0
```

## Local Airflow execution with Docker

For local testing of the DAG against real GCP resources, use the Airflow Docker dev image from the [airflow-gcp-docker-dev](https://github.com/tosun-si/airflow-gcp-docker-dev) project.

### Build the Docker image

```bash
cd /path/to/airflow-gcp-docker-dev
docker build -t airflow-dev .
```

### Run the DAG locally

From this project's root directory. The entire `world_cup_qatar_elt_dbt` folder is mounted because the Cosmos DAG needs access to the dbt project alongside the DAG files:

```bash
docker run -it \
    -p 8080:8080 \
    -e GOOGLE_APPLICATION_CREDENTIALS=/root/.config/gcloud/application_default_credentials.json \
    -e GCP_PROJECT=gb-poc-373711 \
    -e GOOGLE_CLOUD_PROJECT=gb-poc-373711 \
    -e COMPOSER_LOCATION=europe-west1 \
    -v $HOME/.config/gcloud/application_default_credentials.json:/root/.config/gcloud/application_default_credentials.json \
    -v $(pwd)/world_cup_qatar_elt_dbt:/opt/airflow/dags/world_cup_qatar_elt_dbt \
    -v $(pwd)/config:/opt/airflow/config \
    airflow-dev
```

## Deploy the dbt app in a Cloud Run job and copy the dbt folder in GCS bucket

```bash
gcloud builds submit \
    --project=$PROJECT_ID \
    --region=$LOCATION \
    --config deploy-dbt-app.yaml \
    --substitutions _REPO_NAME="$REPO_NAME",_JOB_NAME="$JOB_NAME",_IMAGE_TAG="$IMAGE_TAG",_SERVICE_ACCOUNT="$SERVICE_ACCOUNT",_GCP_AUTH_METHOD="$GCP_AUTH_METHOD",_BIGQUERY_DATASET="$BIGQUERY_DATASET",_BIGQUERY_PRIORITY="$BIGQUERY_PRIORITY",_BIGQUERY_TIMEOUT="$BIGQUERY_TIMEOUT",_BIGQUERY_THREADS="$BIGQUERY_THREADS"
```

## Deploy DAGs in Airflow

```bash
gcloud builds submit \
    --project=$PROJECT_ID \
    --region=$LOCATION \
    --config deploy-dag.yaml \
    --substitutions _DAG_ROOT_FOLDER=$DAG_ROOT_FOLDER,_COMPOSER_ENVIRONMENT=$COMPOSER_ENVIRONMENT,_CONFIG_FOLDER_NAME=$CONFIG_FOLDER_NAME,_ENV=$ENV
```