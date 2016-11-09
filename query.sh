#!/usr/bin/env bash
set -x

# Google Settings
if [[ -z ${1} ]]; then echo "OK: BIGQUERY SQL was not passed. Using container default"; else BIGQUERY_SQL=${1}; fi
if [[ -z ${2} ]]; then echo "OK: CLOUDSDK PROJECT was not passed. Using container default"; else CLOUDSDK_CORE_PROJECT=${2}; fi
if [[ -z ${3} ]]; then echo "OK: BIGQUERY DATASET was not passed. Using container default"; else BIGQUERY_GA_DATASET=${3}; fi

# Set the dates
DATE=$(date +"%Y%m%d")
DSTART=${4}
DEND=${5}
START=$(date -d${DSTART} +%s)
END=$(date -d${DEND} +%s)
CUR=${START}

# Check if the process should run or not.
if [[ -f "/tmp/runjob.txt" ]]; then echo "OK: Time to run the GA360 export process..."; else echo "INFO: No GA360 export job is present. Exit" && exit 1; fi

while [[ ${CUR} -le ${END} ]]; do

  #Set date to proper BQ query format for SQL
  QDATE=$(date -d@${CUR} +%Y-%m-%d)
  FDATE=$(date -d@${CUR} +%Y%m%d)
  let CUR+=24*60*60

  #Set the table and file name to the date of the data being extracted
  FID=$(cat /dev/urandom | tr -cd [:alnum:] | head -c 8)
  if test "${MODE}" = "PROD"; then FILEDATE="${FDATE}"_"${FID}" && GSPATH="production"; else FILEDATE="TESTING_${FDATE}_${FID}" && GSPATH="testing"; fi

  # Setup the working bucket to be used for exports
  gsutil mb -p "${CLOUDSDK_CORE_PROJECT}" -l us gs://"${GSBUCKET}"
  gsutil lifecycle set /lifecycle.json gs://"${GSBUCKET}"/

  # Set working dataset and make sure tables auto-expire after an hour
  BIGQUERY_WD_DATASET="${BIGQUERY_GA_DATASET}_WD"
  BIGQUERY_ARCHIVE_DATASET="${BIGQUERY_GA_DATASET}_ARCHIVE"
  bq mk --default_table_expiration 3600 "${BIGQUERY_WD_DATASET}"
  bq mk --default_table_expiration 2678400 "${BIGQUERY_ARCHIVE_DATASET}"

  #Import the query and set the required BQ variables
  BQQUERY=$(cat /"${BIGQUERY_SQL}".sql | sed "s/{{QDATE}}/${QDATE}/g; s/{{CLOUDSDK_CORE_PROJECT}}/${CLOUDSDK_CORE_PROJECT}/g; s/{{BIGQUERY_GA_DATASET}}/${BIGQUERY_GA_DATASET}/g" )

  # Check if the daily GA360 session data has been loaded by Google
  for i in $(bq ls -n 9999 "${CLOUDSDK_CORE_PROJECT}":"${BIGQUERY_GA_DATASET}" | grep "ga_sessions_${FDATE}" | awk '{print $1}'); do if test "${i}" = "ga_sessions_${FDATE}"; then GASESSIONSCHECK="0"; else GASESSIONSCHECK="1"; fi done

  if test "${GASESSIONSCHECK}" = "0"; then
     echo "OK: ga_sessions_${FDATE} table exists. Run export process..."
     bq query --batch --allow_large_results --destination_table="${BIGQUERY_WD_DATASET}"."${FILEDATE}"_"${BIGQUERY_SQL}" "${BQQUERY}"
   else
     echo "ERROR: The ga_sessions_${FDATE} data is not present yet. Cant start export process" && exit 1
  fi

  # Check if the process created the daily export table in the working job dataset
  for i in $(bq ls -n 9999 "${CLOUDSDK_CORE_PROJECT}":"${BIGQUERY_WD_DATASET}" | grep "${FILEDATE}_${BIGQUERY_SQL}" | awk '{print $1}'); do if test "${i}" = "${FILEDATE}_${BIGQUERY_SQL}"; then BQTABLECHECK="0"; else BQTABLECHECK="1"; fi done

  # We will perform a spot check to make sure that the job table in the working dataset does in fact have data present. If it does, run the export process
  if test "${BQTABLECHECK}" = "0"; then
    echo "OK: ${FILEDATE}_${BIGQUERY_SQL} table exists. Checking record counts..."
    while read -r num; do echo "${num}" && if [[ $num =~ \"num\":\"([[:digit:]]+)\" ]] && (( BASH_REMATCH[1] > 1000 )); then echo "Ok: ${FILEDATE}_${BIGQUERY_SQL} table counts meet expectations. Ready to extract data..."
    bq extract --compression=GZIP ${CLOUDSDK_CORE_PROJECT}:${BIGQUERY_WD_DATASET}.${FILEDATE}_${BIGQUERY_SQL} gs://${GSBUCKET}/${GSPATH}/${BIGQUERY_SQL}/${FILEDATE}_${BIGQUERY_SQL}_export*.gz; fi done < <(echo "SELECT COUNT(*) as num FROM [${CLOUDSDK_CORE_PROJECT}:${BIGQUERY_WD_DATASET}.${FILEDATE}_${BIGQUERY_SQL}] HAVING COUNT(*) > 100000" | bq query --format json)
  else
    echo "ERROR: The ${FILEDATE}_${BIGQUERY_SQL} table counts are too low. Exiting" && exit 1
  fi

  # Transfer to S3
  if [[ "${MODE}" = "PROD" && -n ${S3BUCKET} ]]; then
    echo "Ok: Push extracts to S3..."
    gsutil -m rsync -d -r -x "TESTING_" gs://"${GSBUCKET}"/"${GSPATH}"/"${BIGQUERY_SQL}"/ s3://"${S3BUCKET}"/
    echo "Ok: Completed S3 transfer"
  else
    echo "Ok: Running in TEST mode"
  fi

  # Make an archive of the production table
  if [[ "${MODE}" = "PROD" ]]; then
     # Make sure we dont copy test tables
     for i in $(bq ls -n 9999 "${CLOUDSDK_CORE_PROJECT}" | grep "TESTING_*" | awk '{print $1}'); do bq rm -ft "${CLOUDSDK_CORE_PROJECT}"."${i}"; done
     # Transfer to archive dataset
     bq cp "${CLOUDSDK_CORE_PROJECT}":"${BIGQUERY_WD_DATASET}"."${FILEDATE}"_"${BIGQUERY_SQL}" "${CLOUDSDK_CORE_PROJECT}":"${BIGQUERY_ARCHIVE_DATASET}"."${FILEDATE}"_"${BIGQUERY_SQL}"_ARCHIVE
  fi

done

# Everything worked. Cleanup and reset the process
if [[ -f "/tmp/runjob.txt" ]]; then echo "OK: Job is complete" && rm -f /tmp/runjob.txt; fi

exit 0
