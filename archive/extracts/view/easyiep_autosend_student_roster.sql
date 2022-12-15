USE gabby GO
CREATE OR ALTER VIEW
  extracts.easyiep_autosend_student_roster AS
SELECT
  s.state_studentnumber,
  s.student_number,
  s.last_name,
  s.first_name,
  s.gender,
  s.enroll_status,
  s.dob,
  s.ethnicity,
  scf.primarylanguage,
  s.grade_level,
  nj.cityofbirth,
  nj.stateofbirth,
  nj.districtcoderesident,
  nj.countycodeattending,
  nj.districtcodeattending,
  CASE
    WHEN sp.programid = 5173 THEN nj.schoolcodeattending
    ELSE CONCAT(s.schoolid, sp.programid)
  END AS schoolid,
  nj.referral_date
FROM
  gabby.powerschool.students AS s
  LEFT JOIN gabby.powerschool.studentcorefields AS scf ON s.dcid = scf.studentsdcid
  AND s.[db_name] = scf.[db_name]
  LEFT JOIN gabby.powerschool.spenrollments_gen_static AS sp ON s.id = sp.studentid
  AND s.entrydate (BETWEEN sp.enter_date AND sp.exit_date)
  AND s.[db_name] = sp.[db_name]
  AND sp.specprog_name IN (
    'Out of District',
    'Pathways ES',
    'Pathways MS',
    'Whittier ES'
  )
  LEFT JOIN gabby.powerschool.s_nj_stu_x AS nj ON s.dcid = nj.studentsdcid
  AND s.[db_name] = nj.[db_name]
WHERE
  s.enroll_status = 0
