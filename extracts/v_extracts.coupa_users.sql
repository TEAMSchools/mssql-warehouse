USE gabby
GO

CREATE OR ALTER VIEW extracts.coupa_users AS

SELECT LOWER(sub.samaccountname) AS [Login]
      ,CASE
        WHEN sub.[status] = 'Terminated' THEN 'inactive'
        ELSE 'active'
       END AS [Status]
      ,COALESCE(sub.purchasing_license, 'No') AS [Purchasing User] -- preserve Coupa, otherwise No
      ,'Yes' AS [Expense User]
      ,'SAML' AS [Authentication Method]
      ,LOWER(sub.userprincipalname) AS [Sso Identifier]
      ,'No' AS [Generate Password And Notify User]
      ,LOWER(sub.mail) AS [Email]
      ,sub.preferred_first_name AS [First Name]
      ,sub.preferred_last_name AS [Last Name]
      ,sub.employee_number AS [Employee Number]
      ,CONCAT('Expense User, ', sub.roles) AS [User Role Names]
      ,COALESCE(sub.content_groups
               ,CASE
                 WHEN sub.legal_entity_abbreviation = 'KNJ' THEN 'KIPP NJ'
                 ELSE sub.legal_entity_abbreviation 
                END) AS [Content Groups] -- preserve Coupa, otherwise use HRIS
      ,COALESCE(
          sub.mention_name
         ,gabby.utilities.STRIP_CHARACTERS(CONCAT(sub.preferred_first_name, sub.preferred_last_name ), '^A-Z-') -- first + last, keep only letters & dashes
        ) AS [Mention Name] -- preserve Coupa, otherwise use HRIS
      ,COALESCE(x.coupa_school_name
               ,CASE
                 WHEN sn.coupa_school_name = '<Use PhysicalDeliveryOfficeName>' AND sub.physicaldeliveryofficename IN ('KIPP Cooper Norcross High (KCNA)', 'KIPP Cooper Norcross High School') THEN 'KCNHS'
                 WHEN sn.coupa_school_name = '<Use PhysicalDeliveryOfficeName>' AND sub.physicaldeliveryofficename = 'KIPP Lanning Square Middle' THEN 'Lanning Square Middle'
                 WHEN sn.coupa_school_name = '<Use PhysicalDeliveryOfficeName>' AND sub.physicaldeliveryofficename = 'KIPP Lanning Square Primary' THEN 'Lanning Square Primary'
                 WHEN sn.coupa_school_name = '<Use PhysicalDeliveryOfficeName>' AND sub.physicaldeliveryofficename = 'KIPP Whittier Middle' THEN 'Whittier Middle'
                 WHEN sn.coupa_school_name = '<Use PhysicalDeliveryOfficeName>' THEN sub.physicaldeliveryofficename
                 ELSE sn.coupa_school_name
                END
               ,sub.school_name) AS [School Name] -- override > lookup table (content group/department) > coupa
FROM
    (
     /* existing users */
     SELECT sr.employee_number
           ,sr.preferred_first_name
           ,sr.preferred_last_name
           ,sr.legal_entity_abbreviation
           ,sr.home_department
           ,sr.[status]

           ,ad.samaccountname
           ,ad.userprincipalname
           ,ad.mail
           ,ad.physicaldeliveryofficename

           ,cu.content_groups
           ,cu.school_name
           ,cu.mention_name
           ,cu.purchasing_license
           ,cu.roles
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
           ,sr.legal_entity_abbreviation
           ,sr.home_department
           ,sr.[status]

           ,ad.samaccountname
           ,ad.userprincipalname
           ,ad.mail
           ,ad.physicaldeliveryofficename

           ,NULL AS content_groups
           ,NULL AS school_name
           ,NULL AS mention_name
           ,'No' AS purchasing_license
           ,'Expense User' AS roles
     FROM gabby.people.staff_roster sr
     INNER JOIN gabby.adsi.user_attributes_static ad
       ON sr.employee_number = ad.employeenumber
      AND ISNUMERIC(ad.employeenumber) = 1
     LEFT JOIN gabby.coupa.users cu
       ON sr.employee_number = cu.employee_number
     WHERE sr.[status] NOT IN ('Prestart', 'Terminated')
       AND sr.home_department NOT IN ('Interns')
       AND sr.business_unit IN ('KIPP TEAM and Family Schools Inc.', 'KIPP Cooper Norcross Academy', 'KIPP Miami') -- only CMO/KCNA/MIA
       AND cu.employee_number IS NULL
    ) sub
LEFT JOIN gabby.coupa.school_name_lookup sn
  ON sub.legal_entity_abbreviation = sn.entity_abbv
 AND sub.home_department = sn.home_department
LEFT JOIN gabby.coupa.user_exceptions x
  ON sub.employee_number = x.employee_number
