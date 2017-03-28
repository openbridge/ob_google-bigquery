/*
START_DATE = DATE_ADD(CURRENT_DATE(), INTERVAL -31 DAY)
END_DATE = DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)

The table name construct should look like this "match_table_campaigns_{{GOOGLE_DOUBLECLICK_ID}}"
*/
SELECT Campaign, Campaign_ID, Date FROM (
SELECT Campaign, Campaign_ID FROM `{{GOOGLE_CLOUDSDK_CORE_PROJECT}}:{{GOOGLE_BIGQUERY_JOB_DATASET}}.{{GOOGLE_BIGQUERY_TABLE}}`
  WHERE _DATA_DATE = _LATEST_DATE
), (
SELECT date AS Date
  FROM `bigquery-public-data.common_us.date_greg`
  WHERE Date BETWEEN '{{QDATE}}' AND '{{QDATE}}'
)
ORDER BY
  Campaign_ID, Date
