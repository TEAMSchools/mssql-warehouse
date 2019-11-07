USE gabby;
GO

CREATE OR ALTER VIEW surveygizmo.survey_response_clean AS

SELECT sub.survey_response_id
      ,sub.survey_id
      ,sub.contact_id
      ,sub.[status]
      ,sub.is_test_data
      ,sub.datetime_started
      ,sub.datetime_submitted
      ,sub.date_started
      ,sub.date_submitted
      ,sub.response_time
      ,sub.city
      ,sub.postal
      ,sub.region
      ,sub.country
      ,sub.latitude
      ,sub.longitude
      ,sub.dma
      ,sub.[language]
      ,sub.ip_address
      ,sub.link_id
      ,sub.referer
      ,sub.session_id
      ,sub.user_agent
      ,sub.url_privatedomain
      ,sub.url_contact
      ,sub.url_messageid
      ,sub.url_sguid
      ,sub.url_pathdata
      ,sub.data_quality_json
FROM
    (
     SELECT sr.id AS survey_response_id
           ,sr.survey_id
           ,sr.contact_id
           ,CONVERT(VARCHAR(25), COALESCE(dq.[status], sr.[status])) AS [status]
           ,sr.is_test_data
           ,CONVERT(DATETIME2, LEFT(sr.date_started, 19)) AS datetime_started
           ,CONVERT(DATETIME2, LEFT(sr.date_submitted, 19)) AS datetime_submitted
           ,CONVERT(DATE, CONVERT(DATETIME2, LEFT(sr.date_started, 19))) AS date_started
           ,CONVERT(DATE, CONVERT(DATETIME2, LEFT(sr.date_submitted, 19))) AS date_submitted
           ,sr.response_time
           ,CONVERT(VARCHAR(25), sr.city) AS city
           ,CONVERT(VARCHAR(25), sr.postal) AS postal
           ,CONVERT(VARCHAR(5), sr.region) AS region
           ,CONVERT(VARCHAR(125), sr.country) AS country
           ,sr.latitude
           ,sr.longitude
           ,sr.dma
           ,CONVERT(VARCHAR(25), sr.[language]) AS [language]
           ,CONVERT(VARCHAR(25), sr.ip_address) AS ip_address
           ,sr.link_id
           ,CONVERT(VARCHAR(500), sr.referer) AS referer
           ,CONVERT(VARCHAR(125), sr.session_id) AS session_id
           ,CONVERT(VARCHAR(250), sr.user_agent) AS user_agent
           ,CONVERT(VARCHAR(1), JSON_VALUE(sr.url_variables, '$._privatedomain')) AS url_privatedomain
           ,CONVERT(VARCHAR(25), JSON_VALUE(sr.url_variables, '$.__contact')) AS url_contact
           ,CONVERT(VARCHAR(25), JSON_VALUE(sr.url_variables, '$.__messageid')) AS url_messageid
           ,CONVERT(VARCHAR(25), JSON_VALUE(sr.url_variables, '$.sguid')) AS url_sguid
           ,CONVERT(VARCHAR(250), JSON_VALUE(sr.url_variables, '$.__pathdata')) AS url_pathdata
           ,CONVERT(NVARCHAR(MAX), sr.data_quality) AS data_quality_json

           ,ROW_NUMBER() OVER(PARTITION BY sr.id, sr.survey_id ORDER BY sr._modified DESC) AS rn
     FROM gabby.surveygizmo.survey_response sr
     LEFT JOIN gabby.surveygizmo.survey_response_disqualified dq
       ON sr.id = dq.id
      AND sr.survey_id = dq.survey_id
    ) sub
WHERE sub.rn = 1