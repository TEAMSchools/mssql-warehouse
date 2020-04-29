USE gabby
GO

CREATE OR ALTER VIEW surveys.covid_survey_detail AS

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
      ,d.respondent_df_employee_number
      ,d.respondent_adp_associate_id
      ,d.respondent_preferred_name
      ,d.respondent_legal_entity_name
      ,d.respondent_primary_site
      ,d.respondent_primary_site_schoolid
      ,d.respondent_primary_site_school_level
      ,d.respondent_manager_df_employee_number
      ,NULL AS respondent_manager_adp_associate_id
      ,d.respondent_samaccountname
      ,d.respondent_manager_name
      ,d.respondent_manager_samaccountname
      ,w.job_name
FROM gabby.surveygizmo.survey_detail d
LEFT JOIN gabby.dayforce.employee_work_assignment w
  ON d.respondent_df_employee_number = w.employee_reference_code
 AND d.date_submitted BETWEEN w.work_assignment_effective_start AND COALESCE(w.work_assignment_effective_end,GETDATE()+1)
 AND w.primary_work_assignment = 1
WHERE d.survey_title = 'COVID-19 Survey'
  AND d.rn_respondent_subject = 1
  AND d.campaign_academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()