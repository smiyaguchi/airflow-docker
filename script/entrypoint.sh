#!/usr/bin/env bash

: "${POSTGRES_HOST:="postgres"}"
: "${POSTGRES_PORT:="5432"}"
: "${POSTGRES_USER:="airflow"}"
: "${POSTGRES_PASSWORD:="airflow"}"
: "${POSTGRES_DB:="airflow"}"

: "${AIRFLOW_HOME:="/usr/local/airflow"}"
: "${AIRFLOW__CORE__FERNET_KEY:=${FERNET_KEY:=$(python -c "from cryptgraphy.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)")}}"
: "${AIRFLOW__CORE__EXECUTOR:=${EXECUTOR:-Local}Executor}"

export \
    AIRFLOW_HOME \
    AIRFLOW__CELERY__RESULT_BACKEND \
    AIRFLOW__CORE__EXECUTOR \
    AIRFLOW__CORE__FERNET_KEY \
    AIRFLOW__CORE__LOAD_EXAMPLES \
    AIRFLOW__CORE__SQL_ALCHEMY_CONN \

if [[ -z "$AIRFLOW__CORE__LOAD_EXAMPLES" && "${LOAD_EX:=n}" == n ]]
then
    AIRFLOW__CORE__LOAD_EXAMPLES=False
fi

wait_for_port() {
    local name="$1" host="$2" port="$3"
    local j=0
    while ! nc -z "$host" "$port" > /dev/null 2>&1 < /dev/null; do
        j=$((j+1))
        if [ $j -ge 20 ]; then
            echo >&2 "$host:$port still not reachable"
            exit 1
        fi
        echo "waiting for $name... $j/20"
        sleep 5
    done
}

AIRFLOW__CORE__SQL_ALCHEMY_CONN="postgresql+psycopg2://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB"
AIRFLOW__CELERY__RESULT_BACKEND="db+postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB"
wait_for_port "Postgres" "$POSTGRES_HOST" "$POSTGRES_PORT"

case "$1" in
    webserver)
        airflow initdb
        airflow scheduler &
        exec airflow webserver
        ;;
    *)
        exec "$@"
        ;;
esac
