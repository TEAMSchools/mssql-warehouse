USE gabby;
GO

CREATE OR ALTER VIEW surveygizmo.survey_response_clean AS

SELECT sub.survey_response_id
      ,sub.survey_id
      ,sub.contact_id
      ,sub.status
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
      ,sub.language
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
           ,COALESCE(dq.[status], sr.[status]) AS [status]
           ,sr.is_test_data
           ,CONVERT(DATETIME2, LEFT(sr.date_started, 19)) AS datetime_started
           ,CONVERT(DATETIME2, LEFT(sr.date_submitted, 19)) AS datetime_submitted
           ,CONVERT(DATE, CONVERT(DATETIME2, LEFT(sr.date_started, 19))) AS date_started
           ,CONVERT(DATE, CONVERT(DATETIME2, LEFT(sr.date_submitted, 19))) AS date_submitted
           ,sr.response_time
           ,sr.city
           ,sr.postal
           ,sr.region
           ,sr.country
           ,sr.latitude
           ,sr.longitude
           ,sr.dma
           ,sr.language
           ,sr.ip_address
           ,sr.link_id
           ,sr.referer
           ,sr.session_id
           ,sr.user_agent
           ,JSON_VALUE(sr.url_variables, '$._privatedomain') AS url_privatedomain
           ,JSON_VALUE(sr.url_variables, '$.__contact') AS url_contact
           ,JSON_VALUE(sr.url_variables, '$.__messageid') AS url_messageid
           ,JSON_VALUE(sr.url_variables, '$.sguid') AS url_sguid
           ,JSON_VALUE(sr.url_variables, '$.__pathdata') AS url_pathdata
           ,sr.data_quality AS data_quality_json

           ,ROW_NUMBER() OVER(PARTITION BY sr.id, sr.survey_id ORDER BY sr._modified DESC) AS rn
     FROM gabby.surveygizmo.survey_response sr
     LEFT JOIN gabby.surveygizmo.survey_response_disqualified dq
       ON sr.id = dq.id
      AND sr.survey_id = dq.survey_id
    ) sub
WHERE sub.rn = 1