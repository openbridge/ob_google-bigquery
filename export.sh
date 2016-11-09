#!/usr/bin/env bash
set -x

START=$(date -d "1 day ago" "+%Y-%m-%d")
END=$(date -d "1 day ago" "+%Y-%m-%d")

if test "${1}" = "PROD"; then MODE=PROD && export MODE=${1}; else export MODE="TEST"; fi

if test -n "${CLOUDSDK_ACCOUNT_FILE}";then echo "OK: CLOUDSDK_ACCOUNT_FILE is present. Authenticating with ${CLOUDSDK_ACCOUNT_FILE}..." && gcloud auth activate-service-account --key-file="${CLOUDSDK_ACCOUNT_FILE}" "${CLOUDSDK_ACCOUNT_EMAIL}"; else echo "ERROR: CLOUDSDK_ACCOUNT_FILE not present and is required to run the Google Cloud SDK. Exiting" && exit 1;fi

echo "OK: Starting to run /query.sh ${BIGQUERY_SQL} ${CLOUDSDK_CORE_PROJECT} ${BIGQUERY_GA_DATASET} ${START} ${END}"

/usr/bin/env bash /query.sh ${BIGQUERY_SQL} ${CLOUDSDK_CORE_PROJECT} ${BIGQUERY_GA_DATASET} ${START} ${END} >> /tmp/query.log 2>&1

echo "OK: Completed running /query.sh"

exit 0
