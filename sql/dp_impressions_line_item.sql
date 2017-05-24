/*
The following sample query analyzes the number of impressions by line item over the past 30 days.
START_DATE = DATE_ADD(CURRENT_DATE(), INTERVAL -31 DAY)
END_DATE = DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)
The table name construct should look like this "NetworkImpressions{{GOOGLE_DOUBLECLICK_NETWORK_CODE}}"
*/
SELECT
  MT.Name AS LineItemName,
  DT.DATA_DATE AS Date,
  count(*) AS imps
FROM `{{GOOGLE_BIGQUERY_JOB_DATASET}}.{{GOOGLE_BIGQUERY_TABLE}}` AS DT
LEFT JOIN `{{GOOGLE_BIGQUERY_JOB_DATASET}}.MatchTableLineItem_{{GOOGLE_DOUBLECLICK_NETWORK_CODE}}` AS MT
ON
  DT.LineItemId = MT.Id
WHERE
  DT._DATA_DATE BETWEEN '{{QDATE}}' AND '{{QDATE}}'
GROUP BY LineItemName, Date
ORDER BY Date desc, imps desc
