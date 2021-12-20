USE gabby
GO

CREATE OR ALTER VIEW surveygizmo.survey_response_data_current AS

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
FROM gabby.surveygizmo.survey_response_clean_current_static sr
CROSS APPLY OPENJSON(sr.survey_data_json, '$')
  WITH (
    id INT,
    section_id INT,
    answer_id VARCHAR(125),
    [type] VARCHAR(125),
    question NVARCHAR(512),
    answer NVARCHAR(MAX),
    options NVARCHAR(MAX) AS JSON,
    shown BIT
   ) AS sd
