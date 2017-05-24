#!/usr/bin/env bash

google-cloud-cron () {

    sed -i 's|{{GOOGLE_CLOUDSDK_CORE_PROJECT}}|'"${GOOGLE_CLOUDSDK_CORE_PROJECT}"'|g' /cron/crontab.conf
    sed -i 's|{{GOOGLE_CLOUDSDK_COMPUTE_ZONE}}|'"${GOOGLE_CLOUDSDK_COMPUTE_ZONE}"'|g' /cron/crontab.conf
    sed -i 's|{{GOOGLE_CLOUDSDK_COMPUTE_REGION}}|'"${GOOGLE_CLOUDSDK_COMPUTE_REGION}"'|g' /cron/crontab.conf
    sed -i 's|{{GOOGLE_STORAGE_BUCKET}}|'"${GOOGLE_STORAGE_BUCKET}"'|g' /cron/crontab.conf
    sed -i 's|{{GOOGLE_STORAGE_PATH}}|'"${GOOGLE_STORAGE_PATH}"'|g' /cron/crontab.conf
    sed -i 's|{{AWS_ACCESS_KEY_ID}}|'"${AWS_ACCESS_KEY_ID}"'|g' /cron/crontab.conf
    sed -i 's|{{AWS_SECRET_ACCESS_KEY}}|'"${AWS_SECRET_ACCESS_KEY}"'|g' /cron/crontab.conf
    sed -i 's|{{AWS_S3_BUCKET}}|'"${AWS_S3_BUCKET}"'|g' /cron/crontab.conf
    cat /cron/crontab.conf | crontab -
    crontab -l

}

    if [[ ! -d /cron ]]; then mkdir -p /cron; fi

    if test -n "${GOOGLE_CLOUDSDK_CORE_PROJECT}"; then gcloud config set project ${GOOGLE_CLOUDSDK_CORE_PROJECT} && echo "OK: GOOGLE_CLOUDSDK_CORE_PROJECT has been set to ${GOOGLE_CLOUDSDK_CORE_PROJECT}"; else echo "INFO: GOOGLE_CLOUDSDK_CORE_PROJECT is not being used. This will likely create issues if it is not present"; fi
    if test -n "${GOOGLE_CLOUDSDK_ACCOUNT}"; then echo "${GOOGLE_CLOUDSDK_ACCOUNT}" >> /cron/auth.base64 base64 -d /cron/auth.base64 >> /cron/auth.json && gcloud auth activate-service-account --key-file=/cron/auth.json "${GOOGLE_CLOUDSDK_ACCOUNT_EMAIL}"; else echo "INFO: GOOGLE_CLOUDSDK_ACCOUNT is not being used. Checking if GOOGLE_CLOUDSDK_ACCOUNT_FILE is present..."; fi
    if test -n "${GOOGLE_CLOUDSDK_ACCOUNT_FILE}"; then echo "OK: GOOGLE_CLOUDSDK_ACCOUNT_FILE is present. Authenticating with ${GOOGLE_CLOUDSDK_ACCOUNT_FILE}..." && gcloud auth activate-service-account --key-file="${GOOGLE_CLOUDSDK_ACCOUNT_FILE}" "${GOOGLE_CLOUDSDK_ACCOUNT_EMAIL}"; else echo "INFO: GOOGLE_CLOUDSDK_ACCOUNT_FILE not present. Assuming use of --volumes-from gcloud-config ..."; fi
    if test -n "${GOOGLE_CLOUDSDK_CRON}"; then echo "OK: GOOGLE_CLOUDSDK_CRON is present. Setting up CROND..." && echo "${GOOGLE_CLOUDSDK_CRON}" >> /cron/cron.base64 && base64 -d /cron/cron.base64 >> /cron/crontab.conf && google-cloud-cron; else echo "INFO: There is no GOOGLE_CLOUDSDK_CRON that was passed. Checking for GOOGLE_CLOUDSDK_CRONFILE..."; fi
    if test -n "${GOOGLE_CLOUDSDK_CRONFILE}"; then echo "OK: GOOGLE_CLOUDSDK_CRONFILE is present. Configuring crontab with settings in ${GOOGLE_CLOUDSDK_CRONFILE}..." && cp "${GOOGLE_CLOUDSDK_CRONFILE}" /cron/crontab.conf && google-cloud-cron; else echo "INFO: There is no GOOGLE_CLOUDSDK_CRONFILE present. Skipping use of CRON"; fi

    # Creating working directory for the various queries. Assumes SQL is located /sql
    find /sql -name '*.sql' -exec sh -c 'mkdir -p /tmp/sql && cp "$@" /tmp/sql' _ {} +

    # Google BigQuery source details
    if [[ -n $GOOGLE_BIGQUERY_SQL ]]; then find /tmp/sql/ -maxdepth 5 -type f -exec sed -i -e 's|{{GOOGLE_BIGQUERY_SQL}}|'"${GOOGLE_BIGQUERY_SQL}"'|g' {} \;; fi
    if [[ -n $GOOGLE_BIGQUERY_JOB_DATASET ]]; then find /tmp/sql/ -maxdepth 5 -type f -exec sed -i -e 's|{{GOOGLE_BIGQUERY_JOB_DATASET}}|'"${GOOGLE_BIGQUERY_JOB_DATASET}"'|g' {} \;; fi
    if [[ -n $GOOGLE_BIGQUERY_TABLE ]]; then find /tmp/sql/ -maxdepth 5 -type f -exec sed -i -e 's|{{GOOGLE_BIGQUERY_TABLE}}|'"${GOOGLE_BIGQUERY_TABLE}"'|g' {} \;; fi

    # Google cloud storage details
    if [[ -n $GOOGLE_STORAGE_BUCKET ]]; then find /tmp/sql/ -maxdepth 5 -type f -exec sed -i -e 's|{{GOOGLE_STORAGE_BUCKET}}|'"${GOOGLE_STORAGE_BUCKET}"'|g' {} \;; fi
    if [[ -n $GOOGLE_STORAGE_PATH ]]; then find /tmp/sql/ -maxdepth 5 -type f -exec sed -i -e 's|{{GOOGLE_STORAGE_PATH}}|'"${GOOGLE_STORAGE_PATH}"'|g' {} \;; fi

    # Google service source details
    if [[ -n $GOOGLE_DOUBLECLICK_ID ]]; then find /tmp/sql/ -maxdepth 5 -type f -exec sed -i -e 's|{{GOOGLE_DOUBLECLICK_ID}}|'"${GOOGLE_DOUBLECLICK_ID}"'|g' {} \;; fi
    if [[ -n $GOOGLE_DOUBLECLICK_NETWORK_CODE ]]; then find /tmp/sql/ -maxdepth 5 -type f -exec sed -i -e 's|{{GOOGLE_DOUBLECLICK_NETWORK_CODE}}|'"${GOOGLE_DOUBLECLICK_NETWORK_CODE}"'|g' {} \;; fi
    if [[ -n $GOOGLE_ADWORDS_CUSTOMER_ID ]]; then find /tmp/sql/ -maxdepth 5 -type f -exec sed -i -e 's|{{GOOGLE_ADWORDS_CUSTOMER_ID}}|'"${GOOGLE_ADWORDS_CUSTOMER_ID}"'|g' {} \;; fi

    # Amazon destination details
    if [[ -n $AWS_S3_BUCKET ]]; then find /tmp/sql/ -maxdepth 5 -type f -exec sed -i -e 's|{{AWS_S3_BUCKET}}|'"${AWS_S3_BUCKET}"'|g' {} \;; fi
    if [[ -n $AWS_ACCESS_KEY_ID ]]; then find /tmp/sql/ -maxdepth 5 -type f -exec sed -i -e 's|{{AWS_ACCESS_KEY_ID}}|'"${AWS_ACCESS_KEY_ID}"'|g' {} \;; fi
    if [[ -n $AWS_SECRET_ACCESS_KEY ]]; then find /tmp/sql/ -maxdepth 5 -type f -exec sed -i -e 's|{{AWS_SECRET_ACCESS_KEY}}|'"${AWS_SECRET_ACCESS_KEY}"'|g' {} \;; fi

log_command=""
if test -n "${LOG_FILE}"; then log_command=" 2>&1 | tee -a "${LOG_FILE}; fi

if test "${1}" = 'cron'; then echo "OK: The command ${1} has been set. Starting the container with ${1} running now..." && runcrond="crond -f" && bash -c "${runcrond}"; else echo "INFO: Running the command ${1} ..."; fi

exec "$@"
