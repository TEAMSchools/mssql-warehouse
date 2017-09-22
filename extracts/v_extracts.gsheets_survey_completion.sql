USE gabby
GO

CREATE OR ALTER VIEW extracts.gsheets_survey_completion AS

SELECT survey
      ,feedback_recipient
      ,responder
      ,CONVERT(NVARCHAR,date_completed) AS date_completed
FROM gabby.surveys.survey_completion