CREATE OR ALTER VIEW
  surveys.cmo_engagement_regional_survey_detail AS
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
  w.home_department AS respondent_department_name,
  w.business_unit AS respondent_legal_entity_name,
  d.respondent_manager_name,
  w.job_title AS respondent_primary_job,
  w.[location] AS respondent_primary_site,
  s.race_ethnicity_reporting AS primary_ethnicity,
  s.gender_reporting AS gender,
  s.is_hispanic,
  s.is_race_asian,
  s.is_race_black,
  s.is_race_decline,
  s.is_race_mideast,
  s.is_race_multi,
  s.is_race_nhpi,
  s.is_race_other,
  s.is_race_white
FROM
  gabby.surveygizmo.survey_detail AS d
  LEFT JOIN gabby.people.employment_history_static AS w ON (
    d.respondent_df_employee_number = w.employee_number
    AND d.date_submitted BETWEEN w.effective_start_date AND COALESCE(
      w.effective_end_date,
      DATEFROMPARTS(
        (d.campaign_academic_year + 1),
        7,
        1
      )
    )
  )
  LEFT JOIN gabby.people.staff_roster AS s ON (
    d.respondent_df_employee_number = s.employee_number
  )
WHERE
  d.survey_id = 5300913
  AND d.rn_respondent_subject = 1
  AND w.position_status != 'Terminated'
UNION ALL
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
  d.respondent_department_name,
  d.respondent_legal_entity_name,
  d.respondent_manager_name,
  d.respondent_primary_job,
  d.respondent_primary_site,
  sr.race_ethnicity_reporting AS primary_ethnicity,
  sr.gender_reporting AS gender,
  sr.is_hispanic,
  sr.is_race_asian,
  sr.is_race_black,
  sr.is_race_decline,
  sr.is_race_mideast,
  sr.is_race_multi,
  sr.is_race_nhpi,
  sr.is_race_other,
  sr.is_race_white
FROM
  gabby.surveys.cmo_engagement_regional_survey_detail_archive AS d
  LEFT JOIN gabby.people.staff_roster AS sr ON (
    d.respondent_df_employee_number = sr.employee_number
  )
