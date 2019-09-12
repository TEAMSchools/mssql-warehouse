USE gabby
GO

CREATE OR ALTER VIEW surveys.manager_survey_detail AS

SELECT d.survey_id
      ,d.survey_title
      ,d.survey_response_id
      ,d.campaign_academic_year
      ,d.date_started
      ,d.date_submitted
      ,d.campaign_name
      ,d.campaign_reporting_term
      ,d.is_open_ended
      ,d.question_shortname
      ,d.question_title
      ,d.answer
      ,d.answer_value
      ,d.respondent_df_employee_number
      ,d.respondent_preferred_name
      ,d.respondent_mail
      ,d.is_manager
      ,d.subject_df_employee_number
      ,d.subject_adp_associate_id
      ,d.subject_preferred_name
      ,d.subject_legal_entity_name
      ,d.subject_primary_site
      ,d.subject_primary_site_schoolid
      ,d.subject_primary_site_school_level
      ,d.subject_manager_df_employee_number
      ,NULL AS subject_manager_adp_associate_id
      ,d.subject_samaccountname
      ,d.subject_manager_name
      ,d.subject_manager_samaccountname
FROM gabby.surveygizmo.survey_detail d
WHERE d.survey_title = 'Manager Survey'
  AND d.rn_respondent_subject = 1
  AND d.campaign_academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

UNION ALL

SELECT NULL AS survey_id
      ,survey_type AS survey_title
      ,response_id AS survey_response_id
      ,academic_year AS campaign_academic_year
      ,NULL AS date_started
      ,date_submitted
      ,reporting_term AS campaign_name
      ,reporting_term AS campaign_reporting_term
      ,open_ended AS is_open_ended
      ,question_code AS question_shortname
      ,question_text AS question_title
      ,response AS answer
      ,response_value AS answer_value
      ,NULL AS respondent_df_employee_number
      ,respondent_name AS respondent_preferred_name
      ,respondent_email_address AS respondent_mail
      ,NULL AS is_manager
      ,NULL AS subject_df_employee_number
      ,subject_associate_id AS subject_adp_associate_id
      ,subject_name AS subject_preferred_name
      ,region AS subject_legal_entity_name
      ,subject_location AS subject_primary_site
      ,reporting_schoolid AS subject_primary_site_schoolid
      ,school_level AS subject_primary_site_school_level
      ,NULL AS subject_manager_df_employee_number
      ,subject_manager_id AS subject_manager_adp_associate_id
      ,subject_username AS subject_samaccountname
      ,subject_manager_name
      ,subject_manager_username AS subject_manager_samaccountname
FROM surveys.manager_survey_detail_archive