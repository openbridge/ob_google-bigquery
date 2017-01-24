SELECT
  STRFTIME_UTC_USEC(SEC_TO_TIMESTAMP(visitStartTime+ hits.time/1000),
    '%Y-%m-%d %H:%M:%S') AS hit.timestamp,
  visitNumber,
  visitId,
  fullVisitorId,
  STRFTIME_UTC_USEC(SEC_TO_TIMESTAMP(visitStartTime),
    '%Y-%m-%d %H:%M:%S') AS hit.visitStartTime,
  LEFT(date,
    4)+'-'+SUBSTR(date,5,2)+'-'+RIGHT(date,
    2) AS date,
  totals.visits,
  totals.hits,
  totals.pageviews,
  totals.timeOnSite,
  totals.bounces,
  totals.transactions,
  totals.transactionRevenue,
  totals.newVisits,
  totals.screenviews,
  totals.uniqueScreenviews,
  totals.timeOnScreen,
  totals.totalTransactionRevenue,
  trafficSource.referralPath,
  trafficSource.campaign,
  trafficSource.source,
  trafficSource.medium,
  trafficSource.keyword,
  trafficSource.adContent,
  hits.type,
  hits.eventInfo.eventValue,
  hits.eventInfo.eventLabel,
  hits.eventInfo.eventCategory,
  hits.eventInfo.eventAction,
  hits.appInfo.name,
  hits.appInfo.version,
  hits.appInfo.id,
  hits.appInfo.installerId,
  hits.appInfo.appInstallerId,
  hits.appInfo.appName,
  hits.appInfo.appVersion,
  hits.appInfo.appId,
  hits.appInfo.screenName,
  hits.appInfo.landingScreenName,
  hits.appInfo.exitScreenName,
  hits.appInfo.screenDepth,
  hits.exceptionInfo.description,
  hits.exceptionInfo.isFatal,
  device.browser,
  device.browserVersion,
  device.operatingSystem,
  device.operatingSystemVersion,
  device.isMobile,
  device.mobileDeviceBranding,
  device.flashVersion,
  device.javaEnabled,
  device.LANGUAGE,
  device.screenColors,
  device.screenResolution,
  device.deviceCategory,
  geoNetwork.continent,
  geoNetwork.subContinent,
  geoNetwork.country,
  geoNetwork.region,
  geoNetwork.metro,
  hits.social.socialInteractionNetwork,
  hits.social.socialInteractionAction,
  hits.hitNumber,
  (hits.time/1000) AS hits.time,
  hits.hour,
  hits.minute,
  hits.isSecure,
  hits.isInteraction,
  hits.referer,
  hits.page.pagePath,
  hits.page.hostname,
  hits.page.pageTitle,
  hits.page.pagePathLevel1,
  hits.page.pagePathLevel2,
  hits.page.pagePathLevel3,
  hits.page.pagePathLevel4,
  hits.page.searchKeyword,
  hits.page.searchCategory,
  hits.product.isImpression,
  hits.product.localproductPrice,
  hits.product.localproductRefundAmount,
  hits.product.localproductRevenue,
  hits.product.productBrand,
  hits.product.productListName,
  hits.product.productListPosition,
  hits.product.productPrice,
  hits.product.productQuantity,
  hits.product.productRefundAmount,
  hits.product.productRevenue,
  hits.product.productSKU,
  hits.product.productVariant,
  hits.product.v2productCategory,
  hits.product.v2productName,
  hits.transaction.transactionId,
  hits.transaction.transactionRevenue,
  hits.transaction.transactionTax,
  hits.transaction.transactionShipping,
  hits.transaction.affiliation,
  hits.transaction.currencyCode,
  hits.transaction.localTransactionRevenue,
  hits.transaction.localTransactionTax,
  hits.transaction.localTransactionShipping,
  hits.transaction.transactionCoupon,
  hits.contentInfo.contentDescription,
  hits.item.transactionId,
  hits.item.productName,
  hits.item.productCategory,
  hits.item.productSku,
  hits.item.itemQuantity,
  hits.item.itemRevenue,
  hits.item.currencyCode,
  hits.item.localItemRevenue,
  hits.eCommerceAction.action_type,
  hits.eCommerceAction.step,
  hits.eCommerceAction.option,
  hits.refund.refundAmount,
  hits.refund.localRefundAmount,
  hits.promotion.promoId,
  hits.promotion.promoName,
  hits.promotion.promoCreative,
  hits.promotion.promoPosition,
  hits.publisher.adsClicked,
  hits.publisher.adsenseBackfillDfpClicks,
  hits.publisher.adsenseBackfillDfpImpressions,
  hits.publisher.adsenseBackfillDfpMatchedQueries,
  hits.publisher.adsenseBackfillDfpMeasurableImpressions,
  hits.publisher.adsenseBackfillDfpPagesViewed,
  hits.publisher.adsenseBackfillDfpQueries,
  hits.publisher.adsenseBackfillDfpRevenueCpc,
  hits.publisher.adsenseBackfillDfpRevenueCpm,
  hits.publisher.adsenseBackfillDfpViewableImpressions,
  hits.publisher.adsPagesViewed,
  hits.publisher.adsRevenue,
  hits.publisher.adsUnitsMatched,
  hits.publisher.adsUnitsViewed,
  hits.publisher.adsViewed,
  hits.publisher.adxBackfillDfpClicks,
  hits.publisher.adxBackfillDfpImpressions,
  hits.publisher.adxBackfillDfpMatchedQueries,
  hits.publisher.adxBackfillDfpMeasurableImpressions,
  hits.publisher.adxBackfillDfpPagesViewed,
  hits.publisher.adxBackfillDfpQueries,
  hits.publisher.adxBackfillDfpRevenueCpc,
  hits.publisher.adxBackfillDfpRevenueCpm,
  hits.publisher.adxBackfillDfpViewableImpressions,
  hits.publisher.adxClicks,
  hits.publisher.adxImpressions,
  hits.publisher.adxMatchedQueries,
  hits.publisher.adxMeasurableImpressions,
  hits.publisher.adxPagesViewed,
  hits.publisher.adxQueries,
  hits.publisher.adxRevenue,
  hits.publisher.adxViewableImpressions,
  hits.publisher.dfpAdGroup,
  hits.publisher.dfpAdUnits,
  hits.publisher.dfpClicks,
  hits.publisher.dfpImpressions,
  hits.publisher.dfpMatchedQueries,
  hits.publisher.dfpMeasurableImpressions,
  hits.publisher.dfpNetworkId,
  hits.publisher.dfpPagesViewed,
  hits.publisher.dfpQueries,
  hits.publisher.dfpRevenueCpc,
  hits.publisher.dfpRevenueCpm,
  hits.publisher.dfpViewableImpressions,
  hits.publisher.measurableAdsViewed,
  hits.publisher.viewableAdsViewed,
  hits.social.hasSocialSourceReferral,
  hits.social.socialInteractionNetworkAction,
  hits.social.socialInteractions,
  hits.social.socialInteractionTarget,
  hits.social.socialNetwork,
  MAX(IF (hits.customDimensions.index = 1,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension1,
  MAX(IF (hits.customDimensions.index = 2,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension2,
  MAX(IF (hits.customDimensions.index = 3,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension3,
  MAX(IF (hits.customDimensions.index = 4,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension4,
  MAX(IF (hits.customDimensions.index = 5,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension5,
  MAX(IF (hits.customDimensions.index = 6,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension6,
  MAX(IF (hits.customDimensions.index = 7,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension7,
  MAX(IF (hits.customDimensions.index = 8,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension8,
  MAX(IF (hits.customDimensions.index = 9,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension9,
  MAX(IF (hits.customDimensions.index = 10,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension10,
  MAX(IF (hits.customDimensions.index = 11,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension11,
  MAX(IF (hits.customDimensions.index = 12,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension12,
  MAX(IF (hits.customDimensions.index = 13,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension13,
  MAX(IF (hits.customDimensions.index = 14,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension14,
  MAX(IF (hits.customDimensions.index = 15,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension15,
  MAX(IF (hits.customDimensions.index = 16,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension16,
  MAX(IF (hits.customDimensions.index = 17,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension17,
  MAX(IF (hits.customDimensions.index = 18,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension18,
  MAX(IF (hits.customDimensions.index = 19,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension19,
  MAX(IF (hits.customDimensions.index = 20,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension20,
  MAX(IF (hits.customDimensions.index = 21,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension21,
  MAX(IF (hits.customDimensions.index = 22,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension22,
  MAX(IF (hits.customDimensions.index = 23,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension23,
  MAX(IF (hits.customDimensions.index = 24,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension24,
  MAX(IF (hits.customDimensions.index = 25,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension25,
  MAX(IF (hits.customDimensions.index = 26,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension26,
  MAX(IF (hits.customDimensions.index = 27,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension27,
  MAX(IF (hits.customDimensions.index = 28,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension28,
  MAX(IF (hits.customDimensions.index = 29,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension29,
  MAX(IF (hits.customDimensions.index = 30,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension30,
  MAX(IF (hits.customDimensions.index = 31,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension31,
  MAX(IF (hits.customDimensions.index = 32,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension32,
  MAX(IF (hits.customDimensions.index = 33,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension33,
  MAX(IF (hits.customDimensions.index = 34,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension34,
  MAX(IF (hits.customDimensions.index = 35,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension35,
  MAX(IF (hits.customDimensions.index = 36,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension36,
  MAX(IF (hits.customDimensions.index = 37,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension37,
  MAX(IF (hits.customDimensions.index = 38,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension38,
  MAX(IF (hits.customDimensions.index = 39,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension39,
  MAX(IF (hits.customDimensions.index = 40,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension40,
  MAX(IF (hits.customDimensions.index = 41,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension41,
  MAX(IF (hits.customDimensions.index = 42,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension42,
  MAX(IF (hits.customDimensions.index = 43,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension43,
  MAX(IF (hits.customDimensions.index = 44,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension44,
  MAX(IF (hits.customDimensions.index = 45,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension45,
  MAX(IF (hits.customDimensions.index = 46,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension46,
  MAX(IF (hits.customDimensions.index = 47,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension47,
  MAX(IF (hits.customDimensions.index = 48,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension48,
  MAX(IF (hits.customDimensions.index = 49,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension49,
  MAX(IF (hits.customDimensions.index = 50,
      hits.customDimensions.value,
      NULL)) WITHIN RECORD AS dimension50,
  (CASE
      WHEN hits.customMetrics.index = 1 AND hits.customMetrics.value IS NOT NULL THEN hits.customMetrics.value
      ELSE NULL END) AS metric1,
  (CASE
      WHEN hits.customMetrics.index = 2 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric2,
  (CASE
      WHEN hits.customMetrics.index = 3 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric3,
  (CASE
      WHEN hits.customMetrics.index = 4 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric4,
  (CASE
      WHEN hits.customMetrics.index = 5 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric5,
  (CASE
      WHEN hits.customMetrics.index = 6 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric6,
  (CASE
      WHEN hits.customMetrics.index = 7 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric7,
  (CASE
      WHEN hits.customMetrics.index = 8 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric8,
  (CASE
      WHEN hits.customMetrics.index = 9 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric9,
  (CASE
      WHEN hits.customMetrics.index = 10 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric10,
  (CASE
      WHEN hits.customMetrics.index = 11 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric11,
  (CASE
      WHEN hits.customMetrics.index = 12 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric12,
  (CASE
      WHEN hits.customMetrics.index = 13 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric13,
  (CASE
      WHEN hits.customMetrics.index = 14 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric14,
  (CASE
      WHEN hits.customMetrics.index = 15 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric15,
  (CASE
      WHEN hits.customMetrics.index = 16 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric16,
  (CASE
      WHEN hits.customMetrics.index = 17 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric17,
  (CASE
      WHEN hits.customMetrics.index = 18 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric18,
  (CASE
      WHEN hits.customMetrics.index = 19 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric19,
  (CASE
      WHEN hits.customMetrics.index = 20 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric20,
  (CASE
      WHEN hits.customMetrics.index = 21 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric21,
  (CASE
      WHEN hits.customMetrics.index = 22 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric22,
  (CASE
      WHEN hits.customMetrics.index = 23 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric23,
  (CASE
      WHEN hits.customMetrics.index = 24 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric24,
  (CASE
      WHEN hits.customMetrics.index = 25 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric25,
  (CASE
      WHEN hits.customMetrics.index = 26 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric26,
  (CASE
      WHEN hits.customMetrics.index = 27 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric27,
  (CASE
      WHEN hits.customMetrics.index = 28 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric28,
  (CASE
      WHEN hits.customMetrics.index = 29 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric29,
  (CASE
      WHEN hits.customMetrics.index = 30 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric30,
  (CASE
      WHEN hits.customMetrics.index = 31 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric31,
  (CASE
      WHEN hits.customMetrics.index = 32 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric32,
  (CASE
      WHEN hits.customMetrics.index = 33 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric33,
  (CASE
      WHEN hits.customMetrics.index = 34 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric34,
  (CASE
      WHEN hits.customMetrics.index = 35 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric35,
  (CASE
      WHEN hits.customMetrics.index = 36 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric36,
  (CASE
      WHEN hits.customMetrics.index = 37 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric37,
  (CASE
      WHEN hits.customMetrics.index = 38 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric38,
  (CASE
      WHEN hits.customMetrics.index = 39 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric39,
  (CASE
      WHEN hits.customMetrics.index = 40 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric40,
  (CASE
      WHEN hits.customMetrics.index = 41 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric41,
  (CASE
      WHEN hits.customMetrics.index = 42 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric42,
  (CASE
      WHEN hits.customMetrics.index = 43 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric43,
  (CASE
      WHEN hits.customMetrics.index = 44 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric44,
  (CASE
      WHEN hits.customMetrics.index = 45 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric45,
  (CASE
      WHEN hits.customMetrics.index = 46 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric46,
  (CASE
      WHEN hits.customMetrics.index = 47 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric47,
  (CASE
      WHEN hits.customMetrics.index = 48 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric48,
  (CASE
      WHEN hits.customMetrics.index = 49 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric49,
  (CASE
      WHEN hits.customMetrics.index = 50 AND hits.customMetrics.value > 0 THEN hits.customMetrics.value
      ELSE NULL END) AS metric50,
FROM TABLE_DATE_RANGE([{{GOOGLE_CLOUDSDK_CORE_PROJECT}}:{{GOOGLE_BIGQUERY_JOB_DATASET}}.ga_sessions_],TIMESTAMP('{{QDATE}}'),TIMESTAMP('{{QDATE}}'))
