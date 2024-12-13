import os
from pathlib import Path

import airflow
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from airflow.providers.google.cloud.transfers.gcs_to_gcs import GCSToGCSOperator

from world_cup_qatar_elt_dbt.dag.settings import Settings

settings = Settings()

from cosmos import DbtTaskGroup, ProjectConfig, ExecutionConfig
from cosmos.constants import ExecutionMode

DEFAULT_DBT_ROOT_PATH = Path(__file__).parent.parent / "dbt"
DBT_ROOT_PATH = Path(os.getenv("DBT_ROOT_PATH", DEFAULT_DBT_ROOT_PATH))

project_config = ProjectConfig(
    dbt_project_path=(DBT_ROOT_PATH / "world_cup_qatar_elt").as_posix(),
)

execution_config = ExecutionConfig(
    execution_mode=ExecutionMode.GCP_CLOUD_RUN_JOB,
)

with airflow.DAG(
        settings.dbt_dag2_id,
        default_args=settings.dag_default_args,
        schedule_interval=None) as dag:
    load_team_stats_raw_to_bq = GCSToBigQueryOperator(
        task_id='load_team_player_stats_raw_to_bq',
        bucket=settings.team_stats_input_bucket,
        source_objects=[settings.team_stats_source_object],
        destination_project_dataset_table=f'{settings.project_id}.{settings.dataset}.{settings.team_stats_raw_table}',
        source_format='NEWLINE_DELIMITED_JSON',
        compression='NONE',
        create_disposition=settings.variables['team_stats_raw_create_disposition'],
        write_disposition=settings.variables['team_stats_raw_write_disposition'],
        autodetect=False,
        schema_object_bucket=settings.team_stats_raw_table_schema_bucket,
        schema_object=settings.team_stats_raw_table_schema_object
    )

    team_stats_models = DbtTaskGroup(
        group_id="team_stats_models",
        project_config=project_config,
        execution_config=execution_config,
        operator_args={
            "project_id": settings.project_id,
            "region": settings.location,
            "job_name": settings.cloud_run_job_name_dag2,
        },
        default_args={"retries": 0},
        dag=dag,
    )

    move_file_to_cold = GCSToGCSOperator(
        task_id="move_file_to_cold",
        source_bucket=settings.team_stats_input_bucket,
        source_object=settings.team_stats_source_object,
        destination_bucket=settings.team_stats_dest_bucket,
        destination_object=settings.team_stats_dest_object,
        move_object=False
    )

    load_team_stats_raw_to_bq >> team_stats_models >> move_file_to_cold
