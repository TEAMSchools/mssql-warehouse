USE gabby GO
CREATE OR ALTER VIEW
  compliance.student_membership AS
SELECT
  co.student_number,
  co.state_studentnumber,
  co.academic_year,
  co.region,
  co.school_name,
  co.grade_level,
  co.iep_status,
  co.lep_status,
  co.lunchstatus,
  SUM(CAST(mem.attendancevalue AS INT)) AS att,
  SUM(CAST(mem.membershipvalue AS INT)) AS mem,
  SUM(CAST(mem.membershipvalue AS INT)) - SUM(CAST(mem.attendancevalue AS INT)) AS absences
FROM
  gabby.powerschool.cohort_identifiers_static AS co
  INNER JOIN gabby.powerschool.ps_adaadm_daily_ctod_static AS mem ON co.studentid = mem.studentid
  AND co.yearid = mem.yearid
WHERE
  co.schoolid <> 999999
  AND co.rn_year = 1
GROUP BY
  co.student_number,
  co.state_studentnumber,
  co.school_name,
  co.grade_level,
  co.academic_year,
  co.iep_status,
  co.lep_status,
  co.lunchstatus,
  co.region
