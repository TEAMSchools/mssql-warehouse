CREATE OR ALTER VIEW
  surveygizmo.survey_question_options AS
WITH
  options AS (
    SELECT
      q.id AS question_id,
      q.survey_id,
      CAST(
        JSON_VALUE(o.[value], '$.id') AS NVARCHAR(32)
      ) AS option_id,
      CAST(
        JSON_VALUE(o.[value], '$.value') AS NVARCHAR(512)
      ) AS option_value,
      JSON_QUERY(o.[value], '$.title') AS title,
      JSON_QUERY(o.[value], '$.properties') AS properties
    FROM
      surveygizmo.survey_question AS q
      CROSS APPLY OPENJSON (q.options, '$') AS o
    WHERE
      q.options != '[]'
  )
SELECT
  question_id,
  survey_id,
  option_id,
  option_value,
  JSON_VALUE(title, '$.English') AS option_title_english,
  CAST(
    JSON_VALUE(properties, '$.disabled') AS BIT
  ) AS option_disabled,
  JSON_VALUE(
    properties,
    '$."left-label".English'
  ) AS option_left_label_english,
  JSON_VALUE(
    properties,
    '$."right-label".English'
  ) AS option_right_label_english
FROM
  options
