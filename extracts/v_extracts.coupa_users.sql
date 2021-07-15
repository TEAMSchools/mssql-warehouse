USE gabby
GO

CREATE OR ALTER VIEW extracts.coupa_users AS

WITH roles AS (
  SELECT [user_id]
        ,gabby.dbo.GROUP_CONCAT(role_name) AS roles
  FROM
      (
       SELECT urm.[user_id]
             ,r.[name] AS role_name
       FROM gabby.coupa.user_role_mapping urm
       JOIN gabby.coupa.[role] r
         ON urm.role_id = r.id

       UNION

       SELECT u.id AS [user_id]
             ,'Expense User' AS role_name
       FROM gabby.coupa.[user] u
      ) sub
  GROUP BY [user_id]
 )

,business_groups AS (
  SELECT ubgm.[user_id]
        ,gabby.dbo.GROUP_CONCAT_D(bg.[name], ', ') AS business_group_names
  FROM gabby.coupa.user_business_group_mapping ubgm
  JOIN gabby.coupa.business_group bg
    ON ubgm.business_group_id = bg.id
  GROUP BY ubgm.[user_id]
 )

,all_users AS (
  /* existing users */
  SELECT sr.employee_number
        ,sr.first_name
        ,sr.last_name
        ,sr.[status]
        ,sr.business_unit_code
        ,sr.home_department
        ,sr.job_title

        ,cu.active
        ,CASE
          WHEN cu.purchasing_user = 1 THEN 'Yes'
          WHEN cu.purchasing_user = 0 THEN 'No'
         END AS purchasing_user

        ,r.roles

        ,bg.business_group_names AS content_groups
  FROM gabby.people.staff_roster sr
  INNER JOIN gabby.coupa.[user] cu
    ON sr.employee_number = cu.employee_number
  INNER JOIN roles r
    ON cu.id = r.[user_id]
  LEFT JOIN business_groups bg
    ON cu.id = bg.[user_id]
  WHERE sr.[status] <> 'Prestart'
    AND sr.job_title NOT IN ('Intern')
    AND COALESCE(sr.termination_date, CONVERT(DATE, GETDATE())) >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1, 7, 1)

  UNION ALL

  /* new users */
  SELECT sr.employee_number
        ,sr.first_name
        ,sr.last_name
        ,sr.[status]
        ,sr.business_unit_code
        ,sr.home_department
        ,sr.job_title

        ,1 AS active
        ,'No' AS purchasing_user
        ,'Expense User' AS roles
        ,NULL AS content_groups
  FROM gabby.people.staff_roster sr
  LEFT JOIN gabby.coupa.[user] cu
    ON sr.employee_number = cu.employee_number
  WHERE sr.[status] NOT IN ('Prestart', 'Terminated')
    AND sr.job_title NOT IN ('Intern')
    AND cu.employee_number IS NULL
 )

SELECT sub.[Login]
      ,sub.[Status]
      ,sub.[Purchasing User]
      ,sub.[Expense User]
      ,sub.[Authentication Method]
      ,sub.[Sso Identifier]
      ,sub.[Generate Password And Notify User]
      ,sub.[Email]
      ,sub.[First Name]
      ,sub.[Last Name]
      ,sub.[Employee Number]
      ,sub.[User Role Names]
      ,sub.[Content Groups]
      ,sub.[Mention Name]
      ,COALESCE(sna.coupa_school_name, sub.[coupa_school_name]) AS [School Name]
FROM
    (
     SELECT LOWER(ad.samaccountname) AS [Login]
           ,CASE
             WHEN au.[status] = 'Terminated' THEN 'inactive'
             ELSE 'active'
            END AS [Status]
           ,COALESCE(
               CASE 
                WHEN au.[status] = 'Terminated' THEN 'No' 
                WHEN au.active = 0 THEN 'No'
               END
              ,au.purchasing_user
              ,'No'
             ) AS [Purchasing User] /* preserve Coupa, otherwise No */
           ,CASE 
             WHEN au.[status] = 'Terminated' THEN 'No' 
             ELSE 'Yes' 
            END AS [Expense User]
           ,'SAML' AS [Authentication Method]
           ,LOWER(ad.userprincipalname) AS [Sso Identifier]
           ,'No' AS [Generate Password And Notify User]
           ,LOWER(ad.mail) AS [Email] /* some are missing the AD mail attribute `\(o_O)/` */
           ,au.first_name AS [First Name]
           ,au.last_name AS [Last Name]
           ,au.employee_number AS [Employee Number]
           ,au.roles AS [User Role Names]
           ,COALESCE(
               au.content_groups
              ,CASE
                WHEN au.business_unit_code = 'KIPP_TAF' THEN 'KIPP NJ'
                WHEN au.business_unit_code = 'KIPP_MIAMI' THEN 'MIA'
                ELSE au.business_unit_code
               END
             ) AS [Content Groups] /* preserve Coupa, otherwise use HRIS */
           ,CASE
             WHEN au.[status] = 'Terminated' THEN 'X' + gabby.utilities.STRIP_CHARACTERS(CONCAT(au.first_name, au.last_name ), '^A-Z')
             ELSE gabby.utilities.STRIP_CHARACTERS(CONCAT(au.first_name, au.last_name ), '^A-Z')
            END AS [Mention Name]
           ,COALESCE(
               x.coupa_school_name
              ,CASE 
                WHEN sn.coupa_school_name = '<Use PhysicalDeliveryOfficeName>' THEN ad.physicaldeliveryofficename
                ELSE sn.coupa_school_name
               END
              ,CASE 
                WHEN sn2.coupa_school_name = '<Use PhysicalDeliveryOfficeName>' THEN ad.physicaldeliveryofficename
                ELSE sn2.coupa_school_name
               END
             ) AS coupa_school_name /* override > lookup table (content group/department/job) > lookup table (content group/department) */
     FROM all_users au
     INNER JOIN gabby.adsi.user_attributes_static ad
       ON au.employee_number = ad.employeenumber
      AND ISNUMERIC(ad.employeenumber) = 1
     LEFT JOIN gabby.coupa.school_name_lookup sn
       ON au.business_unit_code = sn.business_unit_code
      AND au.home_department = sn.home_department
      AND au.job_title = sn.job_title
     LEFT JOIN gabby.coupa.school_name_lookup sn2
       ON au.business_unit_code = sn2.business_unit_code
      AND au.home_department = sn2.home_department
      AND sn2.job_title = 'Default'
     LEFT JOIN gabby.coupa.user_exceptions x
       ON au.employee_number = x.employee_number
    ) sub
LEFT JOIN gabby.coupa.school_name_aliases sna
  ON sub.coupa_school_name = sna.physical_delivery_office_name
