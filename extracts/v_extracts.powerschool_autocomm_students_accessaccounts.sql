USE gabby
GO

CREATE OR ALTER VIEW extracts.powerschool_autocomm_students_accessaccounts AS

SELECT co.student_number          
      ,co.student_web_id
      ,co.student_web_password                
      ,CASE WHEN co.enroll_status = 0 THEN 1 ELSE 0 END AS student_allowwebaccess
      ,co.student_web_id + '.fam' AS web_id
      ,co.student_web_password AS web_password
      ,CASE WHEN co.enroll_status = 0 THEN 1 ELSE 0 END AS allowwebaccess      
      ,co.team
      ,co.db_name
FROM gabby.powerschool.cohort_identifiers_static co
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1
  AND co.enroll_status = 0
  AND co.grade_level != 99