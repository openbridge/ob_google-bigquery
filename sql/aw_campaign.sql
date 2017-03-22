# The following sample query analyzes AdWords campaign performance for the past 30 days.
SELECT
  c.ExternalCustomerId,
  c.CampaignName,
  c.CampaignStatus,
  SUM(cs.Impressions) AS Impressions,
  SUM(cs.Interactions) AS Interactions,
  (SUM(cs.Cost) / 1000000) AS Cost
FROM
  `[DATASET].Campaign_[CUSTOMER_ID]` c
LEFT JOIN
  `[DATASET].CampaignStats_[CUSTOMER_ID]` cs
ON
  (c.CampaignId = cs.CampaignId
   AND cs._DATA_DATE BETWEEN
   DATE_ADD(CURRENT_DATE(), INTERVAL -31 DAY) AND DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY))
WHERE
  c._DATA_DATE = c._LATEST_DATE
GROUP BY
  1, 2, 3
ORDER BY
  Impressions DESC
