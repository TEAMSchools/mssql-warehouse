USE gabby
GO

--CREATE OR ALTER VIEW surveygizmo.self_and_others_detail AS

SELECT d.survey_id
      ,d.survey_title
      ,d.survey_response_id
      ,d.academic_year
      ,d.date_started
      ,d.date_submitted
      ,d.campaign_name AS reporting_term_code
      ,d.campaign_name AS reporting_term_name
      ,d.respondent_df_employee_number
      ,d.respondent_preferred_name
      ,d.respondent_mail
      ,d.is_manager
      ,d.question_type
      ,d.question_shortname
      ,d.is_open_ended
      ,d.question_title
      ,d.answer
      ,d.answer_value
      ,d.subject_df_employee_number
      ,d.subject_adp_associate_id
      ,d.subject_preferred_name
      ,d.subject_legal_entity_name
      ,d.subject_primary_site
      ,d.subject_primary_site_schoolid
      ,d.subject_primary_site_school_level
      ,d.subject_manager_df_employee_number
      ,d.subject_samaccountname
      ,d.subject_manager_name
      ,d.subject_manager_samaccountname
      ,CASE 
        WHEN ISNUMERIC(d.answer_value) = 0 THEN NULL
        WHEN d.is_manager = 1 THEN 2.0 
        ELSE 1.0
       END AS response_weight
      ,CASE 
        WHEN ISNUMERIC(d.answer_value) = 0 THEN NULL
        WHEN d.is_manager = 1 THEN d.answer_value * 2.0 
        ELSE d.answer_value 
       END AS response_value
      ,NULL AS avg_response_value_location
FROM gabby.surveygizmo.survey_detail d
WHERE d.survey_title = 'Self and Others'
  AND d.academic_year = 2018

--UNION ALL 

--SELECT survey_type
--      ,response_id
--      ,academic_year
--      ,reporting_term
--      ,term_name
--      ,time_started
--      ,date_submitted
--      ,respondent_name
--      ,respondent_email_address
--      ,question_code
--      ,response
--      ,subject_associate_id
--      ,is_manager
--      ,n_managers
--      ,n_peers
--      ,n_total
--      ,question_text
--      ,open_ended
--      ,response_value
--      ,response_weight
--      ,response_value_weighted
--      ,subject_employee_number
--      ,subject_name
--      ,subject_legal_entity_name
--      ,subject_location
--      ,subject_primary_site_schoolid
--      ,subject_primary_site_school_level
--      ,subject_manager_id
--      ,subject_username
--      ,subject_manager_name
--      ,subject_manager_username
--      ,avg_response_value_location
--FROM surveys.self_and_others_survey_detail