USE gabby
GO

CREATE OR ALTER VIEW extracts.gsheets_survey_completion AS

SELECT t.academic_year
      ,t.reporting_term
      ,t.survey_taker_id
      ,t.survey_round_open
      ,t.survey_round_close
      ,t.survey_completion_date 

      ,c.preferred_first_name
      ,c.preferred_last_name
      ,c.userprincipalname
      ,c.primary_site
      ,c.manager_name
      ,c.manager_mail

FROM gabby.surveys.survey_tracking t
JOIN gabby.people.staff_crosswalk_static c
  ON t.survey_taker_id = c.df_employee_number
WHERE CONVERT(DATE, GETDATE()) BETWEEN t.survey_round_open AND t.survey_round_close
AND c.[status] = 'Active'
