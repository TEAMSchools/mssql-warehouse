USE gabby
GO

CREATE OR ALTER VIEW extracts.coupa_users AS

SELECT LOWER(scw.samaccountname) AS [Login]
      ,cu.ID -- NULL for new users?
      ,'active' AS [Status] -- do we need to deactivate too?
      ,COALESCE(cu.purchasing_user, 'No') AS [Purchasing User] -- preserve what's in Coupa, otherwise No
      ,'Yes' AS [Expense User]
      ,'SAML' AS [Authentication Method]
      ,LOWER(scw.userprincipalname) AS [Sso Identifier]
      ,'No' AS [Generate Password And Notify User]
      ,LOWER(scw.mail) AS [Email]
      ,scw.preferred_first_name AS [First Name]
      ,scw.preferred_last_name AS [Last Name]
      ,scw.df_employee_number AS [Employee Number]
      ,COALESCE(cu.user_role_names, 'Expense User') AS [User Role Names] -- preserve what's in Coupa, otherwise use HRIS
      ,COALESCE(cu.content_groups
               ,CASE
                 WHEN scw.legal_entity_name = 'KIPP New Jersey' THEN 'KIPP NJ'
                 WHEN scw.legal_entity_name = 'KIPP Cooper Norcross Academy' THEN 'KCNA'
                END) AS [Content Groups] -- preserve what's in Coupa, otherwise use HRIS? what if they move?
      ,COALESCE(cu.mention_name, CONCAT(scw.preferred_first_name, scw.preferred_last_name )) AS [Mention Name] -- preserve what's in Coupa, otherwise use HRIS
      ,COALESCE(cu.school_name, scw.primary_site) AS [School Name] -- preserve what's in Coupa, otherwise use HRIS? what if they move?
FROM gabby.people.staff_crosswalk_static scw
LEFT JOIN gabby.coupa.users cu
  ON scw.userprincipalname = cu.sso_identifier
WHERE scw.[status] NOT IN ('Terminated', 'Prestart') -- include prestart?
  AND scw.primary_on_site_department NOT IN ('Interns')
  AND scw.legal_entity_name IN ('KIPP New Jersey', 'KIPP Cooper Norcross Academy')
