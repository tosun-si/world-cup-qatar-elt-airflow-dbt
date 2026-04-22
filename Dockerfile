FROM python:3.11

COPY dbt_requirements.txt ./

RUN pip install -r dbt_requirements.txt

RUN mkdir /root/.dbt

COPY world_cup_qatar_elt_dbt /home/airflow/gcs/dags/world_cup_qatar_elt_dbt
COPY world_cup_qatar_elt_dbt/dbt/world_cup_qatar_elt/profiles.yml /root/.dbt/profiles.yml

WORKDIR /home/airflow/gcs/dags/world_cup_qatar_elt_dbt/dbt/world_cup_qatar_elt