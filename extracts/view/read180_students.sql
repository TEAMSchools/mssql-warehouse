CREATE OR ALTER VIEW
  extracts.read180_students AS
SELECT
  co.student_web_id AS [USER_NAME],
  NULL AS [PASSWORD],
  co.student_number AS [SIS_ID],
  co.first_name AS [FIRST_NAME],
  NULL AS [MIDDLE_NAME],
  co.last_name AS [LAST_NAME],
  /* PK, K, 1-12 */
  CASE
    WHEN co.grade_level = 0 THEN 'K'
    ELSE CAST(co.grade_level AS VARCHAR(2))
  END AS [GRADE],
  s.[name] AS [SCHOOL_NAME],
  CONCAT(
    enr.course_number,
    '.',
    UPPER(enr.section_number)
  ) AS [CLASS_NAME],
  NULL AS [LEXILE_SCORE],
  NULL AS [LEXILE_MOD_DATE],
  NULL AS [ETHNIC_CAUCASIAN],
  NULL AS [ETHNIC_AFRICAN_AM],
  NULL AS [ETHNIC_HISPANIC],
  NULL AS [ETHNIC_PACIFIC_ISL],
  NULL AS [ETHNIC_AM_IND_AK_NATIVE],
  NULL AS [ETHNIC_ASIAN],
  NULL AS [ETHNIC_TWO_OR_MORE_RACES],
  NULL AS [GENDER_MALE],
  NULL AS [GENDER_FEMALE],
  NULL AS [AYP_ECON_DISADVANTAGED],
  NULL AS [AYP_LTD_ENGLISH_PROFICIENCY],
  NULL AS [AYP_GIFTED_TALENTED],
  NULL AS [AYP_MIGRANT],
  NULL AS [AYP_WITH_DISABILITIES],
  co.student_web_id + '@teamstudents.org' AS [EXTERNAL_ID]
FROM
  gabby.powerschool.cohort_identifiers_static AS co
  INNER JOIN gabby.powerschool.course_enrollments_current_static AS enr ON co.student_number = enr.student_number /* trunk-ignore(sqlfluff/L016) */
  AND co.academic_year = enr.academic_year
  AND co.[db_name] = enr.[db_name]
  AND enr.course_number IN ('ELA01068G1', 'MAT02999G1')
  AND enr.course_enroll_status = 0
  AND enr.section_enroll_status = 0
  INNER JOIN gabby.powerschool.schools AS s ON co.schoolid = s.school_number
  AND co.[db_name] = s.[db_name]
WHERE
  co.rn_year = 1
  AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.school_level = 'HS'
