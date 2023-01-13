--CREATE OR ALTER VIEW scd_survey_details AS

WITH student_responses AS (
SELECT email_address
      ,gabby.utilities.DATE_TO_SY([timestamp]) AS academic_year
      ,answer
      ,question_shortname
      ,'Student' AS audience
FROM surveys.scds_responses
UNPIVOT (answer FOR question_shortname IN (
         scd_1,
         scd_2,
         scd_3,
         scd_4,
         scd_5,
         scd_6,
         scd_7,
         scd_8,
         scd_9,
         scd_10
                )
              ) u
)

SELECT c.student_web_id
      ,c.lastfirst
      ,c.academic_year
      ,c.cohort

      ,s.email_address
      ,s.answer
      ,s.question_shortname
      ,s.audience

      
FROM powerschool.cohort_identifiers_static c
LEFT JOIN student_responses s
  ON CONCAT(c.student_web_id,'@teamstudents.org') = s.email_address
 AND c.academic_year >= 2021
WHERE enroll_status = 0
 AND rn_year = 1
 AND c.academic_year IN (2022,2021)
 AND grade_level BETWEEN 4 AND 12
