USE gabby
GO

CREATE OR ALTER VIEW surveygizmo.survey_response_clean AS

SELECT sr.survey_id
      ,sr.id
      ,sr.date_started
      ,sr.date_submitted
      ,sr.response_time
      ,sr.status
      ,sr.contact_id
      
      ,nested.id AS response_id
      ,nested.type
      ,nested.question
      ,nested.shown
      ,nested.answer
FROM gabby.surveygizmo.survey_response sr
CROSS APPLY OPENJSON(survey_data, '$')
  WITH (
    id BIGINT,
    type VARCHAR(125),    
    question VARCHAR(MAX),
    shown BIT,
    answer VARCHAR(MAX)
   ) AS nested
WHERE sr.status = 'Complete'
  AND sr.is_test_data = 0