USE gabby
GO

CREATE OR ALTER VIEW surveygizmo.survey_question_clean AS

SELECT sq.survey_id
      ,sq.id AS question_id
      ,sq.type AS question_type
      ,sq.shortname AS question_shortname
      
      ,nested.English AS question
FROM gabby.surveygizmo.survey_question sq
CROSS APPLY OPENJSON(title, '$')
  WITH (  
    English VARCHAR(MAX)
   ) AS nested