FROM python:3.7-slim-stretch

ENV DEBIAN_FRONTEND noninteractive

ARG AIRFLOW_VERSION=1.10.4
ARG AIRFLOW_USER_HOME=/usr/local/airflow
ENV AIRFLOW_HOME=${AIRFLOW_USER_HOME}

RUN set -x \
    && buildDeps=' \
         freetds-dev \
	 libkrb5-dev \
	 libsasl2-dev \
	 libssl-dev \
 	 libffi-dev \
	 libpq-dev \
	 git \
       ' \		
    && apt-get update \
    && apt-get install -y --no-install-recommends \
	$buildDeps \
        apt-utils \
        build-essential \
	netcat \
    && useradd -ms /bin/bash -d ${AIRFLOW_USER_HOME} airflow \
    && pip install -U marshmallow \
    && pip install pytz \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install grpc-google-iam-v1==0.11.4 \
    && pip install psycopg2-binary \
    && pip install apache-airflow[postgres,gcp]==${AIRFLOW_VERSION} \
    && pip install 'redis==3.2' \
    && apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY script/entrypoint.sh ${AIRFLOW_USER_HOME}/entrypoint.sh
COPY config/airflow.cfg ${AIRFLOW_USER_HOME}/airflow.cfg

RUN chown -R airflow:airflow ${AIRFLOW_USER_HOME}
RUN chmod +x ${AIRFLOW_USER_HOME}/entrypoint.sh

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_USER_HOME}

ENTRYPOINT ["/usr/local/airflow/entrypoint.sh"]
CMD ["webserver"]
