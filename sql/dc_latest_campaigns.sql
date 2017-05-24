/*
The table name construct should look like this "match_table_campaigns_{{GOOGLE_DOUBLECLICK_ID}}"
*/

SELECT Campaign, Campaign_ID FROM `{{GOOGLE_CLOUDSDK_CORE_PROJECT}}:{{GOOGLE_BIGQUERY_JOB_DATASET}}.{{GOOGLE_BIGQUERY_TABLE}}`
WHERE _DATA_DATE = _LATEST_DATE
