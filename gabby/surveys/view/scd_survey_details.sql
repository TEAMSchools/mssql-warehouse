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

,response_id_crosswalk AS (
    SELECT
        survey_id,
        survey_response_id,
        [student_number]
    FROM
        (
            SELECT
                question_shortname,
                answer,
                survey_id,
                survey_response_id
            FROM
                gabby.surveygizmo.survey_detail
            WHERE
                survey_id = 6829997
        ) AS sub PIVOT (
            MAX(answer) FOR question_shortname IN (
                  [student_number]
        ) ) p
   WHERE [student_number] IS NOT NULL
)

,shortname_crosswalk AS (
SELECT DISTINCT question_shortname, question_title,answer,answer_value 
FROM surveygizmo.survey_detail
WHERE survey_id = 6829997
AND question_shortname LIKE '%scd_%'


)

SELECT c.student_number
      ,c.student_web_id
      ,c.lastfirst
      ,c.academic_year
      ,c.cohort
      ,c.gender
      ,c.grade_level
      ,c.iep_status
      
      ,s.email_address
      ,s.answer
      ,s.question_shortname
      ,s.audience

      ,sh.question_title
      ,sh.answer
      
FROM powerschool.cohort_identifiers_static c
LEFT JOIN student_responses s
  ON CONCAT(c.student_web_id,'@teamstudents.org') = s.email_address
 AND c.academic_year >= 2021
LEFT JOIN shortname_crosswalk sh
  ON (sh.question_shortname = s.question_shortname) 
 AND (sh.answer_value = s.answer)
WHERE enroll_status = 0
 AND rn_year = 1
 AND c.academic_year IN (2022,2021)
 AND grade_level BETWEEN 4 AND 12

UNION ALL

SELECT c.student_number
      ,c.student_web_id
      ,c.lastfirst
      ,c.academic_year
      ,c.cohort
      ,c.gender
      ,c.grade_level
      ,c.iep_status
      
      ,s.email_address
      ,s.answer
      ,s.question_shortname
      ,s.audience

      ,sh.question_title
      ,sh.answer
      
FROM powerschool.cohort_identifiers_static c



