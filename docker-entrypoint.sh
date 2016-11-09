#!/usr/bin/env bash

insertcron () {
    sed -i 's|{{CLOUDSDK_CORE_PROJECT}}|'"${CLOUDSDK_CORE_PROJECT}"'|g' /cron/crontab.conf
    sed -i 's|{{CLOUDSDK_COMPUTE_ZONE}}|'"${CLOUDSDK_COMPUTE_ZONE}"'|g' /cron/crontab.conf
    sed -i 's|{{CLOUDSDK_COMPUTE_REGION}}|'"${CLOUDSDK_COMPUTE_REGION}"'|g' /cron/crontab.conf
    sed -i 's|{{AWS_ACCESS_KEY_ID}}|'"${AWS_ACCESS_KEY_ID}"'|g' /cron/crontab.conf
    sed -i 's|{{AWS_SECRET_ACCESS_KEY}}|'"${AWS_SECRET_ACCESS_KEY}"'|g' /cron/crontab.conf
    sed -i 's|{{GSBUCKET}}|'"${GSBUCKET}"'|g' /cron/crontab.conf
    sed -i 's|{{GSPATH}}|'"${GSPATH}"'|g' /cron/crontab.conf
    sed -i 's|{{S3BUCKET}}|'"${S3BUCKET}"'|g' /cron/crontab.conf
    cat /cron/crontab.conf | crontab -
    crontab -l
}

if test -n "${CLOUDSDK_ACCOUNT}";then echo "${CLOUDSDK_ACCOUNT}" >> /cron/auth.base64 base64 -d /cron/auth.base64 >> /cron/auth.json && gcloud auth activate-service-account --key-file=/cron/auth.json "${CLOUDSDK_ACCOUNT_EMAIL}";else echo "INFO: CLOUDSDK_ACCOUNT is not being used. Checking if CLOUDSDK_ACCOUNT_FILE is present...";fi

if test -n "${CLOUDSDK_ACCOUNT_FILE}";then echo "OK: CLOUDSDK_ACCOUNT_FILE is present. Authenticating with ${CLOUDSDK_ACCOUNT_FILE}..." && gcloud auth activate-service-account --key-file="${CLOUDSDK_ACCOUNT_FILE}" "${CLOUDSDK_ACCOUNT_EMAIL}"; else echo "ERROR: CLOUDSDK_ACCOUNT_FILE not present and is required to run the Google Cloud SDK. Exiting" && exit 1;fi

if test -n "${CLOUDSDK_CRON}"; then echo "OK: CLOUDSDK_CRON is present. Setting up CROND..." && echo "${CLOUDSDK_CRON}" >> /cron/cron.base64 && base64 -d /cron/cron.base64 >> /cron/crontab.conf && insertcron; else echo "OK: There is no CLOUDSDK_CRON that was passed. Checking for CLOUDSDK_CRONFILE..."; fi

if test -n "${CLOUDSDK_CRONFILE}"; then echo "OK: CLOUDSDK_CRONFILE is present. Configuring crontab with settings in ${CLOUDSDK_CRONFILE}..." && if [[ ! -d /cron ]]; then mkdir -p /cron; fi && cp "${CLOUDSDK_CRONFILE}" /cron/crontab.conf && insertcron; else echo "INFO: There is no CLOUDSDK_CRONFILE present. Skipping use of CRON";fi

log_command=""
if test -n "${LOG_FILE}"; then log_command=" 2>&1 | tee -a "${LOG_FILE};fi

if test "${1}" = 'cron'; then echo "OK: The command ${1} has been set. Starting the container with ${1} running now..." && runcrond="crond -f" && bash -c "${runcrond}"; else echo "INFO: Running the command ${1} ..."; fi

exec "$@"
