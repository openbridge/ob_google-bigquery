SELECT trafficSource.source , ( ( total_no_of_bounces / total_visits ) * 100 ) AS bounce_rate
FROM (
  SELECT trafficSource.source , COUNT ( trafficSource.source ) AS total_visits, COUNT ( totals.bounces ) AS total_no_of_bounces
  FROM TABLE_DATE_RANGE([{{GOOGLE_CLOUDSDK_CORE_PROJECT}}:{{GOOGLE_BIGQUERY_JOB_DATASET}}.{{GOOGLE_BIGQUERY_TABLE}}],TIMESTAMP('{{QDATE}}'),TIMESTAMP('{{QDATE}}'))
  GROUP BY trafficSource.source )
GROUP BY trafficSource.source, bounce_rate;
