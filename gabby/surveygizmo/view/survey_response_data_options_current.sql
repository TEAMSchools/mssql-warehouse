CREATE OR ALTER VIEW
  surveygizmo.survey_response_data_options_current AS
SELECT
  srd.survey_id,
  srd.survey_response_id,
  srd.question_id,
  CAST(
    JSON_VALUE(ol.[value], '$.id') AS NVARCHAR(16)
  ) AS option_id,
  CAST(
    JSON_VALUE(ol.[value], '$.option') AS NVARCHAR(128)
  ) AS option_name,
  CAST(
    JSON_VALUE(ol.[value], '$.answer') AS NVARCHAR(128)
  ) AS answer
FROM
  gabby.surveygizmo.survey_response_data_current_static AS srd
  CROSS APPLY OPENJSON (srd.options_list, '$') AS ol
WHERE
  srd.options_list IS NOT NULL
