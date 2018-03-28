SELECT
   hits.product.v2productCategory as product_Category,
   hits.product.v2productName as product_Name,
   (sum( hits.product.productRevenue ) * 0.000001) as product_Revenue,
   RANK() OVER (PARTITION BY product_Category ORDER BY product_Revenue DESC) Category_Rank,
FROM TABLE_DATE_RANGE([{{GOOGLE_CLOUDSDK_CORE_PROJECT}}:{{GOOGLE_BIGQUERY_JOB_DATASET}}.{{GOOGLE_BIGQUERY_SOURCE_TABLE}}],TIMESTAMP('{{QDATE}}'),TIMESTAMP('{{QDATE}}'))
WHERE hits.product.v2productName IS NOT NULL
  AND hits.eCommerceAction.action_type = '6'
GROUP BY product_Category, product_Name
ORDER BY product_Revenue DESC
