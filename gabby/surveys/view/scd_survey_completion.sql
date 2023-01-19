CREATE OR ALTER VIEW
  scd_survey_completion AS
WITH
  student_responses AS (
    SELECT
      email_address,
      gabby.utilities.DATE_TO_SY ([timestamp]) AS survey_academic_year
    FROM
      gabby.surveys.scds_responses
    GROUP BY
      email_address,
      [timestamp]
  ),
  family_responses AS (
    SELECT
      student_email,
      gabby.utilities.DATE_TO_SY (date_submitted) AS survey_academic_year
    FROM
      (
        SELECT
          question_shortname,
          answer,
          date_submitted
        FROM
          gabby.surveygizmo.survey_detail
        WHERE
          survey_id = 6829997
      ) AS sub PIVOT (
        MAX(answer) FOR question_shortname IN ([student_email])
      ) AS p
  )
SELECT
  c.student_web_id,
  c.cohort,
  c.lastfirst,
  c.grade_level,
  c.region,
  c.reporting_school_name,
  c.academic_year,
  CASE
    WHEN s.survey_academic_year IS NOT NULL THEN 1
    ELSE 0
  END AS student_completion,
  CASE
    WHEN f.survey_academic_year IS NOT NULL THEN 1
    ELSE 0
  END AS family_completion
FROM
  gabby.powerschool.cohort_identifiers_static AS c
  LEFT JOIN student_responses AS s ON (
    CONCAT(
      c.student_web_id,
      '@teamstudents.org'
    ) = s.email_address
  )
  AND c.academic_year = s.survey_academic_year
  LEFT JOIN family_responses AS f ON (
    CONCAT(
      c.student_web_id,
      '@teamstudents.org'
    ) = f.student_email
  )
WHERE
  c.enroll_status = 0
  AND c.rn_year = 1
  AND c.academic_year >= 2021
