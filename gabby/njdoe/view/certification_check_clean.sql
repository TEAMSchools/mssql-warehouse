CREATE OR ALTER VIEW
  njdoe.certification_check_clean AS
SELECT
  df_employee_number,
  JSON_VALUE(applicant, '$.tracking_number') AS applicant_tracking_number,
  JSON_VALUE(applicant, '$.email') AS applicant_email,
  JSON_VALUE(applicant, '$.phone_number') AS applicant_phone_number,
  application_history,
  certificate_history
FROM
  njdoe.certification_check
