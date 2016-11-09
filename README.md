

# Google Cloud SDK Docker Container

This Docker container is meant to simplify running Google Cloud operations. It was originally created to perform "cloud-to-cloud" operations like sync files to Amazon S3. However, you can run any commands supported by the SDK via the container.

The container is based on the following:<br>
**Operating System:** Alpine `Latest:3.4`<br>
**Google SDK Version:** `133.0.0`

### Step 1: Getting Started = Setup Google Account
This container assumes you already have a Google Cloud account setup. Do not have a Google Cloud account? Set one up [here](https://cloud.google.com/).

### Step 2: Create Your Google Cloud Project
Now that you have a Google Cloud account the next step is setting up a project. If you are not sure how, check out the [documentation](https://developers.google.com/console/help/new/#creatingdeletingprojects).

### Step 3: Activate Google Cloud APIs
With your project setup you will need to activate APIs on that project. The API's are how the Google Cloud SDK perform operations on your behalf.

For details on how to do this, the Google [documentation](https://developers.google.com/console/help/new/#activating-and-deactivating-apis) describes the process for activating APIs.

### Step 4: Google Cloud Authentication

The preferred method of authentication is using
a Google Cloud OAuth Service Account file. Without the account file you will not get far as access will be denied. The Google Service Account Authentication [documentation](https://cloud.google.com/storage/docs/authentication?hl=en#service_accounts) details how to generate the file.

### Step 5: Setting Up Your Google SDK Container Environment

Now that you have everything setup @ Google you need to configure your container. The container leverages environment variables and expects an environment file will be used to set them. While you can bypass use the environment file, most of the documentation will assume you are choosing that approach.

The environment file contains all the variables needed to run the container. The sample file is located here: `./env/gcloud-sample.env`

Here is the sample environment file:

```
CLOUDSDK_ACCOUNT_FILE=/auth.json
CLOUDSDK_ACCOUNT_EMAIL=foo@appspot.gserviceaccount.com
CLOUDSDK_CRONFILE=/crontab.conf
CLOUDSDK_CORE_PROJECT=foo-casing-779217
CLOUDSDK_COMPUTE_ZONE=us-east1-b
CLOUDSDK_COMPUTE_REGION=us-east1
BIGQUERY_SQL=ga360master
BIGQUERY_GA_DATASET=1999957242
AWS_ACCESS_KEY_ID=QWWQWQWLYC2NDIMQA
AWS_SECRET_ACCESS_KEY=WQWWQqaad2+tyX0PWQQWQQQsdBsdur8Tu
GSBUCKET=openbridge-buzz
S3BUCKET=bucketname/path/to/dir
LOG_FILE=/tmp/gcloud.log

# These are not used, but could be
# CLOUDSDK_ACCOUNT=$(base64 auth.json)
# CLOUDSDK_CRON=$(base64 crontab.txt)
```

Those environment variables marked as required need to be included on all requests.

#### AWS Credentials
You will notice the use of AWS credentials in addition to Google ones. The AWS creds are present to support "cloud-to-cloud" transactions. For example, <code>/cron/crontab.conf</code> shows automated file transfers from Google Cloud drive to Amazon S3.

### Cron Scheduling

This container can run gcloud operations using cron. The use of CROND is the default configuration in `docker-compose.yml`. It has the following set: `command: cron`. This informs the container to run the `crond` service in the background. With `crond` running anything set in `crontab` will get executed. A working example crontab can be found here: <code>/cron/crontab.conf</code>

Please note that when using cron to trigger operations environment variables may need to
to be configured inside the crontab config file. This is handled by  <code>docker-entrypoint.sh</code>

Also, if you want to include your own crontab files, then you may need to adjust the <code>docker-entrypoint.sh</code> to reflect the proper configs into <code>/cron/crontab.conf</code>

## Running Your Google Cloud SDK Container

### Docker: Using Compose
The simplest way to run the container is:
```
docker-compose up -d
```
This assumes you have configured everything in `./env/gcloud-sample.env` and have made any customizations you needed to `docker-compose.yml`

You can get fairly sophisticated with your compose configs. The included `docker-compose.yml` is a starting point. Take a look at the Docker Compose
[documentation](https://docs.docker.com/compose/compose-file/) for a more indepth look at what is possible.

### Docker: Using Run Commands

This example includes AWS credentials:
```
docker run -it --restart=always --rm \
    -e "CLOUDSDK_ACCOUNT_FILE=/auth.json " \
    -e "CLOUDSDK_ACCOUNT_EMAIL=foo@appspot.gserviceaccount.com" \
    -e "CLOUDSDK_CRONFILE=/cron/crontab.conf" \
    -e "CLOUDSDK_CORE_PROJECT=foo-casing-139217" \
    -e "CLOUDSDK_COMPUTE_ZONE=europe-west1-b" \
    -e "CLOUDSDK_COMPUTE_REGION=europe-west1" \
    -e "BIGQUERY_SQL=ga360master \
    -e "BIGQUERY_GA_DATASET=123456789" \
    -e "AWS_ACCESS_KEY_ID=12ASASKSALSJLAS" \
    -e "AWS_SECRET_ACCESS_KEY=ASASAKEWPOIEWOPIEPOWEIPWE" \
    -e "GSBUCKET=openbridge-foo" \
    -e "S3BUCKET=foo/ebs/buzz/foo/google/google_analytics/ga-table" \
    -e "LOG_FILE=/ebs/logs/gcloud.log \
    openbridge/gcloud \
    gsutil rsync -d -r gs://{{GSBUCKET}}/ s3://{{S3BUCKET}}/

```
Here is another example of running an operation to list the Google Cloud instances running in a project:

```
docker run -it --rm \
    -e "CLOUDSDK_ACCOUNT_FILE=/auth.json" \
    -e "CLOUDSDK_ACCOUNT_EMAIL=CLOUDSDK_ACCOUNT_EMAIL=foo@appspot.gserviceaccount.com" \
    -e "CLOUDSDK_CORE_PROJECT=foo-casing-139217 \
    openbridge/gcloud \
    gcloud compute instances list
```

To see a list of available `gcloud` commands:
```bash
docker run -it --rm --env-file ./env/prod.env -v /Users/bob/github/ob_google-cloud-sdk/prod.json:/auth.json gcloud gcloud -h
```

```bash
docker run -it --rm --env-file ./env/prod.env -v /Users/bob/github/ob_google-cloud-sdk/auth/prod.json:/auth.json -v /Users/bob/github/ob_google-cloud-sdk/cron/crontab.conf:/crontab.conf gcloud bq ls -n 1000 hasbro-casing-139217:127357242
```
# Docker Run
Also included is a simple shell script `RUN.sh` to run the container. You may need to tweak this to fit your environment/setup.

## Reference Commands
He are some manual cleanup commands

### Examples

Run by setting the name, start and end dates. Examples:
```bash
/usr/bin/env bash /query.sh <sql> <project> <dataset> <start date> <end date>
```
```bash
/usr/bin/env bash /query.sh ga360master foo-casing-539217 827858240 2016-10-21 2016-10-21
```

Remove BQ dataset:
 ```bash
bq rm -r -f "${BIGQUERY_WD_DATASET}"
```
Remove gzip files from Cloud Storage
```bash
gsutil rm gs://"${GSBUCKET}"/"${GSPATH}"/"${BIGQUERY_SQL}"/"${FILEDATE}"_"${BIGQUERY_SQL}"_*.gz
```
Remove all files from Cloud Storage
```bash
gsutil -m rm -f -r gs://"${GSBUCKET}"/**
```
Remove remove tables that match a pattern from BQ
```bash
for i in $(bq ls -n 9999 ${CLOUDSDK_CORE_PROJECT} | grep "<pattern>" | awk '{print $1}'); do bq rm -ft ${CLOUDSDK_CORE_PROJECT}."${i}"; done
```
Generate list of tables from BQ. Check if any tables exist that match a pattern. If yes, 0=yes a match and 1=no match
```bash
BQTABLECHECK=$(bq ls -n 1000 "${CLOUDSDK_CORE_PROJECT}":"${BIGQUERY_WD_DATASET}" > ${CLOUDSDK_CORE_PROJECT}"_"${BIGQUERY_WD_DATASET}.txt && grep -q "${FILEDATE}_${BIGQUERY_SQL}" ${CLOUDSDK_CORE_PROJECT}"_"${BIGQUERY_WD_DATASET}.txt && echo "0" || echo "1")
```
Generate list of tables from BQ. Check if any tables exist that match a date pattern pattern. If yes, 0=yes a match and 1=no match
```bash
GASESSIONSCHECK=$(bq ls -n 1000 "${CLOUDSDK_CORE_PROJECT}":"${BIGQUERY_GA_DATASET}" > check_ga_sessions.txt && grep -q "ga_sessions_${FDATE}" check_ga_sessions.txt && echo "0" || echo "1")
```
