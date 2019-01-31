USE gabby
GO

CREATE OR ALTER VIEW extracts.gsheets_survey_completion AS

SELECT sc.survey_type
      ,sc.subject_name
      ,sc.responder_email
      ,sc.date_created AS date_completed
FROM gabby.surveys.survey_completion sc
WHERE sc.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()