CREATE OR ALTER VIEW
  njdoe.background_check_clean AS
SELECT
  employee_number,
  JSON_VALUE(applicant, '$.document_id') AS document_id,
  JSON_VALUE(
    applicant,
    '$.number_of_approvals'
  ) AS number_of_approvals
FROM
  gabby.njdoe.background_check
