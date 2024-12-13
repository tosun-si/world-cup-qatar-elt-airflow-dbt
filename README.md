# world-cup-qatar-elt-airflow-dbt

This repo via a real world use case, shows how to launch dbt models from a DAG in Apache Airflow.\
Dbt is deployed in a Cloud Run job, and we present 2 use cases: 
- DAG to execute the dbt pipeline and models via a `CloudRunJobOperator`
- DAG that executes and materializes the dbt models as Airflow tasks, via the `cosmos` library. The executor is Cloud Run for this example. This technic allows to retry and launch a dbt model directly in Airflow

## Install the Astronomer Cosmos package in Cloud Composer (PyPi package)

```
astronomer-cosmos = "==1.7.1"
```

## Deploy the dbt app in a Cloud Run job and copy the dbt folder in GCS bucket

```bash
gcloud builds submit \
    --project=$PROJECT_ID \
    --region=$LOCATION \
    --config deploy-dbt-app.yaml \
    --substitutions _REPO_NAME="$REPO_NAME",_JOB_NAME="$JOB_NAME",_IMAGE_TAG="$IMAGE_TAG",_SERVICE_ACCOUNT="$SERVICE_ACCOUNT",_GCP_AUTH_METHOD="$GCP_AUTH_METHOD",_BIGQUERY_DATASET="$BIGQUERY_DATASET",_BIGQUERY_PRIORITY="$BIGQUERY_PRIORITY",_BIGQUERY_TIMEOUT="$BIGQUERY_TIMEOUT",_BIGQUERY_THREADS="$BIGQUERY_THREADS" \
    --verbosity="debug" .
```

## Deploy DAGs in Airflow

```bash
gcloud builds submit \
    --project=$PROJECT_ID \
    --region=$LOCATION \
    --config deploy-dag.yaml \
    --substitutions _FEATURE_NAME=$FEATURE_NAME,_COMPOSER_ENVIRONMENT=$COMPOSER_ENVIRONMENT,_CONFIG_FOLDER_NAME=$CONFIG_FOLDER_NAME,_ENV=$ENV \
    --verbosity="debug" .
```