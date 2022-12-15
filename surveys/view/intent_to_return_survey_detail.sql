USE gabby GO
CREATE OR ALTER VIEW
  surveys.intent_to_return_survey_detail AS
SELECT
  d.survey_id,
  d.survey_title,
  d.survey_response_id,
  d.campaign_academic_year,
  d.date_started,
  d.date_submitted,
  d.campaign_name,
  d.campaign_reporting_term,
  d.is_open_ended,
  d.question_shortname,
  d.question_title,
  d.answer,
  d.answer_value,
  d.respondent_df_employee_number,
  d.respondent_preferred_name,
  d.respondent_mail,
  d.is_manager,
  d.respondent_df_employee_number AS subject_df_employee_number,
  d.respondent_adp_associate_id AS subject_adp_associate_id,
  d.respondent_preferred_name AS subject_preferred_name,
  d.respondent_primary_site_schoolid AS subject_primary_site_schoolid,
  d.respondent_primary_site_school_level AS subject_primary_site_school_level,
  d.respondent_manager_df_employee_number AS subject_manager_df_employee_number,
  NULL AS subject_manager_adp_associate_id,
  d.respondent_samaccountname AS subject_samaccountname,
  d.respondent_manager_name AS subject_manager_name,
  d.respondent_manager_samaccountname AS subject_manager_samaccountname,
  s.legal_entity_name AS subject_legal_entity_name,
  s.primary_site AS subject_primary_site,
  s.primary_race_ethnicity_reporting AS subject_primary_race_ethnicity,
  s.gender AS subject_gender,
  w.home_department_description AS subject_department_name,
  w.job_title_description AS subject_dayforce_role
FROM
  gabby.surveygizmo.survey_detail AS d
  LEFT JOIN gabby.people.work_assignment_history_static AS w ON d.respondent_df_employee_number = w.employee_number
  AND d.date_submitted (
    BETWEEN w.position_effective_date AND w.position_effective_end_date_eoy
  )
  LEFT JOIN gabby.people.staff_crosswalk_static AS s ON d.respondent_df_employee_number = s.df_employee_number
WHERE
  d.survey_title = 'Intent to Return'
  AND d.rn_respondent_subject = 1
