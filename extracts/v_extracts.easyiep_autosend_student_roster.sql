USE gabby
GO

CREATE OR ALTER VIEW extracts.easyiep_autosend_student_roster AS

SELECT s.state_studentnumber
      ,s.student_number
      ,s.last_name
      ,s.first_name
      ,s.gender
      ,s.enroll_status
      ,s.dob
      ,s.ethnicity
      ,scf.primarylanguage
      ,s.grade_level
      ,nj.cityofbirth
      ,nj.stateofbirth
      ,nj.districtcoderesident
      ,nj.countycodeattending
      ,nj.districtcodeattending
      ,CASE
        WHEN sp.programid = 5173 THEN nj.schoolcodeattending
        ELSE CONCAT(s.schoolid, sp.programid) 
       END AS schoolid      
      ,nj.referral_date
FROM gabby.powerschool.students s
LEFT OUTER JOIN gabby.powerschool.studentcorefields scf
  ON s.dcid = scf.studentsdcid
LEFT OUTER JOIN gabby.powerschool.spenrollments_gen sp
  ON s.id = sp.studentid
 AND s.entrydate BETWEEN sp.enter_date AND sp.exit_date
 AND sp.programid IN (4573, 5074, 5075, 5173) 
LEFT OUTER JOIN gabby.powerschool.s_nj_stu_x nj
  ON s.dcid = nj.studentsdcid
WHERE s.enroll_status = 0