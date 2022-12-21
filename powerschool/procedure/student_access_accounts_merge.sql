CREATE
OR ALTER
PROCEDURE powerschool.student_access_accounts_merge AS
MERGE
  gabby.powerschool.student_access_accounts_static AS tgt
  /**/
  USING powerschool.student_access_accounts AS src ON (
    src.student_number = tgt.student_number
  )
WHEN MATCHED THEN
UPDATE SET
  tgt.student_web_password = src.student_web_password
WHEN NOT MATCHED THEN
INSERT
  (
    student_number,
    schoolid,
    enroll_status,
    base_username,
    alt_username,
    uses_alt,
    base_dupe_audit,
    alt_dupe_audit,
    student_web_id,
    student_web_password
  )
VALUES
  (
    src.student_number,
    src.schoolid,
    src.enroll_status,
    src.base_username,
    src.alt_username,
    src.uses_alt,
    src.base_dupe_audit,
    src.alt_dupe_audit,
    src.student_web_id,
    src.student_web_password
  );
