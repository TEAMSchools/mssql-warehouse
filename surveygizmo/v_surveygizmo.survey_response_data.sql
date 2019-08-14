USE gabby
GO

CREATE OR ALTER VIEW surveygizmo.survey_response_data AS

SELECT sr.id AS survey_response_id
      ,sr.survey_id

      ,sd.id AS question_id
      ,sd.section_id
      ,sd.[type]
      ,sd.question
      ,sd.answer_id
      ,sd.answer
      ,sd.shown
FROM gabby.surveygizmo.survey_response sr
CROSS APPLY OPENJSON(sr.survey_data, '$')
  WITH (
    id INT,
    section_id INT,
    answer_id VARCHAR(125),
    [type] VARCHAR(125),
    question VARCHAR(MAX),
    answer VARCHAR(MAX),
    shown BIT
   ) AS sd