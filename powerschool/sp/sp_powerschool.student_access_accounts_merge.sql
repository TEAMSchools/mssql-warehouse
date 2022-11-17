USE gabby
GO

CREATE OR ALTER PROCEDURE powerschool.student_access_accounts_merge AS

WITH merge_cte AS (
  SELECT student_number
        ,schoolid
        ,enroll_status
        ,base_username
        ,alt_username
        ,uses_alt
        ,base_dupe_audit
        ,alt_dupe_audit
        ,student_web_id
        ,student_web_password
  FROM gabby.powerschool.student_access_accounts
 )

MERGE gabby.powerschool.student_access_accounts_static AS TARGET
USING merge_cte AS SOURCE
   ON SOURCE.student_number = TARGET.student_number
WHEN MATCHED THEN
  UPDATE 
    SET TARGET.student_web_password = SOURCE.student_web_password
WHEN NOT MATCHED THEN 
  INSERT 
    (student_number
    ,schoolid
    ,enroll_status
    ,base_username
    ,alt_username
    ,uses_alt
    ,base_dupe_audit
    ,alt_dupe_audit
    ,student_web_id
    ,student_web_password)
  VALUES
    (SOURCE.student_number
    ,SOURCE.schoolid
    ,SOURCE.enroll_status
    ,SOURCE.base_username
    ,SOURCE.alt_username
    ,SOURCE.uses_alt
    ,SOURCE.base_dupe_audit
    ,SOURCE.alt_dupe_audit
    ,SOURCE.student_web_id
    ,SOURCE.student_web_password);
