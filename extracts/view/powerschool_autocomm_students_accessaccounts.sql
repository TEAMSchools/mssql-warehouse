CREATE OR ALTER VIEW
  extracts.powerschool_autocomm_students_accessaccounts AS
SELECT
  co.student_number,
  co.student_web_id,
  co.student_web_password,
  CASE
    WHEN co.enroll_status = 0 THEN 1
    ELSE 0
  END AS student_allowwebaccess,
  co.student_web_id + '.fam' AS web_id,
  co.student_web_password AS web_password,
  CASE
    WHEN co.enroll_status = 0 THEN 1
    ELSE 0
  END AS allowwebaccess,
  co.team,
  CASE
    WHEN co.grade_level IN (0, 5, 9) THEN 'A'
    WHEN co.grade_level IN (1, 6, 10) THEN 'B'
    WHEN co.grade_level IN (2, 7, 11) THEN 'C'
    WHEN co.grade_level IN (3, 8, 12) THEN 'D'
    WHEN co.grade_level = 4 THEN 'E'
  END AS track,
  co.lunchstatus AS eligibility_name,
  co.lunch_balance AS total_balance,
  co.advisor_name AS home_room,
  gabby.utilities.GLOBAL_ACADEMIC_YEAR () + (13 - co.grade_level) AS graduation_year,
  CONVERT(
    VARCHAR,
    de.district_entry_date,
    101
  ) AS district_entry_date,
  CONVERT(
    VARCHAR,
    de.district_entry_date,
    101
  ) AS school_entry_date,
  co.[db_name]
FROM
  gabby.powerschool.cohort_identifiers_static AS co
  LEFT JOIN gabby.powerschool.district_entry_date AS de ON (
    co.studentid = de.studentid
    AND co.[db_name] = de.[db_name]
    AND de.rn_entry = 1
  )
WHERE
  co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.rn_year = 1
  AND co.grade_level != 99
