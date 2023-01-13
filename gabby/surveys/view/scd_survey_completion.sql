--CREATE OR ALTER VIEW scd_survey_completion AS

WITH student_responses AS (
SELECT email_address 
      ,[timestamp]
      ,gabby.utilities.DATE_TO_SY([timestamp]) AS survey_academic_year
FROM surveys.scds_responses
)

SELECT 
     c.student_web_id
    ,c.cohort
    ,c.lastfirst
    ,c.grade_level
    ,c.region
    ,c.reporting_school_name
    ,c.academic_year
    
    ,CASE
     WHEN c.grade_level BETWEEN 0 AND 3 THEN NULL
     WHEN c.grade_level BETWEEN 4 AND 12 AND s.[timestamp] IS NOT NULL THEN 1 
     ELSE 0 END AS student_completion
    ,NULL AS family_completion
    
FROM powerschool.cohort_identifiers_static c
LEFT JOIN student_responses s
  ON CONCAT(c.student_web_id,'@teamstudents.org') = s.email_address
 AND c.academic_year = s.survey_academic_year
WHERE c.enroll_status = 0
AND c.rn_year = 1
AND c.academic_year >= 2021

