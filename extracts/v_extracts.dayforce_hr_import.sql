USE gabby
GO

CREATE OR ALTER VIEW extracts.dayforce_hr_import AS

SELECT 'EmployeeImport' AS F1
      ,NULL AS F2
      ,NULL AS F3
      ,NULL AS F4
      ,NULL AS F5
      ,NULL AS F6
      ,NULL AS F7
      ,NULL AS F8

UNION ALL

SELECT 'H'
      ,'Employee'
      ,'Employee'
      ,'XRefCode'
      ,'EmployeeNumber'
      ,'FirstName'
      ,'LastName'
      ,'FederationId'

UNION ALL

SELECT 'D'
      ,'Employee'
      ,'Employee'
      ,CONVERT(VARCHAR,d.df_employee_number)
      ,CONVERT(VARCHAR,d.df_employee_number)
      ,CONVERT(VARCHAR,d.first_name)
      ,CONVERT(VARCHAR,d.last_name)
      
      ,ad.userprincipalname
FROM gabby.dayforce.employees d
JOIN gabby.adsi.user_attributes_static ad
  ON d.df_employee_number = ad.employeenumber
 AND ISNUMERIC(ad.employeenumber) = 1