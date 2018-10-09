USE gabby
GO

CREATE OR ALTER VIEW surveys.manager_survey_long AS

WITH manager_long AS (
  SELECT response_id
        ,academic_year
        ,reporting_term
        ,term_name      
        ,time_started
        ,date_submitted
        ,status
        ,associate_id
        ,salesforce_id
        ,email_address
        ,your_name_ AS respondent_name
        ,manager_name
        ,manager_associate_id      
        ,question_code
        ,response
  FROM gabby.surveys.manager_survey_final
  UNPIVOT(
    response
    FOR question_code IN (q_1
                         ,q_2
                         ,q_3
                         ,q_4
                         ,q_5
                         ,q_6
                         ,q_7
                         ,q_8
                         ,q_9
                         ,q_10
                         ,q_11
                         ,q_12
                         ,q_13
                         ,q_14
                         ,q_15
                         ,q_16
                         ,q_17
                         ,q_18)
   ) u
 )

SELECT 'MGR' AS survey_type
      ,CONVERT(INT,mgr.response_id) AS response_id
      ,CONVERT(INT,mgr.academic_year) AS academic_year
      ,CONVERT(VARCHAR(5),mgr.reporting_term) AS reporting_term
      ,CONVERT(VARCHAR(5),mgr.term_name) AS term_name      
      ,CONVERT(DATETIME2,CASE WHEN ISDATE(mgr.time_started) = 0 THEN NULL ELSE mgr.time_started END) AS time_started
      ,CONVERT(DATETIME2,CASE WHEN ISDATE(mgr.date_submitted) = 0 THEN NULL ELSE mgr.date_submitted END) AS date_submitted
      ,CONVERT(VARCHAR(25),mgr.status) AS status
      ,CONVERT(VARCHAR(25),mgr.associate_id) AS respondent_associate_id
      ,CONVERT(VARCHAR(25),mgr.salesforce_id) AS respondent_salesforce_id
      ,CONVERT(VARCHAR(125),mgr.email_address) AS respondent_email_address
      ,CONVERT(VARCHAR(125),mgr.respondent_name) AS respondent_name
      ,CONVERT(VARCHAR(25),mgr.manager_associate_id) AS subject_associate_id
      ,CONVERT(VARCHAR(25),mgr.question_code) AS question_code
      ,mgr.response

      ,qk.question_text
      ,CONVERT(VARCHAR(5),qk.open_ended) AS open_ended

      ,CONVERT(FLOAT,rs.response_value) AS response_value
FROM manager_long mgr     
JOIN gabby.surveys.question_key qk
  ON mgr.question_code = qk.question_code
 AND qk.survey_type = 'MGR'
LEFT JOIN gabby.surveys.response_scales rs
  ON mgr.response = rs.response_text
 AND rs.survey_type = 'MGR'