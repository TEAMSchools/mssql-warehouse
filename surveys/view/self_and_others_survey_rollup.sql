USE gabby GO
CREATE OR ALTER VIEW
  surveys.self_and_others_survey_rollup AS
SELECT
  survey_title AS survey_type,
  campaign_academic_year AS academic_year,
  campaign_reporting_term AS reporting_term,
  campaign_name AS term_name,
  subject_df_employee_number AS subject_employee_number,
  subject_preferred_name AS subject_name,
  subject_primary_site AS subject_location,
  subject_legal_entity_name,
  subject_primary_site_schoolid,
  subject_primary_site_school_level,
  subject_manager_df_employee_number AS subject_manager_id,
  subject_samaccountname AS subject_username,
  subject_manager_name,
  subject_manager_samaccountname AS subject_manager_username,
  question_shortname AS question_code,
  question_title AS question_text,
  ROUND(AVG(answer_value), 1) AS avg_response_value,
  SUM(answer_weight) AS total_response_weight,
  SUM(answer_value_weighted) AS total_weighted_response_value,
  ROUND(
    SUM(answer_value_weighted) / SUM(answer_weight),
    1
  ) AS avg_weighted_response_value,
  NULL AS avg_response_value_location
FROM
  gabby.surveys.self_and_others_survey_detail
WHERE
  is_open_ended = 'N'
GROUP BY
  survey_title,
  campaign_academic_year,
  campaign_reporting_term,
  campaign_name,
  subject_df_employee_number,
  subject_preferred_name,
  subject_primary_site,
  subject_legal_entity_name,
  subject_primary_site_schoolid,
  subject_primary_site_school_level,
  subject_manager_df_employee_number,
  subject_samaccountname,
  subject_manager_name,
  subject_manager_samaccountname,
  question_shortname,
  question_title
