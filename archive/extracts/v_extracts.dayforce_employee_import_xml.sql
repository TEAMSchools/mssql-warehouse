USE gabby GO
CREATE OR ALTER VIEW
  extracts.dayforce_employee_import_xml AS
SELECT
  sub.XRefCode,
  sub.EmployeeNumber,
  sub.FirstName,
  sub.LastName,
  CONCAT(
    sub.ContactInformationTypeXrefCode,
    sub.EffectiveStart,
    sub.IsForSystemCommunication,
    sub.ElectronicAddress
  ) AS ContactInformation
FROM
  (
    SELECT
      df.df_employee_number AS XRefCode,
      df.df_employee_number AS EmployeeNumber,
      df.first_name AS FirstName,
      df.last_name AS LastName,
      CONCAT(
        '<ContactInformationTypeXrefCode>',
        'BusinessEmail',
        '</ContactInformationTypeXrefCode>'
      ) AS ContactInformationTypeXrefCode,
      CONCAT(
        '<EffectiveStart>',
        df.original_hire_date,
        '</EffectiveStart>'
      ) AS EffectiveStart,
      CONCAT(
        '<IsForSystemCommunication>',
        1,
        '</IsForSystemCommunication>'
      ) AS IsForSystemCommunication,
      CONCAT(
        '<ElectronicAddress>',
        ad.mail,
        '</ElectronicAddress>'
      ) AS ElectronicAddress
    FROM
      gabby.dayforce.employees df
      JOIN gabby.adsi.user_attributes_static ad ON df.df_employee_number = CAST(ad.employeenumber AS VARCHAR)
      AND ISNUMERIC(ad.employeenumber) = 1
    WHERE
      df.[status] <> 'TERMINATED'
  ) sub
