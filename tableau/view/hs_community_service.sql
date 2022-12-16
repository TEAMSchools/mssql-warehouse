CREATE OR ALTER VIEW
  tableau.hs_community_service AS
SELECT
  co.student_number,
  co.academic_year,
  co.lastfirst,
  co.gender,
  co.ethnicity,
  co.iep_status,
  co.lep_status,
  co.c_504_status,
  co.grade_level,
  co.cohort,
  co.advisor_name,
  co.guardianemail,
  CONCAT(co.student_web_id, '@teamstudents.org') AS student_email,
  sch.[name] AS school_name,
  b.behavior_date,
  b.behavior,
  b.notes,
  CONCAT(b.staff_last_name, ', ', b.staff_first_name) AS staff_name,
  CAST(
    LEFT(b.behavior, LEN(b.behavior) - 5) AS INT
  ) AS cs_hours
FROM
  gabby.powerschool.cohort_identifiers_static AS co
  LEFT JOIN gabby.powerschool.schools AS sch ON co.schoolid = sch.school_number
  AND co.[db_name] = sch.[db_name]
  LEFT JOIN gabby.deanslist.behavior AS b ON co.student_number = b.student_school_id
  AND co.[db_name] = b.[db_name]
  AND b.behavior_category = 'Community Service'
  AND (
    b.behavior_date BETWEEN co.entrydate AND co.exitdate
  )
WHERE
  co.grade_level >= 9
  AND co.enroll_status = 0
  AND co.rn_year = 1
