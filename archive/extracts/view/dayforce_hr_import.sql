CREATE OR ALTER VIEW
  extracts.dayforce_hr_import AS
SELECT
  'EmployeeImport' AS F1,
  NULL AS F2,
  NULL AS F3,
  NULL AS F4,
  NULL AS F5,
  NULL AS F6,
  NULL AS F7,
  NULL AS F8
UNION ALL
SELECT
  'H',
  'Employee',
  'Employee',
  'XRefCode',
  'EmployeeNumber',
  'FirstName',
  'LastName',
  'FederationId'
UNION ALL
SELECT
  'D',
  'Employee',
  'Employee',
  CAST(d.df_employee_number AS VARCHAR),
  CAST(d.df_employee_number AS VARCHAR),
  CAST(d.first_name AS VARCHAR),
  CAST(d.last_name AS VARCHAR),
  ad.userprincipalname
FROM
  gabby.dayforce.employees AS d
  INNER JOIN gabby.adsi.user_attributes_static AS ad ON d.df_employee_number = ad.employeenumber
  AND ISNUMERIC(ad.employeenumber) = 1
