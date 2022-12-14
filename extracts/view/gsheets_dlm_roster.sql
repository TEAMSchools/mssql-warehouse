USE gabby GO
CREATE OR ALTER VIEW
  extracts.gsheets_dlm_roster AS
WITH
  roster AS (
    SELECT
      co.student_number,
      co.state_studentnumber,
      co.first_name,
      co.last_name,
      co.academic_year,
      co.region,
      co.schoolid,
      co.school_name,
      co.grade_level,
      nj.state_assessment_name,
      nj.math_state_assessment_name
    FROM
      gabby.powerschool.cohort_identifiers_static co
      JOIN gabby.powerschool.s_nj_stu_x nj ON co.students_dcid = nj.studentsdcid
      AND co.[db_name] = nj.[db_name]
      AND (
        nj.state_assessment_name IN (3, 4)
        OR nj.math_state_assessment_name = 3
      )
    WHERE
      co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
      AND co.rn_year = 1
      AND (
        co.grade_level
        --BETWEEN 3 AND 8
        OR co.grade_level = 11
      )
  )
SELECT
  r.region,
  r.schoolid,
  r.grade_level,
  CONCAT(
    r.school_name,
    ' ',
    LEFT(
      ce.teacher_name,
      CHARINDEX(',', ce.teacher_name) - 1
    ),
    ' ELA'
  ) AS [Roster Name],
  'ELA' AS [Subject],
  NULL AS [Course],
  807325965 AS [School Identifier],
  r.academic_year + 1 AS [School Year],
  r.state_studentnumber AS [State Student Identifier],
  r.student_number AS [Local Student Identifier],
  r.first_name AS [Student Legal First Name],
  r.last_name AS [Student Legal Last Name],
  ce.teachernumber AS [Educator Identifier],
  RIGHT(
    ce.teacher_name,
    LEN(ce.teacher_name) - CHARINDEX(',', ce.teacher_name) - 1
  ) AS [Educator First Name],
  LEFT(
    ce.teacher_name,
    CHARINDEX(',', ce.teacher_name) - 1
  ) AS [Educator Last Name],
  NULL AS [Remove from Roster]
FROM
  roster r
  JOIN gabby.powerschool.course_enrollments_current_static ce ON r.student_number = ce.student_number
  AND r.academic_year = ce.academic_year
  AND ce.course_enroll_status = 0
  AND ce.section_enroll_status = 0
  AND ce.credittype = 'ENG'
WHERE
  r.state_assessment_name IS NOT NULL
UNION ALL
SELECT
  r.region,
  r.schoolid,
  r.grade_level,
  CONCAT(
    r.school_name,
    ' ',
    LEFT(
      ce.teacher_name,
      CHARINDEX(',', ce.teacher_name) - 1
    ),
    ' Math'
  ) AS [Roster Name],
  'M' AS [Subject],
  NULL AS [Course],
  807325965 AS [School Identifier],
  r.academic_year AS [School Year],
  r.state_studentnumber AS [State Student Identifier],
  r.student_number AS [Local Student Identifier],
  r.first_name AS [Student Legal First Name],
  r.last_name AS [Student Legal Last Name],
  ce.teachernumber AS [Educator Identifier],
  RIGHT(
    ce.teacher_name,
    LEN(ce.teacher_name) - CHARINDEX(',', ce.teacher_name) - 1
  ) AS [Educator First Name],
  LEFT(
    ce.teacher_name,
    CHARINDEX(',', ce.teacher_name) -1
  ) AS [Educator Last Name],
  NULL AS [Remove from Roster]
FROM
  roster r
  JOIN powerschool.course_enrollments_current_static ce ON r.student_number = ce.student_number
  AND r.academic_year = ce.academic_year
  AND ce.course_enroll_status = 0
  AND ce.section_enroll_status = 0
  AND ce.credittype = 'MATH'
WHERE
  r.math_state_assessment_name IS NOT NULL
