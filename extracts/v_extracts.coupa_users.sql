USE gabby
GO

CREATE OR ALTER VIEW extracts.coupa_users AS

SELECT LOWER(scw.samaccountname) AS [Login]
      ,NULL AS ID -- NULL for new users
      ,'active' AS [Status]
      ,'No' AS [Purchasing User]
      ,'Yes' AS [Expense User]
      ,'SAML' AS [Authentication Method]
      ,LOWER(scw.userprincipalname) AS [Sso Identifier]
      ,'No' AS [Generate Password And Notify User]
      ,LOWER(scw.mail) AS [Email]
      ,scw.preferred_first_name AS [First Name]
      ,scw.preferred_last_name AS [Last Name]
      ,scw.df_employee_number AS [Employee Number]
      ,'Expense User' AS [User Role Names]
      ,CASE
        WHEN scw.legal_entity_name = 'KIPP New Jersey' THEN 'KIPP NJ'
        WHEN scw.legal_entity_name = 'TEAM Academy Charter Schools' THEN 'TEAM'
        WHEN scw.legal_entity_name = 'KIPP Cooper Norcross Academy' THEN 'KCNA'
        WHEN scw.legal_entity_name = 'KIPP Miami' THEN 'MIA'
       END AS [Content Groups]
      ,CONCAT(scw.preferred_first_name, scw.preferred_last_name ) AS [Mention Name]
      ,scw.primary_site AS [School Name] -- match on lookup table (content group/department)
FROM gabby.people.staff_crosswalk_static scw
LEFT JOIN gabby.coupa.users cu
  ON scw.df_employee_number = cu.employee_number
WHERE scw.[status] NOT IN ('Prestart', 'Terminated')
  AND scw.primary_on_site_department NOT IN ('Interns') -- exclude interns
  AND cu.employee_number IS NULL
  AND scw.legal_entity_name IN ('KIPP New Jersey', 'KIPP Cooper Norcross Academy') -- only TEAM/KCNA temporarily

UNION ALL

SELECT LOWER(scw.samaccountname) AS [Login]
      ,cu.ID
      ,CASE
        WHEN scw.[status] = 'Terminated' THEN 'inactive'
        ELSE 'active'
       END AS [Status]
      ,COALESCE(cu.purchasing_user, 'No') AS [Purchasing User] -- preserve what's in Coupa, otherwise No
      ,'Yes' AS [Expense User]
      ,'SAML' AS [Authentication Method]
      ,LOWER(scw.userprincipalname) AS [Sso Identifier]
      ,'No' AS [Generate Password And Notify User]
      ,LOWER(scw.mail) AS [Email]
      ,scw.preferred_first_name AS [First Name]
      ,scw.preferred_last_name AS [Last Name]
      ,scw.df_employee_number AS [Employee Number]
      ,CONCAT('Expense User, ', cu.user_role_names) AS [User Role Names]
      ,COALESCE(cu.content_groups
               ,CASE
                 WHEN scw.legal_entity_name = 'KIPP New Jersey' THEN 'KIPP NJ'
                 WHEN scw.legal_entity_name = 'TEAM Academy Charter Schools' THEN 'TEAM'
                 WHEN scw.legal_entity_name = 'KIPP Cooper Norcross Academy' THEN 'KCNA'
                 WHEN scw.legal_entity_name = 'KIPP Miami' THEN 'MIA'
                END) AS [Content Groups] -- preserve what's in Coupa, otherwise use HRIS
      ,COALESCE(cu.mention_name, CONCAT(scw.preferred_first_name, scw.preferred_last_name )) AS [Mention Name] -- preserve what's in Coupa, otherwise use HRIS
      ,COALESCE(cu.school_name, scw.primary_site) AS [School Name] -- preserve what's in Coupa, otherwise use match on lookup table (content group/department)
FROM gabby.people.staff_crosswalk_static scw
INNER JOIN gabby.coupa.users cu
  ON scw.df_employee_number = cu.employee_number
WHERE scw.[status] <> 'Prestart'
  AND scw.primary_on_site_department NOT IN ('Interns') -- exclude interns
