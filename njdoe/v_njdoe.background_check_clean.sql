USE gabby GO
CREATE OR ALTER VIEW
  njdoe.background_check_clean AS
SELECT
  bc.employee_number,
  JSON_VALUE(bc.applicant, '$.document_id') AS document_id,
  JSON_VALUE(bc.applicant, '$.number_of_approvals') AS number_of_approvals
FROM
  gabby.njdoe.background_check bc
