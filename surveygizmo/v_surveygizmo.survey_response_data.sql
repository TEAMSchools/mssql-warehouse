USE gabby
GO

CREATE OR ALTER VIEW surveygizmo.survey_response_data AS

WITH responses AS (
  SELECT sr.id AS survey_response_id
        ,sr.survey_id
        ,sr.survey_data
        ,CONVERT(DATE, LEFT(date_started, 19)) AS date_started
        ,ROW_NUMBER() OVER(PARTITION BY sr.survey_id, sr.id ORDER BY sr._modified DESC) AS rn
  FROM gabby.surveygizmo.survey_response sr
 )

SELECT sr.survey_response_id
      ,sr.survey_id
      ,sr.date_started

      ,sd.id AS question_id
      ,sd.section_id
      ,sd.[type]
      ,sd.question
      ,sd.answer_id
      ,sd.answer
      ,sd.options
      ,sd.shown
FROM responses sr
CROSS APPLY OPENJSON(sr.survey_data, '$')
  WITH (
    id INT,
    section_id INT,
    answer_id VARCHAR(125),
    [type] VARCHAR(125),
    question VARCHAR(MAX),
    answer VARCHAR(MAX),
    options NVARCHAR(MAX) AS JSON,
    shown BIT
   ) AS sd
WHERE sr.rn = 1
