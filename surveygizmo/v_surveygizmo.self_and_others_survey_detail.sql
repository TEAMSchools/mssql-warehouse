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
      ,resp.preferred_name AS respondent_name
      ,resp.mail AS respondent_email_address
      ,resp.is_manager
      ,d.question_type
      ,d.question_shortname AS question_code
      ,d.is_open_ended
      ,d.question_title AS question_text
      ,d.answer AS response
      ,d.answer_value AS response_value
      ,d.subject_df_employee_number
      ,NULL AS subject_adp_associate_id
      ,subj.preferred_name AS subject_name
      ,subj.legal_entity_name AS subject_legal_entity_name
      ,subj.primary_site AS subject_location
      ,subj.primary_site_schoolid AS subject_primary_site_schoolid
      ,subj.primary_site_school_level AS subject_primary_site_school_level
      ,subj.manager_df_employee_number AS subject_manager_df_employee_number
      ,subj.samaccountname AS subject_username
      ,subj.manager_name AS subject_manager_name
      ,subj.manager_samaccountname AS subject_manager_username

      --,d.n_managers
      --,d.n_peers
      --,d.n_total
      --,CASE 
      --  WHEN d.n_peers = 0 OR d.n_manager = 0 THEN d.answer_value * d.response_weight * 2
      --  ELSE d.answer_value * d.response_weight
      -- END AS response_value_weighted
      --,NULL AS avg_response_value_location
FROM gabby.surveygizmo.survey_detail d
LEFT JOIN gabby.people.staff_crosswalk_static resp
  ON d.respondent_df_employee_number = resp.df_employee_number
LEFT JOIN gabby.people.staff_crosswalk_static subj
  ON d.subject_df_employee_number = subj.df_employee_number
WHERE d.survey_title = 'Self and Others'
  AND d.academic_year >= 2019

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