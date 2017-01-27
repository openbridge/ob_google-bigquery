SELECT
trafficSource.source + ' / ' + trafficSource.medium AS source_medium,
count(DISTINCT CONCAT(fullVisitorId, STRING(visitId)), 100000) as sessions,
SUM(totals.bounces) as bounces,
100 * SUM(totals.bounces) / count(DISTINCT CONCAT(fullVisitorId, STRING(visitId)), 100000) as bounce_rate,
SUM(totals.transactions) as transactions,
100 * SUM(totals.transactions) / count(DISTINCT CONCAT(fullVisitorId, STRING(visitId)), 100000) as conversion_rate,
SUM(totals.transactionRevenue) / 1000000 as transaction_revenue,
SUM(hits.transaction.transactionRevenue) / 1000000 as rev2,
AVG(hits.transaction.transactionRevenue) / 1000000 as avg_rev2,
(SUM(hits.transaction.transactionRevenue) / 1000000 ) / SUM(totals.transactions) as avg_rev
FROM TABLE_DATE_RANGE([{{GOOGLE_CLOUDSDK_CORE_PROJECT}}:{{GOOGLE_BIGQUERY_JOB_DATASET}}.{{GOOGLE_BIGQUERY_TABLE}}],TIMESTAMP('{{QDATE}}'),TIMESTAMP('{{QDATE}}'))
GROUP BY source_medium
ORDER BY sessions DESC
