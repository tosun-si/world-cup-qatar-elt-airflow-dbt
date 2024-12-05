import airflow
from airflow.providers.google.cloud.operators.cloud_run import CloudRunExecuteJobOperator
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from airflow.providers.google.cloud.transfers.gcs_to_gcs import GCSToGCSOperator

from world_cup_qatar_elt_dbt.dag.settings import Settings

settings = Settings()

with airflow.DAG(
        "world_cup_qatar_elt_dag",
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

    execute_dbt_job = CloudRunExecuteJobOperator(
        task_id="execute_dbt_job",
        project_id=settings.project_id,
        region=settings.location,
        job_name=settings.cloud_run_job_name_dag1,
        dag=dag,
        deferrable=False,
    )

    move_file_to_cold = GCSToGCSOperator(
        task_id="move_file_to_cold",
        source_bucket=settings.team_stats_input_bucket,
        source_object=settings.team_stats_source_object,
        destination_bucket=settings.team_stats_dest_bucket,
        destination_object=settings.team_stats_dest_object,
        move_object=False
    )

    load_team_stats_raw_to_bq >> execute_dbt_job >> move_file_to_cold
