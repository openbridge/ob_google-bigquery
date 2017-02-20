#!/usr/bin/env bash

insertcron () {
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

if test -n "${GOOGLE_CLOUDSDK_ACCOUNT}"; then echo "${GOOGLE_CLOUDSDK_ACCOUNT}" >> /cron/auth.base64 base64 -d /cron/auth.base64 >> /cron/auth.json && gcloud auth activate-service-account --key-file=/cron/auth.json "${GOOGLE_CLOUDSDK_ACCOUNT_EMAIL}"; else echo "INFO: GOOGLE_CLOUDSDK_ACCOUNT is not being used. Checking if GOOGLE_CLOUDSDK_ACCOUNT_FILE is present..."; fi

if test -n "${GOOGLE_CLOUDSDK_ACCOUNT_FILE}"; then echo "OK: GOOGLE_CLOUDSDK_ACCOUNT_FILE is present. Authenticating with ${GOOGLE_CLOUDSDK_ACCOUNT_FILE}..." && gcloud auth activate-service-account --key-file="${GOOGLE_CLOUDSDK_ACCOUNT_FILE}" "${GOOGLE_CLOUDSDK_ACCOUNT_EMAIL}"; else echo "INFO: GOOGLE_CLOUDSDK_ACCOUNT_FILE not present. Assuming use of --volumes-from gcloud-config ..."; fi

if test -n "${GOOGLE_CLOUDSDK_CRON}"; then echo "OK: GOOGLE_CLOUDSDK_CRON is present. Setting up CROND..." && echo "${GOOGLE_CLOUDSDK_CRON}" >> /cron/cron.base64 && base64 -d /cron/cron.base64 >> /cron/crontab.conf && insertcron; else echo "INFO: There is no GOOGLE_CLOUDSDK_CRON that was passed. Checking for GOOGLE_CLOUDSDK_CRONFILE..."; fi

if test -n "${GOOGLE_CLOUDSDK_CRONFILE}"; then echo "OK: GOOGLE_CLOUDSDK_CRONFILE is present. Configuring crontab with settings in ${GOOGLE_CLOUDSDK_CRONFILE}..." && if [[ ! -d /cron ]]; then mkdir -p /cron; fi && cp "${GOOGLE_CLOUDSDK_CRONFILE}" /cron/crontab.conf && insertcron; else echo "INFO: There is no GOOGLE_CLOUDSDK_CRONFILE present. Skipping use of CRON"; fi

log_command=""
if test -n "${LOG_FILE}"; then log_command=" 2>&1 | tee -a "${LOG_FILE}; fi

if test "${1}" = 'cron'; then echo "OK: The command ${1} has been set. Starting the container with ${1} running now..." && runcrond="crond -f" && bash -c "${runcrond}"; else echo "INFO: Running the command ${1} ..."; fi

exec "$@"
