USE gabby
GO

CREATE OR ALTER VIEW extracts.coupa_users AS

SELECT LOWER(sub.samaccountname) AS [Login]
      ,CASE
        WHEN sub.[status] = 'Terminated' THEN 'inactive'
        WHEN sub.active IS NOT NULL THEN sub.active
        WHEN sub.business_unit_code IN ('TEAM', 'MIA') THEN 'inactive' -- TEAM/Miami phasing in
        ELSE 'active'
       END AS [Status]
      ,COALESCE(CASE WHEN sub.[status] = 'Terminated' THEN 'No' END
               ,sub.purchasing_license
               ,'No') AS [Purchasing User] -- preserve Coupa, otherwise No
      ,CASE WHEN sub.[status] = 'Terminated' THEN 'No' ELSE 'Yes' END AS [Expense User]
      ,'SAML' AS [Authentication Method]
      ,LOWER(sub.userprincipalname) AS [Sso Identifier]
      ,'No' AS [Generate Password And Notify User]
      ,COALESCE(LOWER(sub.mail), LOWER(sub.userprincipalname)) AS [Email] -- some are missing the AD mail attribute `\(8|)/`
      ,sub.preferred_first_name AS [First Name]
      ,sub.preferred_last_name AS [Last Name]
      ,sub.employee_number AS [Employee Number]
      ,CONCAT('Expense User, ', sub.roles) AS [User Role Names]
      ,COALESCE(sub.content_groups
               ,CASE
                 WHEN sub.business_unit_code = 'KIPP_TAF' THEN 'KIPP NJ'
                 ELSE sub.business_unit_code 
                END) AS [Content Groups] -- preserve Coupa, otherwise use HRIS
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
                END) AS [School Name] -- override > lookup table (content group/department/job) > lookup table (content group/department)
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

           ,cu.content_groups
           ,cu.school_name
           ,cu.purchasing_license
           ,cu.roles
           ,cu.active
     FROM gabby.people.staff_roster sr
     INNER JOIN gabby.adsi.user_attributes_static ad
       ON sr.employee_number = ad.employeenumber
      AND ISNUMERIC(ad.employeenumber) = 1
     INNER JOIN gabby.coupa.users cu
       ON sr.employee_number = cu.employee_number
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

           ,NULL AS content_groups
           ,NULL AS school_name
           ,'No' AS purchasing_license
           ,'Expense User' AS roles
           ,NULL AS active
     FROM gabby.people.staff_roster sr
     INNER JOIN gabby.adsi.user_attributes_static ad
       ON sr.employee_number = ad.employeenumber
      AND ISNUMERIC(ad.employeenumber) = 1
     LEFT JOIN gabby.coupa.users cu
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
