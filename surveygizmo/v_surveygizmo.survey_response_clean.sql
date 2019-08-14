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
      ,survey_data AS survey_data_json
      ,url_variables AS url_variables_json
      ,data_quality AS data_quality_json
FROM gabby.surveygizmo.survey_response