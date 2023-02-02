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
      email,
      gabby.utilities.DATE_TO_SY (date_started) AS survey_academic_year
    FROM
      (
        SELECT
          rd.survey_response_id,
          rd.survey_id,
          rd.date_started,
          qc.shortname,
          rd.answer
        FROM
          surveygizmo.survey_response_data rd
          JOIN surveygizmo.survey_question_clean_static qc ON (rd.survey_id = qc.survey_id)
          AND (
            rd.question_id = qc.survey_question_id
          )
        WHERE
          rd.survey_id = 6829997
      ) AS sub PIVOT (
        MAX(answer) FOR [shortname] IN ([email])
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
    ) = f.email
    AND c.academic_year = f.survey_academic_year
  )
WHERE
  c.enroll_status = 0
  AND c.rn_year = 1
  AND c.academic_year >= 2021
