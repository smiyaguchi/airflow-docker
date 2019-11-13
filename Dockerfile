FROM python:3.7-slim-stretch

ENV DEBIAN_FRONTEND noninteractive

ARG AIRFLOW_VERSION=1.10.4
ARG AIRFLOW_HOME=/usr/local/airflow

RUN set -x \
    && apt-get update \
    && apt-get install -y apt-utils \
                          build-essential \
    && pip install -U marshmallow \
    && pip install grpc-google-iam-v1==0.12.0 \
    && pip install apache-airflow[postgres,gcp]==${AIRFLOW_VERSION} \
    && pip install 'redis==3.2' \
    && apt-get clean

WORKDIR ${AIRFLOW_HOME}

ENTRYPOINT ["airflow"]
CMD ["webserver"]
