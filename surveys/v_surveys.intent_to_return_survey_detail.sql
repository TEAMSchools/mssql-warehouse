USE gabby
GO

CREATE OR ALTER VIEW surveys.intent_to_return_survey_detail AS

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
      ,d.respondent_df_employee_number AS subject_df_employee_number
      ,d.respondent_adp_associate_id AS subject_adp_associate_id
      ,d.respondent_preferred_name AS subject_preferred_name
      ,s.legal_entity_name AS subject_legal_entity_name
      ,s.primary_site AS subject_primary_site
      ,d.respondent_primary_site_schoolid AS subject_primary_site_schoolid
      ,d.respondent_primary_site_school_level AS subject_primary_site_school_level
      ,d.respondent_manager_df_employee_number AS subject_manager_df_employee_number
      ,NULL AS subject_manager_adp_associate_id
      ,d.respondent_samaccountname AS subject_samaccountname
      ,d.respondent_manager_name AS subject_manager_name
      ,d.respondent_manager_samaccountname AS subject_manager_samaccountname
      ,w.department_name AS subject_department_name
      ,w.job_name AS subject_dayforce_role
      ,s.primary_race_ethnicity_reporting AS subject_primary_race_ethnicity
      ,s.gender AS subject_gender
FROM gabby.surveygizmo.survey_detail d
LEFT JOIN gabby.dayforce.employee_work_assignment w
  ON d.respondent_df_employee_number = w.employee_reference_code
 AND d.date_submitted BETWEEN w.work_assignment_effective_start AND COALESCE(w.work_assignment_effective_end,DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR()+1,6,30))
 AND w.primary_work_assignment = 1
LEFT JOIN gabby.people.staff_crosswalk_static s
  ON d.respondent_df_employee_number = s.df_employee_number
WHERE d.survey_title = 'Intent to Return'
  AND d.rn_respondent_subject = 1
