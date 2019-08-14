USE gabby
GO

CREATE OR ALTER VIEW surveygizmo.survey_response_clean AS

SELECT id
      ,survey_id
      ,contact_id
      ,[status]
      ,is_test_data
      ,CONVERT(DATETIME2, LEFT(date_started, 19)) AS date_started
      ,CONVERT(DATETIME2, LEFT(date_submitted, 19)) AS date_submitted
      ,response_time
      ,city
      ,postal
      ,region
      ,country
      ,latitude
      ,longitude
      ,dma
      ,[language]
      ,ip_address
      ,link_id
      ,referer
      ,session_id
      ,user_agent
      ,JSON_VALUE(url_variables, '$._privatedomain') AS url_privatedomain
      ,JSON_VALUE(url_variables, '$.__contact') AS url_contact
      ,JSON_VALUE(url_variables, '$.__messageid') AS url_messageid
      ,JSON_VALUE(url_variables, '$.sguid') AS url_sguid
      ,JSON_VALUE(url_variables, '$.__pathdata') AS url_pathdata

      ,data_quality AS data_quality_json
FROM gabby.surveygizmo.survey_response