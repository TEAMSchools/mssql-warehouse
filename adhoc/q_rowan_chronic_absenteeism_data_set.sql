WITH ada AS (
  SELECT studentid
        ,yearid
        ,AVG(CONVERT(FLOAT,attendancevalue)) AS ada
  FROM gabby.powerschool.ps_adaadm_daily_ctod_static
  GROUP BY studentid
          ,yearid
 )

,suspensions AS (
  SELECT studentid
        ,gabby.utilities.DATE_TO_SY(att_date) AS academic_year
        ,MAX(CASE WHEN att_code = 'OSS' THEN 'Y' ELSE 'N' END) AS oss
        ,MAX(CASE WHEN att_code = 'ISS' THEN 'Y' ELSE 'N' END) AS iss
  FROM gabby.powerschool.ps_attendance_daily_static
  GROUP BY studentid
          ,gabby.utilities.DATE_TO_SY(att_date)
 )

SELECT co.student_number
      ,CONCAT(co.first_name, ' ', co.last_name) AS student_name
      ,co.dob
      ,CONCAT(co.street, ', ', co.city, ', ', co.state, ' ', co.zip) AS home_address      
      ,co.ethnicity
      ,nj.home_language
      ,co.academic_year
      ,co.entrydate
      ,co.exitdate
      ,co.school_name
      ,co.grade_level
      ,co.iep_status
      ,co.lunchstatus      
      ,gpa.gpa_y1
      ,lit.read_lvl
      ,ada.ada
      ,sus.iss
      ,sus.oss
      ,NULL AS transportation_method
FROM gabby.powerschool.cohort_identifiers_static co
LEFT OUTER JOIN gabby.powerschool.s_nj_stu_x nj
  ON co.students_dcid = nj.studentsdcid
LEFT OUTER JOIN gabby.powerschool.gpa_detail gpa
  ON co.student_number = gpa.student_number
 AND co.academic_year = gpa.academic_year
 AND gpa.is_curterm = 1
LEFT OUTER JOIN gabby.lit.achieved_by_round_static lit
  ON co.student_number = lit.student_number
 AND co.academic_year = lit.academic_year
 AND lit.is_curterm = 1
LEFT OUTER JOIN ada
  ON co.studentid = ada.studentid
 AND co.yearid = ada.yearid
LEFT OUTER JOIN suspensions sus
  ON co.studentid = sus.studentid
 AND co.academic_year = sus.academic_year
WHERE co.region = 'KCNA'
  AND co.academic_year >= 2015
  AND co.rn_year = 1