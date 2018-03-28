/*
The following sample query analyzes the number of impressions and unique users by line item type over the past 30 days.
START_DATE = DATE_ADD(CURRENT_DATE(), INTERVAL -31 DAY)
END_DATE = DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)
The table name construct should look like this "NetworkImpressions{{GOOGLE_DOUBLECLICK_NETWORK_CODE}}"
{{QDATE}} is a variable passed at run time
*/
SELECT
  MT.LineItemType AS LineItemType,
  DT.DATA_DATE AS Date,
  count(*) AS imps,
  count(distinct UserId) AS uniq_users
FROM `{{GOOGLE_BIGQUERY_JOB_DATASET}}.{{GOOGLE_BIGQUERY_SOURCE_TABLE}}`` AS DT
LEFT JOIN `{{GOOGLE_BIGQUERY_JOB_DATASET}}.MatchTableLineItem_{{GOOGLE_DOUBLECLICK_NETWORK_CODE}}` AS MT
ON
  DT.LineItemId = MT.Id
WHERE
  DT._DATA_DATE BETWEEN '{{QDATE}}' AND '{{QDATE}}'
GROUP BY LineItemType, Date
ORDER BY Date desc, imps desc
