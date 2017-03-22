# The following sample query analyzes campaign activity over the past 30 days. #In this query, replace [CAMPAIGN_LIST] with a comma separated list of all # the DoubleClick campaigns of interest within the scope of the query.

# START_DATE = DATE_ADD(CURRENT_DATE(), INTERVAL -31 DAY)
# END_DATE = DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)
SELECT
  base.*,
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
      `[DATASET].match_table_campaigns_{{GOOGLE_DOUBLECLICK_ID}}`
    WHERE
      DATA_DATE = LATEST_DATE ),
    (
    SELECT
      mt_at.Activity_Group,
      mt_ac.Activity,
      mt_ac.Activity_Type,
      mt_ac.Activity_Sub_Type,
      mt_ac.Activity_ID,
      mt_ac.Activity_Group_ID
    FROM
      `[DATASET].match_table_activity_cats{{GOOGLE_DOUBLECLICK_ID}}` AS mt_ac
    JOIN (
      SELECT
        Activity_Group,
        Activity_Group_ID
      FROM
        `{{GOOGLE_CLOUDSDK_CORE_PROJECT}}:{{GOOGLE_BIGQUERY_JOB_DATASET}}.match_table_activity_types{{GOOGLE_DOUBLECLICK_ID}}`
      WHERE
        DATA_DATE = _LATEST_DATE ) AS mt_at
    ON
      mt_at.Activity_Group_ID = mt_ac.Activity_Group_ID
    WHERE
      _DATA_DATE = _LATEST_DATE ),
    (
    SELECT
      date AS Date
    FROM
      `bigquery-public-data.common_us.date_greg`
    WHERE
      Date BETWEEN [START_DATE]
      AND [END_DATE] ) ) AS base
LEFT JOIN (
  SELECT
    Campaign_ID,
    Activity_ID,
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
    Activity_ID,
    Date ) AS activity
ON
  base.Campaign_ID = activity.Campaign_ID
  AND base.Activity_ID = activity.Activity_ID
  AND base.Date = activity.Date
WHERE
  base.Campaign_ID IN [CAMPAIGN_LIST]
  AND base.Activity_ID = activity.Activity_ID
ORDER BY
  base.Campaign_ID,
  base.Activity_Group_ID,
  base.Activity_ID,
  base.Date
