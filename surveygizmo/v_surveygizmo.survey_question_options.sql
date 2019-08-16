USE gabby
GO

CREATE OR ALTER VIEW surveygizmo.survey_question_options AS

SELECT q.id AS question_id
      ,q.survey_id

      ,o.id AS option_id
      ,o.value
      ,JSON_VALUE(o.title, '$.English') AS title_english
      ,CONVERT(BIT, JSON_VALUE(o.properties, '$.disabled')) AS [disabled]
      ,JSON_QUERY(o.properties, '$."left-label".English') AS left_label_english
      ,JSON_QUERY(o.properties, '$."right-label".English') AS right_label_english
FROM gabby.surveygizmo.survey_question q
CROSS APPLY OPENJSON(q.options, '$')
  WITH (
    id INT,
    value NVARCHAR(MAX),
    title NVARCHAR(MAX) AS JSON,
    properties NVARCHAR(MAX) AS JSON
   ) AS o
WHERE q.options != '[]'