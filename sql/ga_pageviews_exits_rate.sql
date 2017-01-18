SELECT
  page,
  COUNT(page) as pageviews,
  SUM(IF(hit_number = max_hit, 1, 0)) as exits,
  (SUM(IF(hit_number = max_hit, 1, 0))/COUNT(page)) * 100 AS exit_rate
FROM (SELECT CONCAT(fullVisitorId, STRING(visitId)) AS unique_visit_id, hits.hitNumber AS hit_number, hits.type AS hit_type, hits.page.pagePath AS page, MAX(hit_number) OVER (PARTITION BY unique_visit_id) AS max_hit
FROM TABLE_DATE_RANGE([{{GOOGLE_CLOUDSDK_CORE_PROJECT}}:{{GOOGLE_BIGQUERY_JOB_DATASET}}.ga_sessions_],TIMESTAMP('{{QDATE}}'),TIMESTAMP('{{QDATE}}'))
WHERE hits.type = 'PAGE'
GROUP BY unique_visit_id, hit_number, hit_type, page
ORDER BY unique_visit_id, hit_number)
GROUP BY page
ORDER BY pageviews DESC
