CREATE OR ALTER VIEW
  surveys.school_community_diagnostic AS
WITH
  student_responses AS (
    SELECT
      email_address,
      gabby.utilities.DATE_TO_SY ([timestamp]) AS academic_year,
      answer,
      question_shortname,
      'Student' AS audience
    FROM
      surveys.scds_responses UNPIVOT (
        answer FOR question_shortname IN (
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
  ),
  response_id_crosswalk AS (
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
        MAX(answer) FOR question_shortname IN ([student_number])
      ) p
    WHERE
      [student_number] IS NOT NULL
  ),
  shortname_crosswalk AS (
    SELECT DISTINCT
      question_shortname,
      question_title,
      answer,
      answer_value
    FROM
      surveygizmo.survey_detail
    WHERE
      survey_id = 6829997
      AND question_shortname LIKE '%scd_%'
      AND answer IS NOT NULL
  ),
  grade AS (
    SELECT
      employee_number,
      MAX(student_grade_level) AS student_grade_level
    FROM
      pm.teacher_grade_levels
    WHERE
      academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
    GROUP BY
      employee_number
  )
SELECT
  c.student_number,
  c.student_web_id,
  c.lastfirst,
  c.academic_year,
  c.cohort,
  c.gender,
  c.grade_level,
  c.iep_status,
  c.school_name,
  c.school_level,
  s.email_address,
  s.answer AS answer_value,
  s.question_shortname,
  s.audience,
  sh.question_title,
  sh.answer AS answer_text,
  x.region
FROM
  student_responses AS s
  LEFT JOIN powerschool.cohort_identifiers_static AS c ON CONCAT(
    c.student_web_id,
    '@teamstudents.org'
  ) = s.email_address
  AND c.academic_year >= 2021
  LEFT JOIN shortname_crosswalk AS sh ON (
    sh.question_shortname = s.question_shortname
  )
  AND (sh.answer_value = s.answer)
  LEFT JOIN people.school_crosswalk AS x ON (c.school_name = x.site_name)
WHERE
  c.enroll_status = 0
  AND c.rn_year = 1
  AND c.academic_year >= 2021
  AND c.grade_level BETWEEN 4 AND 12
UNION ALL
SELECT
  c.student_number,
  c.student_web_id,
  c.lastfirst,
  c.academic_year,
  c.cohort,
  c.gender,
  c.grade_level,
  c.iep_status,
  c.school_name,
  c.school_level,
  d.respondent_userprincipalname,
  d.answer_value,
  d.question_shortname,
  'Family' AS audience,
  d.question_title,
  d.answer AS answer_text,
  x.region
FROM
  surveygizmo.survey_detail AS d
  LEFT JOIN response_id_crosswalk AS r ON (
    r.survey_id = d.survey_id
    AND r.survey_response_id = d.survey_response_id
  )
  -- trunk-ignore(sqlfluff/LT05)
  LEFT JOIN powerschool.cohort_identifiers_static AS c ON c.student_number = r.student_number
  LEFT JOIN people.school_crosswalk AS x ON (c.school_name = x.site_name)
WHERE
  c.enroll_status = 0
  AND c.rn_year = 1
  AND c.academic_year >= 2021
UNION ALL
SELECT
  NULL AS student_number,
  NULL AS student_web_id,
  d.respondent_preferred_name AS lastfirst,
  d.campaign_academic_year AS academic_year,
  NULL AS cohort,
  x.gender AS gender,
  g.student_grade_level AS grade_level,
  NULL AS iep_status,
  d.respondent_primary_site,
  x.primary_site_school_level AS school_level,
  d.respondent_userprincipalname,
  d.answer_value,
  d.question_shortname,
  'Staff' AS audience,
  d.question_title,
  d.answer AS answer_text,
  x.legal_entity_name
FROM
  surveygizmo.survey_detail AS d
  LEFT JOIN people.staff_crosswalk_static AS x ON (
    d.respondent_df_employee_number = x.df_employee_number
  )
  LEFT JOIN grade AS g ON (
    x.df_employee_number = g.employee_number
  )
WHERE
  d.question_shortname LIKE '%scd%'
  AND d.campaign_academic_year >= 2021
