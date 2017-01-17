![Google](https://github.com/openbridge/ob_google-cloud/blob/develop-temp/images/google.png)

# Google Cloud SDK+ Docker Container
- [Overview](#overview)
- [Get Your Google Account](#get-your-google-account)
  - [Step 1: Getting Started = Setup Google Account](#step-1-getting-started-setup-google-account)
  - [Step 2: Create Your Google Cloud Project](#step-2-create-your-google-cloud-project)
  - [Step 3: Activate Google Cloud APIs](#step-3-activate-google-cloud-apis)
  - [Step 4: Google Cloud Authentication](#step-4-google-cloud-authentication)
    - [Setup Docker Authentication Volume](#setup-docker-authentication-volume)
    - [Using Authentication Volume](#using-authentication-volume)
    - [Setup Local Authentication File](#setup-local-authentication-file)
  - [Step 5: Complete!](#step-5-complete)
- [Running BigQuery Export Operations](#running-bigquery-export-operations)
  - [Environment File = BigQuery Jobs](#environment-file-bigquery-jobs)
  - [AWS Credentials](#aws-credentials)
- [Running Your Container](#running-your-container)
  - [Run Google Cloud SDK As Daemon](#run-google-cloud-sdk-as-daemon)
    - [Example: Docker Compose](#example-docker-compose)
  - [Ephemeral Google Cloud SDK Service](#ephemeral-google-cloud-sdk-service)
- [Docker Run](#docker-run)
- [Example Commands](#example-commands)
- [Issues](#issues)
- [Contributing](#contributing)

## Overview

This Docker container is meant to simplify running Google Cloud operations. It was originally created to perform "cloud-to-cloud" operations like sync files to Amazon S3\. However, you can run any commands supported by the SDK via the container.

The container is based on the following:<br>
**Operating System:** Alpine `Latest:3.5`<br>
**Google SDK Version:** `139.0.1`

# Get Your Google Account

## Step 1: Getting Started = Setup Google Account

This container assumes you already have a Google Cloud account setup. Do not have a Google Cloud account? Set one up [here](https://cloud.google.com/).

## Step 2: Create Your Google Cloud Project

Now that you have a Google Cloud account the next step is setting up a project. If you are not sure how, check out the [documentation](https://developers.google.com/console/help/new/#creatingdeletingprojects). If you already have a project setup, take note of the ID.

## Step 3: Activate Google Cloud APIs

With your project setup you will need to activate APIs on that project. The API's are how the Google Cloud SDK perform operations on your behalf.

For details on how to do this, the Google [documentation](https://developers.google.com/console/help/new/#activating-and-deactivating-apis) describes the process for activating APIs.

## Step 4: Google Cloud Authentication

The preferred methods of authentication is using a Google Cloud OAuth Service Account docker volume or auth file. Without the account volume or file you will not get far as access will be denied. The Google Service Account Authentication [documentation](https://cloud.google.com/storage/docs/authentication?hl=en#service_accounts) details how to generate the file.

### Setup Docker Authentication Volume

Follow these instructions if you are running docker _outside_ of Google Compute Engine:

```bash
docker run -t -i --name gcloud-config openbridge/google-cloud gcloud init
```

If you would like to use service account instead please look here:

```bash
docker run -t -i --name gcloud-config openbridge/google-cloud gcloud auth activate-service-account <your-service-account-email> --key-file /tmp/your-key.p12 --project <your-project-id>
```

### Using Authentication Volume

Re-use the credentials from gcloud-config volumes & run sdk commands:

```bash
    docker run --rm -ti --volumes-from gcloud-config openbridge/google-cloud gcloud info
    docker run --rm -ti --volumes-from gcloud-config openbridge/google-cloud gsutil ls
```

If you are using this image from _within_ [Google Compute Engine](https://cloud.google.com/compute/). If you enable a Service Account with the necessary scopes, there is no need to auth or use a config volume:

```bash
  docker run --rm -ti openbridge/google-cloud gcloud info
  docker run --rm -ti openbridge/google-cloud gsutil ls
```

### Setup Local Authentication File

If you do not want to use a Docker volume, you can also use a auth file. There is a sample auth file here: `samples/auth-sample.json`.

Once the file is complete, place it into the `./auth` directory within the project. The next step is to reference the path to your authentication file in the `.env` file. This is done by setting the path for the variable `GOOGLE_CLOUDSDK_ACCOUNT_FILE=`.

For example, if you name your auth file `creds.json` you would set the config to`GOOGLE_CLOUDSDK_ACCOUNT_FILE=/creds.json`. This sets the path to the creds file in the root of the container.

To use your authentication file, you need to mount it within the container in the same location as specified in your `.env` file:

```bash
docker run -it -v /Users/bob/Documents/github/ob_google-cloud/auth/creds.json:/creds.json -v /Users/thomas/Documents/github/ob_google-cloud/sql:/sql --env-file ${i} openbridge/google-cloud gcloud info"
```

## Step 5: Complete!

# Running BigQuery Export Operations

The container is designed to be able to perform BigQuery export operations. It leverages the .sql files stored in `./sql/*` to run a query and then export the results of that data to Google Cloud storage and, if needed, to Amazon S3.

Now that you have everything setup @ Google you need to configure your container. Earlier an `.env` was referenced as a method to use a local authentication file. The container leverages environment variables and expects an environment file will be used to set them. While you can bypass use the environment file, most of the documentation will assume you are choosing this approach.

The environment file contains all the variables needed to run the container. The sample file is located here: `./samples/bigquery.env`. Here is the sample environment file:

## Environment File = BigQuery Jobs

```bash
GOOGLE_CLOUDSDK_ACCOUNT_FILE=/auth.json
GOOGLE_CLOUDSDK_ACCOUNT_EMAIL=foo@appspot.gserviceaccount.com
GOOGLE_CLOUDSDK_CRONFILE=/crontab.conf
GOOGLE_CLOUDSDK_CORE_PROJECT=foo-casing-779217
GOOGLE_CLOUDSDK_COMPUTE_ZONE=us-east1-b
GOOGLE_CLOUDSDK_COMPUTE_REGION=us-east1
GOOGLE_GOOGLE_BIGQUERY_SQL=ga360master
GOOGLE_BIGQUERY_JOB_DATASET=1999957242
GOOGLE_STORAGE_BUCKET=openbridge-buzz
AWS_ACCESS_KEY_ID=QWWQWQWLYC2NDIMQA
AWS_SECRET_ACCESS_KEY=WQWWQqaad2+tyX0PWQQWQQQsdBsdur8Tu
AWS_S3_BUCKET=bucketname/path/to/dir
LOG_FILE=/tmp/gcloud.log

 These are not used, but could be
 GOOGLE_CLOUDSDK_ACCOUNT=$(base64 auth.json)
 GOOGLE_CLOUDSDK_CRON=$(base64 crontab.txt)
```

Those environment variables marked as required need to be included on all requests.

## AWS Credentials

You will notice the use of AWS credentials in addition to Google ones. The AWS creds are present to support "cloud-to-cloud" transactions. For example, `/cron/crontab.conf` shows automated file transfers from Google Cloud drive to Amazon S3.

# Running Your Container

## Run Google Cloud SDK As Daemon

This container can run gcloud operations using cron. The use of CROND is the default configuration in `docker-compose.yml`. It has the following set: `command: cron`. This informs the container to run the `crond` service in the background. With `crond` running anything set in `crontab` will get executed. A working example crontab can be found here: `/cron/crontab.conf`

Please note that when using cron to trigger operations environment variables may need to to be configured inside the crontab config file. This is handled by `docker-entrypoint.sh`

Also, if you want to include your own crontab files, then you may need to adjust the `docker-entrypoint.sh` to reflect the proper configs into `/cron/crontab.conf`

```bash
SHELL=/bin/bash
PATH=/google-cloud-sdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
GOOGLE_CLOUDSDK_CORE_PROJECT={{GOOGLE_CLOUDSDK_CORE_PROJECT}}
GOOGLE_CLOUDSDK_COMPUTE_ZONE={{GOOGLE_CLOUDSDK_COMPUTE_ZONE}}
GOOGLE_CLOUDSDK_COMPUTE_REGION={{GOOGLE_CLOUDSDK_COMPUTE_REGION}}
AWS_ACCESS_KEY_ID={{AWS_ACCESS_KEY_ID}}
AWS_SECRET_ACCESS_KEY={{AWS_SECRET_ACCESS_KEY}}
AWS_S3_BUCKET={{AWS_S3_BUCKET}}
GOOGLE_STORAGE_BUCKET={{GOOGLE_STORAGE_BUCKET}}
05 13,14,15,16,17,18 * * * /usr/bin/env bash -c 'bigquery-run prod' >> /tmp/query.log 2>&1
45 12 * * * echo "RUN" > /tmp/runjob.txt
```

### Example: Docker Compose

The simplest way to run the container is:

```bash
docker-compose up -d
```

This assumes you have configured everything in `./env/gcloud-sample.env` and have made any customizations you needed to `docker-compose.yml`

You can get fairly sophisticated with your compose configs. The included `docker-compose.yml` is a starting point. Take a look at the Docker Compose [documentation](https://docs.docker.com/compose/compose-file/) for a more indepth look at what is possible.

## Ephemeral Google Cloud SDK Service

```bash
/usr/bin/env bash -c 'bigquery-run prod'
```

This example includes AWS credentials:

```bash
docker run -it --restart=always --rm \
    -e "GOOGLE_CLOUDSDK_ACCOUNT_FILE=/auth.json " \
    -e "GOOGLE_CLOUDSDK_ACCOUNT_EMAIL=foo@appspot.gserviceaccount.com" \
    -e "GOOGLE_CLOUDSDK_CRONFILE=/cron/crontab.conf" \
    -e "GOOGLE_CLOUDSDK_CORE_PROJECT=foo-casing-139217" \
    -e "GOOGLE_CLOUDSDK_COMPUTE_ZONE=europe-west1-b" \
    -e "GOOGLE_CLOUDSDK_COMPUTE_REGION=europe-west1" \
    -e "GOOGLE_GOOGLE_BIGQUERY_SQL=ga360master" \
    -e "GOOGLE_BIGQUERY_JOB_DATASET=123456789" \
    -e "AWS_ACCESS_KEY_ID=12ASASKSALSJLAS" \
    -e "AWS_SECRET_ACCESS_KEY=ASASAKEWPOIEWOPIEPOWEIPWE" \
    -e "GOOGLE_STORAGE_BUCKET=openbridge-foo" \
    -e "AWS_S3_BUCKET=foo/ebs/buzz/foo/google/google_analytics/ga-table" \
    -e "LOG_FILE=/ebs/logs/gcloud.log" \
    openbridge/gcloud \
    gsutil rsync -d -r gs://{{GOOGLE_STORAGE_BUCKET}}/ s3://{{AWS_S3_BUCKET}}/
```

Here is another example of running an operation to list the Google Cloud instances running in a project:

```bash
docker run -it --rm \
    -e "GOOGLE_CLOUDSDK_ACCOUNT_FILE=/auth.json" \
    -e "GOOGLE_CLOUDSDK_ACCOUNT_EMAIL=GOOGLE_CLOUDSDK_ACCOUNT_EMAIL=foo@appspot.gserviceaccount.com" \
    -e "GOOGLE_CLOUDSDK_CORE_PROJECT=foo-casing-139217" \
    openbridge/gcloud \
    gcloud compute instances list
```

To see a list of available `gcloud` commands:

```bash
docker run -it --rm --env-file ./env/prod.env -v /Users/thomas/github/ob_google-cloud/auth/prod.json:/auth.json openbridge/google-cloud gcloud -h
```

```bash
docker run -it --rm --env-file ./env/prod.env -v /Users/bob/github/ob_google-cloud-sdk/auth/prod.json:/auth.json -v /Users/bob/github/ob_google-cloud-sdk/cron/crontab.conf:/crontab.conf gcloud bq ls -n 1000 hasbro-casing-139217:127357242
```

# Docker Run

Also included is a simple shell script `RUN.sh` to run the container. You may need to tweak this to fit your environment/setup.

# Example Commands

Run by setting the name, start and end dates:

```bash
/usr/bin/env bash -c 'bigquery-export <sql> <project> <dataset> <start date> <end date>'
```

```bash
/usr/bin/env bash -c 'bigquery-export ga360 foo-casing-539217 827858240 2016-10-21 2016-10-21'
```

Remove BQ dataset:

```bash
bq rm -r -f "${GOOGLE_BIGQUERY_WD_DATASET}"
```

Remove gzip files from Cloud Storage

```bash
docker run --rm -ti --volumes-from gcloud-config openbridge/google-cloud gsutil rm gs://"${GOOGLE_STORAGE_BUCKET}"/"${GOOGLE_STORAGE_PATH}"/"${GOOGLE_GOOGLE_BIGQUERY_SQL}"/"${FILEDATE}"_"${GOOGLE_GOOGLE_BIGQUERY_SQL}"_*.gz
```

Remove all files from Cloud Storage

```bash
docker run --rm -ti --volumes-from gcloud-config openbridge/google-cloud gsutil -m rm -f -r gs://"${GOOGLE_STORAGE_BUCKET}"/**
```

Remove remove tables that match a pattern from BQ

```bash
docker run --rm -ti --volumes-from gcloud-config openbridge/google-cloud bash
```

The at the command prompt:

```bash
for i in $(bq ls -n 9999 ${GOOGLE_CLOUDSDK_CORE_PROJECT} | grep "<pattern>" | awk '{print $1}'); do bq rm -ft ${GOOGLE_CLOUDSDK_CORE_PROJECT}."${i}"; done
```

Generate list of tables from BQ. Check if any tables exist that match a pattern. If yes, 0=yes a match and 1=no match

```bash
docker run --rm -ti --volumes-from gcloud-config openbridge/google-cloud bash
```

The at the command prompt:

```bash
BQTABLECHECK=$(bq ls -n 1000 "${GOOGLE_CLOUDSDK_CORE_PROJECT}":"${GOOGLE_BIGQUERY_WD_DATASET}" > ${GOOGLE_CLOUDSDK_CORE_PROJECT}"_"${GOOGLE_BIGQUERY_WD_DATASET}.txt && grep -q "${FILEDATE}_${GOOGLE_GOOGLE_BIGQUERY_SQL}" ${GOOGLE_CLOUDSDK_CORE_PROJECT}"_"${GOOGLE_BIGQUERY_WD_DATASET}.txt && echo "0" || echo "1")
```

Generate list of tables from BQ. Check if any tables exist that match a date pattern pattern. If yes, 0=yes a match and 1=no match

```bash
docker run --rm -ti --volumes-from gcloud-config openbridge/google-cloud bash
```

The at the command prompt:

```bash
GASESSIONSCHECK=$(bq ls -n 1000 "${GOOGLE_CLOUDSDK_CORE_PROJECT}":"${GOOGLE_BIGQUERY_JOB_DATASET}" > check_ga_sessions.txt && grep -q "ga_sessions_${FDATE}" check_ga_sessions.txt && echo "0" || echo "1")
`
```

# Issues

If you have any problems with or questions about this image, please contact us through a GitHub issue.

# Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

Before you start to code, we recommend discussing your plans through a GitHub issue, especially for more ambitious contributions. This gives other contributors a chance to point you in the right direction, give you feedback on your design, and help you find out if someone else is working on the same thing.
