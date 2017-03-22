/*
The following sample query analyzes the number of impressions, clicks, activities, and distinct users by campaign over the past 30 days.
START_DATE = DATE_ADD(CURRENT_DATE(), INTERVAL -31 DAY)
END_DATE = DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)

The table name construct should look like this "NetworkImpressions{{GOOGLE_DOUBLECLICK_NETWORK_CODE}}"
*/
SELECT
  base.*,
  imp.count AS imp_count,
  imp.du AS imp_du,
  click.count AS click_count,
  click.du AS click_du,
  activity.count AS activity_count,
  activity.du AS activity_du
FROM (
  SELECT
    *
  FROM (
    SELECT
      Campaign,
      Campaign_ID
    FROM
      `{{GOOGLE_BIGQUERY_JOB_DATASET}}.match_table_campaigns_{{GOOGLE_DOUBLECLICK_ID}}`
    WHERE
      DATA_DATE = _LATEST_DATE ),
    (
    SELECT
      date AS Date
    FROM
      `bigquery-public-data.common_us.date_greg`
    WHERE
      Date BETWEEN DATE_ADD(CURRENT_DATE(), INTERVAL -31 DAY)
      AND DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY) ) ) AS base
LEFT JOIN (
  SELECT
    Campaign_ID,
    _DATA_DATE AS Date,
    COUNT() AS count,
    COUNT(DISTINCT User_ID) AS du
  FROM
    `{{GOOGLE_CLOUDSDK_CORE_PROJECT}}:{{GOOGLE_BIGQUERY_JOB_DATASET}}.impression{{GOOGLE_DOUBLECLICK_ID}}`
  WHERE
    DATA_DATE BETWEEN DATE_ADD(CURRENT_DATE(), INTERVAL -31 DAY)
    AND DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)
  GROUP BY
    Campaign_ID,
    Date ) AS imp
ON
  base.Campaign_ID = imp.Campaign_ID
  AND base.Date = imp.Date
LEFT JOIN (
  SELECT
    Campaign_ID,
    DATA_DATE AS Date,
    COUNT() AS count,
    COUNT(DISTINCT User_ID) AS du
  FROM
    `{{GOOGLE_CLOUDSDK_CORE_PROJECT}}:{{GOOGLE_BIGQUERY_JOB_DATASET}}.click{{GOOGLE_DOUBLECLICK_ID}}`
  WHERE
    _DATA_DATE BETWEEN DATE_ADD(CURRENT_DATE(), INTERVAL -31 DAY)
    AND DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)
  GROUP BY
    Campaign_ID,
    Date ) AS click
ON
  base.Campaign_ID = click.Campaign_ID
  AND base.Date = click.Date
LEFT JOIN (
  SELECT
    Campaign_ID,
    _DATA_DATE AS Date,
    COUNT() AS count,
    COUNT(DISTINCT User_ID) AS du
  FROM
    `{{GOOGLE_CLOUDSDK_CORE_PROJECT}}:{{GOOGLE_BIGQUERY_JOB_DATASET}}.activity{{GOOGLE_DOUBLECLICK_ID}}`
  WHERE
    _DATA_DATE BETWEEN DATE_ADD(CURRENT_DATE(), INTERVAL -31 DAY)
    AND DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)
  GROUP BY
    Campaign_ID,
    Date ) AS activity
ON
  base.Campaign_ID = activity.Campaign_ID
  AND base.Date = activity.Date
WHERE
  base.Campaign_ID IN [CAMPAIGN_LIST]
  AND (base.Date = imp.Date
    OR base.Date = click.Date
    OR base.Date = activity.Date)
ORDER BY
  base.Campaign_ID,
  base.Date
