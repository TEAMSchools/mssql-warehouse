CREATE OR ALTER VIEW
  surveygizmo.survey_response_data_current AS
SELECT
  survey_response_id,
  survey_id,
  date_started,
  CAST(
    JSON_VALUE(survey_data_json, '$.id') AS INT
  ) AS question_id,
  CAST(
    JSON_VALUE(survey_data_json, '$.section_id') AS INT
  ) AS section_id,
  CAST(
    JSON_VALUE(survey_data_json, '$.answer_id') AS NVARCHAR(125)
  ) AS answer_id,
  CAST(
    JSON_VALUE(survey_data_json, '$.type') AS NVARCHAR(125)
  ) AS [type],
  CAST(
    JSON_VALUE(survey_data_json, '$.question') AS NVARCHAR(512)
  ) AS question,
  CAST(
    JSON_VALUE(survey_data_json, '$.answer') AS NVARCHAR(MAX)
  ) AS answer,
  CAST(
    JSON_VALUE(survey_data_json, '$.shown') AS BIT
  ) AS shown,
  JSON_QUERY(survey_data_json, '$.options') AS options,
  JSON_QUERY(
    survey_data_json,
    '$.options_list'
  ) AS options_list
FROM
  gabby.surveygizmo.survey_response_clean_current_static
