# Project: world-cup-qatar-elt-airflow-dbt

ELT pipeline with dbt, BigQuery and Airflow orchestration on Google Cloud.
Raw data: Qatar FIFA World Cup Players stats.

## Tech stack

- **dbt** (dbt-core + dbt-bigquery) for data transformations
- **BigQuery** as data warehouse
- **Apache Airflow** (Cloud Composer) for orchestration
- **Astronomer Cosmos** for materializing dbt models as Airflow tasks
- **Cloud Run Jobs** for dbt execution
- **Cloud Build** for CI/CD
- **uv** as Python package manager
- **direnv** with `.envrc` for environment management

## Project structure

- `world_cup_qatar_elt_dbt/dag/` - Airflow DAGs
  - `world_cup_qatar_elt_dbt_case1_dag.py` - triggers dbt via `CloudRunJobOperator`
  - `world_cup_qatar_elt_dbt_case2_dag.py` - dbt models as Airflow tasks via Cosmos with Cloud Run executor
  - `settings.py` - DAG settings from Airflow Variables
- `world_cup_qatar_elt_dbt/dbt/world_cup_qatar_elt/` - dbt project (models, macros, profiles)
- `dags_setup/` - Composer DAG setup
- `config/variables/` - Airflow variables per environment
- `scripts/` - deployment scripts for DAGs and config to Cloud Composer
- `deploy-dbt-app.yaml` - Cloud Build config for dbt Cloud Run job
- `deploy-dag.yaml` - Cloud Build config for DAG deployment
- `Dockerfile` - dbt image for Cloud Run job
- `dbt_requirements.txt` - separate dbt-only deps for Docker (keeps image lean)

## Development setup

- Python 3.13.11 (see `.python-version`)
- Uses `uv` for dependency management (`pyproject.toml`)
- Uses `direnv` with `.envrc` for automatic venv activation and env vars
- Run `uv sync` to install dependencies
- GCP project: `gb-poc-373711`, region: `europe-west1`
- Cloud Composer environment: `dev-composer-env`

## Local Airflow testing with Docker

Use the [airflow-gcp-docker-dev](https://github.com/tosun-si/airflow-gcp-docker-dev) image to test DAGs locally against real GCP resources before deploying to Composer.

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

The entire `world_cup_qatar_elt_dbt` folder is mounted because the Cosmos DAG needs the dbt project alongside the DAG files.

## dbt commands

```bash
dbt deps --project-dir world_cup_qatar_elt_dbt/dbt/world_cup_qatar_elt
dbt run --project-dir world_cup_qatar_elt_dbt/dbt/world_cup_qatar_elt
```

## Deploy the Airflow DAG to Cloud Composer

The DAG folder and its config variables are deployed via Cloud Build (`deploy-dag.yaml`), which invokes `scripts/deploy_dag_config.sh` and `scripts/deploy_dag_folder.sh`:

```bash
gcloud builds submit \
    --project=$PROJECT_ID \
    --region=$LOCATION \
    --config deploy-dag.yaml \
    --substitutions _DAG_ROOT_FOLDER=$DAG_ROOT_FOLDER,_COMPOSER_ENVIRONMENT=$COMPOSER_ENVIRONMENT,_CONFIG_FOLDER_NAME=$CONFIG_FOLDER_NAME,_ENV=$ENV
```

Required env vars (set in `.envrc`): `DAG_ROOT_FOLDER`, `COMPOSER_ENVIRONMENT`, `CONFIG_FOLDER_NAME`, `ENV`.
