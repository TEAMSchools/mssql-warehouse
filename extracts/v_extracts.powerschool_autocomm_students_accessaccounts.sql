USE gabby
GO

ALTER VIEW extracts.powerschool_autocomm_students_accessaccounts AS

SELECT student_number          
      ,student_web_id
      ,student_web_password                
      ,CASE WHEN enroll_status = 0 THEN 1 ELSE 0 END AS student_allowwebaccess
      ,student_web_id + '.fam' AS web_id
      ,student_web_password AS web_password
      ,CASE WHEN enroll_status = 0 THEN 1 ELSE 0 END AS allowwebaccess
      ,team        
FROM gabby.powerschool.student_access_accounts
WHERE schoolid != 999999
  AND enroll_status = 0