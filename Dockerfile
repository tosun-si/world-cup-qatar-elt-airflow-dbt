FROM ghcr.io/dbt-labs/dbt-bigquery:1.8.2

COPY . .

WORKDIR /dbt/world_cup_qatar_elt