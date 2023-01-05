CREATE OR ALTER VIEW
  surveygizmo.survey_response_data_options AS
SELECT
  survey_id,
  survey_response_id,
  question_id,
  option_id,
  option_name,
  answer
FROM
  surveygizmo.survey_response_data_options_current_static
UNION ALL
SELECT
  survey_id,
  survey_response_id,
  question_id,
  option_id,
  option_name,
  answer
FROM
  surveygizmo.survey_response_data_options_archive
