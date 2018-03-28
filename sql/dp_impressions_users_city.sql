/*
The following sample query analyzes the number of impressions and unique users by city over the past 30 days.
START_DATE = DATE_ADD(CURRENT_DATE(), INTERVAL -31 DAY)
END_DATE = DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)

The table name construct should look like this "NetworkImpressions{{GOOGLE_DOUBLECLICK_NETWORK_CODE}}"
*/

SELECT
  City,
  DATA_DATE AS Date,
  count(*) AS imps,
  count(distinct UserId) AS uniq_users
FROM `{{GOOGLE_BIGQUERY_JOB_DATASET}}.{{GOOGLE_BIGQUERY_SOURCE_TABLE}}`
WHERE
  _DATA_DATE BETWEEN '{{QDATE}}' AND '{{QDATE}}'
GROUP BY City, Date
