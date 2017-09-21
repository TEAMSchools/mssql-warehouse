USE gabby
GO

CREATE OR ALTER VIEW surveys.survey_completion AS

SELECT _created AS date_completed
      ,email AS responder
      ,subject_name AS feedback_recipient
      ,'Self & Others' AS survey
FROM gabby.surveys.self_and_others_survey

UNION ALL

SELECT _created AS date_completed
      ,responder_name AS responder
      ,subject_name AS feedback_recipient
      ,'Manager' AS survey	
FROM gabby.surveys.manager_survey