import os
from dataclasses import dataclass
from datetime import timedelta

from airflow.models import Variable
from airflow.utils.dates import days_ago

_variables = Variable.get("world_cup_qatar_elt_dbt", deserialize_json=True)
_feature_name = _variables["feature_name"]


@dataclass
class Settings:
    dag_folder = os.getenv("DAGS_FOLDER")
    dag_default_args = {
        'depends_on_past': False,
        'email': ['airflow@example.com'],
        'email_on_failure': False,
        'email_on_retry': False,
        'retries': 0,
        'retry_delay': timedelta(minutes=5),
        "start_date": days_ago(1)
    }
    project_id = os.getenv("GCP_PROJECT")
    location = os.getenv("COMPOSER_LOCATION")

    dataset = _variables["dataset"]
    team_stats_raw_table = _variables["team_stats_raw_table"]
    team_stats_table = _variables["team_stats_table"]
    team_stats_raw_table_schema_bucket = _variables["team_stats_raw_table_schema_bucket"]
    team_stats_raw_table_schema_object = _variables["team_stats_raw_table_schema_object"]

    team_stats_input_bucket = _variables["team_stats_input_bucket"]
    team_stats_source_object = _variables["team_stats_source_object"]
    team_stats_dest_bucket = _variables["team_stats_dest_bucket"]
    team_stats_dest_object = _variables["team_stats_dest_object"]

    dbt_dag1_id = _variables["dbt_dag1_id"]
    dbt_dag2_id = _variables["dbt_dag2_id"]

    cloud_run_job_name_dag1 = _variables["cloud_run_job_name_dag1"]
    cloud_run_job_name_dag2 = _variables["cloud_run_job_name_dag2"]

    variables = _variables
