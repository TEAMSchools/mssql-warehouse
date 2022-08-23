USE gabby
GO

CREATE OR ALTER VIEW extracts.gsheets_survey_completion AS

WITH incomplete_surveys AS (
  SELECT academic_year
        ,reporting_term
        ,survey_taker_id
        ,survey_round_open
        ,survey_round_close
        ,survey_completion_date 
        ,survey_id
        /*Ordering surveys by term (most recent campaign) and staff updates by completion date for row numbering, to filter out complete staff updates from prior campaigns*/
        ,CASE
         WHEN survey_id <> '6330385'
         THEN ROW_NUMBER() OVER(
           PARTITION BY survey_taker_id
             ORDER BY reporting_term) 
         ELSE ROW_NUMBER() OVER(
           PARTITION BY survey_taker_id
             ORDER BY survey_completion_date DESC) 
         END AS rn_null
  FROM gabby.surveys.survey_tracking t
  WHERE survey_id = '6330385' 
     OR (survey_completion_date IS NULL AND CONVERT(DATE, GETDATE()) BETWEEN survey_round_open AND survey_round_close)
)

SELECT i.academic_year
      ,i.reporting_term
      ,i.survey_taker_id
      ,i.survey_round_open
      ,i.survey_round_close
      ,i.survey_completion_date 
      ,i.survey_id

      ,c.preferred_first_name
      ,c.preferred_last_name
      ,c.userprincipalname
      ,c.primary_site
      ,c.manager_name
      ,c.manager_mail
      ,GETDATE() AS date_of_extract

FROM incomplete_surveys i
INNER JOIN gabby.people.staff_crosswalk_static c
  ON i.survey_taker_id = c.df_employee_number
WHERE rn_null = 1
  AND survey_completion_date IS NULL