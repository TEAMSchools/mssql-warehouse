USE gabby
GO

CREATE OR ALTER VIEW surveys.manager_survey_detail AS

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
      ,mgr.response_id
      ,mgr.academic_year
      ,mgr.reporting_term
      ,mgr.term_name
      ,mgr.time_started
      ,mgr.date_submitted
      ,mgr.status
      ,mgr.associate_id  AS respondent_associate_id
      ,mgr.salesforce_id AS respondent_salesforce_id
      ,mgr.email_address AS respondent_email_address
      ,mgr.respondent_name      
      ,mgr.manager_associate_id AS subject_associate_id
      ,mgr.question_code
      ,mgr.response
      
      ,CONCAT(adp.preferred_first, ' ', adp.preferred_last) AS subject_name
      ,adp.location_custom AS subject_location
      ,adp.manager_custom_assoc_id AS subject_manager_name

      ,ad.samaccountname AS subject_username

      ,qk.question_text
      ,qk.open_ended

      ,rs.response_value
      ,ROUND(AVG(CONVERT(FLOAT,rs.response_value)) OVER(PARTITION BY mgr.academic_year, mgr.reporting_term, mgr.question_code, adp.location_custom), 1) AS avg_response_value_location
FROM manager_long mgr
JOIN gabby.adp.staff_roster adp
  ON mgr.manager_associate_id = adp.associate_id
 AND adp.rn_curr = 1
JOIN gabby.adsi.user_attributes ad
  ON adp.associate_id = ad.idautopersonalternateid
JOIN gabby.surveys.question_key qk
  ON mgr.question_code = qk.question_code
 AND qk.survey_type = 'MGR'
LEFT OUTER JOIN gabby.surveys.response_scales rs
  ON mgr.response = rs.response_text
 AND rs.survey_type = 'MGR'