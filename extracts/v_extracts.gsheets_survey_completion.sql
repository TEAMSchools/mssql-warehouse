USE gabby
GO
CREATE OR ALTER VIEW extracts.gsheets_survey_completion AS

SELECT academic_year
      ,reporting_term
      ,survey_taker_id
      ,survey_taker_name
      ,survey_taker_location
      ,manager_name
      ,survey_round_open
      ,survey_round_close
      ,survey_completion_date 
FROM gabby.surveys.survey_tracking 
WHERE CONVERT(DATE,GETDATE()) BETWEEN survey_round_open AND survey_round_close