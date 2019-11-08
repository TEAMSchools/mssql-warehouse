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
      ,d.respondent_department_name
      ,d.respondent_legal_entity_name
      ,d.respondent_manager_name
      ,d.respondent_primary_job
      ,d.respondent_primary_site
FROM gabby.surveygizmo.survey_detail d
WHERE d.survey_title = 'Engagement, Regional, and CMO Survey'
  AND d.rn_respondent_subject = 1
  AND d.campaign_academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

UNION ALL

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
      ,d.respondent_department_name
      ,d.respondent_legal_entity_name
      ,d.respondent_manager_name
      ,d.respondent_primary_job
      ,d.respondent_primary_site
FROM gabby.surveys.cmo_engagement_regional_survey_detail_archive d