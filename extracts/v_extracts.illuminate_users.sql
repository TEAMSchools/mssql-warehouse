USE gabby;
GO

CREATE OR ALTER VIEW extracts.illuminate_users AS

SELECT COALESCE(ps.ps_teachernumber, CONVERT(VARCHAR(25), df.df_employee_number)) AS [01 User ID]
      ,df.preferred_last_name AS [02 User Last Name]
      ,df.preferred_first_name AS [03 User First Name]
      ,NULL AS [04 User Middle Name]
      ,NULL AS [05 Birth Date]
      ,NULL AS [06 Gender]
      ,ad.userprincipalname AS [07 Email Address]
      ,ad.samaccountname AS [08 Username]
      ,NULL AS [09 Password]
      ,df.df_employee_number AS [10 State User or Employee ID]
      ,NULL AS [11 Name suffix]
      ,NULL AS [12 Former First Name]
      ,NULL AS [13 Former Middle Name]
      ,NULL AS [14 Former Last Name]
      ,NULL AS [15 Primary Race]
      ,NULL AS [16 User is Hispanic]
      ,NULL AS [17 Address]
      ,df.legal_entity_name AS [18 City]
      ,NULL AS [19 State]
      ,NULL AS [20 Zip]
      ,df.primary_job AS [21 Job Title]
      ,NULL AS [22 Education Level]
      ,NULL AS [23 Hire Date]
      ,NULL AS [24 Exit Date]
      ,CASE WHEN df.status = 'TERMINATED' THEN 0 ELSE 1 END AS [25 Active]
      ,NULL AS [26 Position Status]
      ,NULL AS [27 Total Years Edu Service]
      ,NULL AS [28 Total Year In District]
      ,NULL AS [29 Email2]
      ,NULL AS [30 Phone1]
      ,NULL AS [31 Phone2]
FROM gabby.dayforce.staff_roster df
LEFT JOIN gabby.people.id_crosswalk_powerschool ps
  ON df.df_employee_number = ps.df_employee_number
 AND ps.is_master = 1
LEFT JOIN gabby.adsi.user_attributes_static ad
  ON CONVERT(VARCHAR,df.df_employee_number) = ad.employeenumber