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
      ,w.department_name AS respondent_department_name
      ,w.legal_entity_name AS respondent_legal_entity_name
      ,d.respondent_manager_name
      ,w.job_name AS respondent_primary_job
      ,w.physical_location_name AS respondent_primary_site
FROM gabby.surveygizmo.survey_detail d
LEFT JOIN gabby.dayforce.work_assignment_status w
  ON d.respondent_df_employee_number = w.df_employee_id
 AND d.date_submitted BETWEEN w.effective_start_date 
                          AND COALESCE(w.effective_end_date, DATEFROMPARTS((d.campaign_academic_year + 1), 7, 1))
WHERE d.survey_id = 5300913
  AND d.rn_respondent_subject = 1
  AND d.campaign_academic_year >= 2018

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
