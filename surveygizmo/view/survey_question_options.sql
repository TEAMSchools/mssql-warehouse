CREATE OR ALTER VIEW
  surveygizmo.survey_question_options AS
SELECT
  q.id AS question_id,
  q.survey_id,
  o.id AS option_id,
  o.[value] AS option_value,
  JSON_VALUE(o.title, '$.English') AS option_title_english,
  CAST(
    JSON_VALUE(o.properties, '$.disabled') AS BIT
  ) AS option_disabled,
  JSON_QUERY(o.properties, '$."left-label".English') AS option_left_label_english,
  JSON_QUERY(o.properties, '$."right-label".English') AS option_right_label_english
FROM
  gabby.surveygizmo.survey_question AS q
  CROSS APPLY OPENJSON (q.options, '$')
WITH
  (
    id VARCHAR(25),
    [value] VARCHAR(500),
    title NVARCHAR(MAX) AS JSON,
    properties NVARCHAR(MAX) AS JSON
  ) AS o
WHERE
  q.options != '[]'
