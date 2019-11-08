USE gabby
GO

CREATE OR ALTER VIEW surveys.cmo_engagement_regional_survey_detail AS

SELECT d.survey_id
      ,d.survey_title
      ,d.survey_response_id
      ,d.campaign_academic_year
      ,d.date_started
      ,d.date_submitted
      ,d.campaign_name
      ,CONVERT(VARCHAR(25), d.campaign_reporting_term) AS campaign_reporting_term
      ,d.is_open_ended
      ,CONVERT(VARCHAR(250), d.question_shortname) AS question_shortname
      ,d.question_title
      ,d.answer
      ,d.answer_value
      ,CONVERT(VARCHAR(8),d.respondent_df_employee_number) AS respondent_df_employee_number
      ,d.respondent_preferred_name
      ,d.respondent_mail
      ,d.is_manager
      ,d.respondent_department_name
      ,d.respondent_legal_entity_name
      ,d.respondent_manager_name
      ,d.respondent_primary_job
      ,d.respondent_primary_site
FROM gabby.surveygizmo.survey_detail d
WHERE d.survey_id = 5300913
  AND d.rn_respondent_subject = 1
  AND d.campaign_academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

UNION ALL 

SELECT NULL as survey_id
      ,'CMO Survey (Historic)' AS survey_title
      ,NULL AS survey_response_id
      ,c.academic_year AS campaign_academic_year
      ,NULL AS date_started
      ,NULL AS date_submitted
      ,CASE WHEN term_name = 'fall' THEN 'R9S1'
            WHEN term_name = 'spring' THEN 'R9S2'
            ELSE NULL
            END AS campaign_name
      ,CASE WHEN term_name = 'fall' THEN 'R9S1'
            WHEN term_name = 'spring' THEN 'R9S2'
            ELSE NULL
            END AS campaign_reporting_term
      ,CASE WHEN is_oe = 1 THEN 'Y'
            ELSE 'N'
            END AS is_open_ended
      ,c.question AS question_shortname
      ,NULL AS question_title
      ,c.response_text AS answer
      ,c.response_value AS answer_value
      ,CONVERT(VARCHAR(8),c.df_employee_number) AS respondent_df_employee_number
      ,NULL AS respondent_preferred_name
      ,c.email AS respondent_mail
      ,NULL AS is_manager
      ,NULL AS respondent_department_name
      ,NULL AS legal_entity_name
      ,NULL AS respondent_manager_name
      ,c.primary_job AS respondent_primary_job
      ,c.primary_site AS respondent_primary_site
FROM surveys.cmo_survey_final c

UNION ALL

SELECT NULL AS survey_id
      ,'Engagement & Regional Survey (Historic)' AS survey_title
      ,e.participant_id AS survey_response_id
      ,e.academic_year AS campaign_academic_year
      ,NULL AS date_started
      ,NULL AS date_submitted
      ,e.reporting_term AS campaign_name
      ,e.reporting_term AS campaign_reporting_term
      ,'N' AS is_open_ended
      ,e.question_code AS question_shortname
      ,q.question_text AS question_title
      ,CONVERT(NVARCHAR,e.response_value) AS answer
      ,e.response_value AS answer_value
      ,e.associate_id AS respondent_df_employee_number
      ,NULL AS respondent_preferred_name
      ,e.email AS  respondent_mail
      ,NULL AS is_manager
      ,NULL AS respondent_department_name
      ,e.region AS respondent_legal_entity_name
      ,NULL AS respondent_manager_name
      ,NULL AS respondent_primary_job
      ,e.location AS respondent_primary_site
FROM surveys.r9engagement_survey_detail e 
LEFT JOIN surveys.question_key q
  ON e.academic_year = q.academic_year
 AND e.question_code = q.question_code
 AND q.survey_type = 'CMO'

UNION ALL

SELECT NULL AS survey_id
      ,'Engagement & Regional Survey (Historic)' AS survey_title
      ,oe.participant_id AS survey_response_id
      ,oe.academic_year AS campaign_academic_year
      ,NULL AS date_started
      ,NULL AS date_submitted
      ,oe.reporting_term AS campaign_name
      ,oe.reporting_term AS campaign_reporting_term
      ,'Y' AS is_open_ended
      ,oe.question_code AS question_shortname
      ,q.question_text AS question_title
      ,oe.response_value AS answer
      ,NULL AS answer_value
      ,oe.associate_id AS respondent_df_employee_number
      ,NULL AS respondent_preferred_name
      ,oe.email AS  respondent_mail
      ,NULL AS is_manager
      ,NULL AS respondent_department_name
      ,oe.region AS respondent_legal_entity_name
      ,NULL AS respondent_manager_name
      ,NULL AS respondent_primary_job
      ,oe.location AS respondent_primary_site
FROM surveys.r9engagement_survey_oe oe
LEFT JOIN surveys.question_key q
  ON oe.academic_year = q.academic_year
 AND oe.question_code = q.question_code
 AND q.survey_type = 'CMO'
