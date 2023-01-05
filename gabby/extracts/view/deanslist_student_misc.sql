CREATE OR ALTER VIEW
  extracts.deanslist_student_misc AS
WITH
  ug_school AS (
    SELECT
      student_number,
      schoolid,
      [db_name]
    FROM
      powerschool.cohort_identifiers_static
    WHERE
      rn_undergrad = 1
      AND grade_level != 99
  ),
  enroll_dates AS (
    SELECT
      student_number,
      schoolid,
      [db_name],
      MIN(entrydate) AS school_entrydate,
      MAX(exitdate) AS school_exitdate
    FROM
      powerschool.cohort_identifiers_static
    GROUP BY
      student_number,
      schoolid,
      [db_name]
  )
SELECT
  co.student_number,
  co.state_studentnumber AS [SID],
  co.team,
  co.home_phone,
  co.mother AS parent1_name,
  co.father AS parent2_name,
  co.guardianemail,
  co.academic_year,
  co.mother_cell AS parent1_cell,
  co.father_cell AS parent2_cell,
  co.advisor_name,
  co.advisor_email,
  co.lunch_balance,
  co.dob,
  co.student_web_id + '.fam' AS family_access_id,
  co.student_web_id + '@teamstudents.org' AS student_email,
  CONCAT(co.student_web_password, 'kipp') AS student_web_password,
  CONCAT(
    co.street,
    ', ',
    co.city,
    ', ',
    co.[state],
    ' ',
    co.zip
  ) AS home_address,
  CASE
    WHEN co.enroll_status = -1 THEN 'Pre-Registered'
    WHEN co.enroll_status = 0 THEN 'Enrolled'
    WHEN co.enroll_status = 1 THEN 'Inactive'
    WHEN co.enroll_status = 2 THEN 'Transferred Out'
    WHEN co.enroll_status = 3 THEN 'Graduated'
  END AS enroll_status,
  s.sched_nextyeargrade,
  ed.school_entrydate,
  ed.school_exitdate,
  ktc.counselor_name AS ktc_counselor_name,
  ktc.counselor_phone AS ktc_counselor_phone,
  ktc.counselor_email AS ktc_counselor_email,
  gpa.[GPA_Y1],
  gpa.gpa_term
FROM
  powerschool.cohort_identifiers_static AS co
  INNER JOIN powerschool.students AS s ON (
    co.student_number = s.student_number
    AND co.[db_name] = s.[db_name]
  )
  INNER JOIN ug_school AS ug ON (
    co.student_number = ug.student_number
    AND co.[db_name] = ug.[db_name]
  )
  LEFT JOIN enroll_dates AS ed ON (
    co.student_number = ed.student_number
    AND co.[db_name] = ed.[db_name]
    AND (
      CASE
        WHEN co.schoolid = 999999 THEN ug.schoolid
        ELSE co.schoolid
      END
    ) = ed.schoolid
  )
  LEFT JOIN alumni.ktc_roster AS ktc ON (
    co.student_number = ktc.student_number
  )
  LEFT JOIN powerschool.gpa_detail AS gpa ON (
    co.student_number = gpa.student_number
    AND co.academic_year = gpa.academic_year
    AND co.[db_name] = gpa.[db_name]
    AND gpa.is_curterm = 1
  )
WHERE
  co.academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.rn_year = 1
