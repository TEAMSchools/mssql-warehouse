USE gabby
GO

CREATE OR ALTER VIEW extracts.gsheets_student_contact_info AS

SELECT co.student_number
      ,co.newark_enrollment_number
      ,co.state_studentnumber
      ,co.lastfirst
      ,co.schoolid
      ,co.school_name
      ,CASE WHEN co.grade_level = 0 THEN 'K' ELSE CONVERT(VARCHAR,co.grade_level) END AS grade_level      
      ,co.team
      ,co.advisor_name      
      ,CONVERT(VARCHAR,co.entrydate) AS entrydate
      ,co.boy_status
      ,CONVERT(VARCHAR,co.dob) AS dob
      ,co.gender                        
      ,co.lunchstatus
      ,CASE
        WHEN co.lunch_app_status IS NULL THEN 'N'
        WHEN co.lunch_app_status = 'No Application' THEN 'N'
        WHEN co.lunch_app_status LIKE 'Prior%' THEN 'N'
        ELSE 'Y'
       END AS lunch_app_status 
      ,CONVERT(MONEY,co.lunch_balance) AS lunch_balance
      ,co.home_phone
      ,co.mother_cell
      ,co.father_cell
      ,co.mother
      ,co.father      
      ,CONCAT(co.release_1_name, ' | ', co.release_1_phone) AS release_1
      ,CONCAT(co.release_2_name, ' | ', co.release_2_phone) AS release_2
      ,CONCAT(co.release_3_name, ' | ', co.release_3_phone) AS release_3
      ,CONCAT(co.release_4_name, ' | ', co.release_4_phone) AS release_4
      ,CONCAT(co.release_5_name, ' | ', co.release_5_phone) AS release_5
      ,co.guardianemail      
      ,CONCAT(co.street, ', ', co.city, ', ', co.state, ' ', co.zip) AS address
      ,co.first_name
      ,co.last_name
      ,co.student_web_id
      ,co.student_web_password
      ,co.student_web_id + '.fam' AS family_web_id
      ,co.student_web_password AS family_web_password      

      ,suf.media_release

      ,co.region
      ,co.iep_status
      ,co.lep_status
      ,co.c_504_status

      ,CASE WHEN scf.homeless_code IN ('Y1', 'Y2') THEN 1 END AS is_homeless
FROM gabby.powerschool.cohort_identifiers_static co
LEFT JOIN gabby.powerschool.u_studentsuserfields suf
  ON co.students_dcid = suf.studentsdcid
 AND co.db_name = suf.db_name
LEFT JOIN gabby.powerschool.studentcorefields scf
  ON co.students_dcid = scf.studentsdcid
 AND co.db_name = scf.db_name
WHERE co.enroll_status IN (0, -1)
  AND co.rn_all = 1