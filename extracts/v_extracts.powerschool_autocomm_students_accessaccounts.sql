USE gabby
GO

CREATE OR ALTER VIEW extracts.powerschool_autocomm_students_accessaccounts AS

SELECT saa.student_number          
      ,saa.student_web_id
      ,saa.student_web_password                
      ,CASE WHEN saa.enroll_status = 0 THEN 1 ELSE 0 END AS student_allowwebaccess
      ,saa.student_web_id + '.fam' AS web_id
      ,saa.student_web_password AS web_password
      ,CASE WHEN saa.enroll_status = 0 THEN 1 ELSE 0 END AS allowwebaccess
      ,LEFT(gabby.utilities.STRIP_CHARACTERS(adv.advisory_name,'0-9'), 10) AS team
FROM gabby.powerschool.student_access_accounts saa
LEFT OUTER JOIN gabby.powerschool.advisory adv
  ON saa.student_number = adv.student_number
 AND adv.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
 AND adv.rn_year = 1
WHERE schoolid != 999999
  AND enroll_status = 0