FROM quay.io/astronomer/ap-airflow-dev:2.2.0-buster-onbuild-43353
COPY ./dags ./dags
