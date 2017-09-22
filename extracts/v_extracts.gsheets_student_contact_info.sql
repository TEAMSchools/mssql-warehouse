USE gabby
GO

CREATE OR ALTER VIEW extracts.gsheets_student_contact_info AS

SELECT co.student_number
      ,co.newark_enrollment_number
      ,co.state_studentnumber
      ,co.lastfirst
      ,co.schoolid
      ,co.school_name
      ,CASE WHEN co.grade_level = 0 THEN 'K' ELSE CONVERT(NVARCHAR,co.grade_level) END AS grade_level      
      ,co.team
      ,co.advisor_name      
      ,CONVERT(NVARCHAR,co.entrydate) AS entrydate
      ,co.boy_status
      ,CONVERT(NVARCHAR,co.dob) AS dob
      ,co.gender                        
      ,co.lunchstatus
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

      ,aa.student_web_id
      ,aa.student_web_password
      ,aa.web_id AS family_web_id
      ,aa.web_password AS family_web_password      
FROM gabby.powerschool.cohort_identifiers_static co
LEFT OUTER JOIN gabby.extracts.powerschool_autocomm_students_accessaccounts aa
  ON co.student_number = aa.student_number
WHERE co.enroll_status = 0
  AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1 