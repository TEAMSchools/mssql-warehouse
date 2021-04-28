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

SELECT LOWER(sub.samaccountname) AS [Login]
      ,CASE
        WHEN sub.[status] = 'Terminated' THEN 'inactive'
        WHEN sub.active IS NOT NULL THEN sub.active
        WHEN sub.business_unit_code IN ('TEAM', 'KIPP_MIAMI') THEN 'inactive' /* TEAM/Miami phasing in */
        ELSE 'active'
       END AS [Status]
      ,COALESCE(CASE WHEN sub.[status] = 'Terminated' THEN 'No' END
               ,sub.purchasing_user
               ,'No') AS [Purchasing User] /* preserve Coupa, otherwise No */
      ,CASE WHEN sub.[status] = 'Terminated' THEN 'No' ELSE 'Yes' END AS [Expense User]
      ,'SAML' AS [Authentication Method]
      ,LOWER(sub.userprincipalname) AS [Sso Identifier]
      ,'No' AS [Generate Password And Notify User]
      ,COALESCE(LOWER(sub.mail), LOWER(sub.userprincipalname)) AS [Email] /* some are missing the AD mail attribute `\(o_O)/` */
      ,sub.preferred_first_name AS [First Name]
      ,sub.preferred_last_name AS [Last Name]
      ,sub.employee_number AS [Employee Number]
      ,sub.roles AS [User Role Names]
      ,COALESCE(sub.content_groups
               ,CASE
                 WHEN sub.business_unit_code = 'KIPP_TAF' THEN 'KIPP NJ'
                 WHEN sub.business_unit_code = 'KIPP_MIAMI' THEN 'MIA'
                 ELSE sub.business_unit_code
                END) AS [Content Groups] /* preserve Coupa, otherwise use HRIS */
      ,gabby.utilities.STRIP_CHARACTERS(CONCAT(sub.preferred_first_name, sub.preferred_last_name ), '^A-Z') AS [Mention Name]
      ,COALESCE(x.coupa_school_name
               ,CASE
                 WHEN sn.coupa_school_name = '<Use PhysicalDeliveryOfficeName>' AND sub.physicaldeliveryofficename IN ('KIPP Cooper Norcross High (KCNA)', 'KIPP Cooper Norcross High School') THEN 'KCNHS'
                 WHEN sn.coupa_school_name = '<Use PhysicalDeliveryOfficeName>' THEN REPLACE(sub.physicaldeliveryofficename, 'KIPP ', '')
                 ELSE sn.coupa_school_name
                END
               ,CASE
                 WHEN sn2.coupa_school_name = '<Use PhysicalDeliveryOfficeName>' AND sub.physicaldeliveryofficename IN ('KIPP Cooper Norcross High (KCNA)', 'KIPP Cooper Norcross High School') THEN 'KCNHS'
                 WHEN sn2.coupa_school_name = '<Use PhysicalDeliveryOfficeName>' THEN REPLACE(sub.physicaldeliveryofficename, 'KIPP ', '')
                 ELSE sn2.coupa_school_name
                END) AS [School Name] /* override > lookup table (content group/department/job) > lookup table (content group/department) */
FROM
    (
     /* existing users */
     SELECT sr.employee_number
           ,sr.preferred_first_name
           ,sr.preferred_last_name
           ,sr.business_unit_code
           ,sr.home_department
           ,sr.[status]
           ,sr.job_title

           ,ad.samaccountname
           ,ad.userprincipalname
           ,ad.mail
           ,ad.physicaldeliveryofficename

           ,CASE 
             WHEN cu.active = 1 THEN 'active'
             WHEN cu.active = 0 THEN 'inactive'
            END AS active
           ,CASE
             WHEN cu.purchasing_user = 1 THEN 'Yes'
             WHEN cu.purchasing_user = 0 THEN 'No'
            END AS purchasing_user
           ,JSON_VALUE(cu.custom_fields, '$."school-name".name') AS school_name

           ,r.roles

           ,bg.business_group_names AS content_groups
     FROM gabby.people.staff_roster sr
     INNER JOIN gabby.adsi.user_attributes_static ad
       ON sr.employee_number = ad.employeenumber
      AND ISNUMERIC(ad.employeenumber) = 1
     INNER JOIN gabby.coupa.[user] cu
       ON sr.employee_number = cu.employee_number
     INNER JOIN roles r
       ON cu.id = r.[user_id]
     LEFT JOIN business_groups bg
       ON cu.id = bg.[user_id]
     WHERE sr.[status] <> 'Prestart'
       AND sr.home_department NOT IN ('Interns')

     UNION ALL

     /* new users */
     SELECT sr.employee_number
           ,sr.preferred_first_name
           ,sr.preferred_last_name
           ,sr.business_unit_code
           ,sr.home_department
           ,sr.[status]
           ,sr.job_title

           ,ad.samaccountname
           ,ad.userprincipalname
           ,ad.mail
           ,ad.physicaldeliveryofficename
           ,NULL AS active
           ,'No' AS purchasing_user
           ,NULL AS school_name
           ,'Expense User' AS roles
           ,NULL AS content_groups
     FROM gabby.people.staff_roster sr
     INNER JOIN gabby.adsi.user_attributes_static ad
       ON sr.employee_number = ad.employeenumber
      AND ISNUMERIC(ad.employeenumber) = 1
     LEFT JOIN gabby.coupa.[user] cu
       ON sr.employee_number = cu.employee_number
     WHERE sr.[status] NOT IN ('Prestart', 'Terminated')
       AND sr.home_department NOT IN ('Interns')
       AND cu.employee_number IS NULL
    ) sub
LEFT JOIN gabby.coupa.school_name_lookup sn
  ON sub.business_unit_code = sn.business_unit_code
 AND sub.home_department = sn.home_department
 AND sub.job_title = sn.job_title
LEFT JOIN gabby.coupa.school_name_lookup sn2
  ON sub.business_unit_code = sn2.business_unit_code
 AND sub.home_department = sn2.home_department
 AND sn2.job_title = 'Default'
LEFT JOIN gabby.coupa.user_exceptions x
  ON sub.employee_number = x.employee_number
