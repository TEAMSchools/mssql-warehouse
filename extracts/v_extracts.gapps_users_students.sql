USE gabby
GO

CREATE OR ALTER VIEW extracts.gapps_users_students AS

SELECT co.student_number
      ,co.schoolid
      ,co.first_name AS firstname
      ,co.last_name AS lastname      
      ,CASE WHEN co.schoolid = 73253 THEN 'on' ELSE 'off' END AS changepassword
      ,CASE WHEN co.enroll_status = 0 THEN 'off' ELSE 'on' END AS suspended
      ,'/Students/' + CASE 
                       WHEN co.enroll_status != 0 THEN 'Disabled'
                       WHEN co.school_name = 'Out of District' THEN 'Disabled'
                       ELSE co.school_name 
                      END AS org
      ,acct.student_web_id + '@teamstudents.org' AS email
      ,acct.student_web_password AS password
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.powerschool.student_access_accounts acct 
  ON co.student_number = acct.student_number
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1