# The following sample query analyzes keywords by campaign, ad group, and keyword status. This query uses the KeywordMatchType function. Keyword match types help control which searches can trigger your ad.
SELECT
  c.CampaignStatus AS CampaignStatus,
  a.AdGroupStatus AS AdGroupStatus,
  k.Status AS KeywordStatus,
  k.KeywordMatchType AS KeywordMatchType,
  COUNT(*) AS count
FROM
  `[DATASET].Keyword_[CUSTOMER_ID]` k
  JOIN
  `[DATASET].Campaign_[CUSTOMER_ID]` c
ON
  (k.CampaignId = c.CampaignId AND k.DATA_DATE = c._DATA_DATE)
JOIN
  `[DATASET].AdGroup[CUSTOMER_ID]` a
ON
  (k.AdGroupId = a.AdGroupId AND k._DATA_DATE = a._DATA_DATE)
WHERE
  k._DATA_DATE = k._LATEST_DATE
GROUP BY
  1, 2, 3, 4
