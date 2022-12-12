USE gabby
GO

--CREATE OR ALTER VIEW extracts.gsheets_comp_events

WITH school_approvers AS (
SELECT x.primary_site
      ,x.userprincipalname AS sl_email
      ,x.manager_userprincipalname AS hos_email
      ,x.manager_df_employee_number
      ,x.google_email AS sl_google
FROM gabby.people.staff_crosswalk_static x
WHERE x.primary_job = 'School Leader'
  AND x.status <> 'TERMINATED'
)

,manager_approvers AS (
SELECT df_employee_number
      ,userprincipalname AS manager_email
      ,google_email AS manager_google
FROM gabby.people.staff_crosswalk_static
)

,hos_approvers AS (
SELECT df_employee_number
      ,userprincipalname AS hos_email
      ,google_email AS hos_google
FROM gabby.people.staff_crosswalk_static x
JOIN school_approvers s
  ON x.df_employee_number = s.manager_df_employee_number

)

SELECT x.payroll_company_code
      ,x.legal_entity_name
      ,CONCAT(x.preferred_name, ' - ', x.primary_site) AS preferred_name
      ,x.file_number
      ,x.primary_site
      ,x.primary_job
      
      ,COALESCE(a.sl_google,m.manager_google) AS first_approver
      ,COALESCE(h.hos_google, 'cbaldor@apps.teamschools.org') AS second_approver_username
   
FROM gabby.people.staff_crosswalk_static x
LEFT JOIN school_approvers a
  ON x.primary_site = a.primary_site
LEFT JOIN hos_approvers h
  ON x.manager_df_employee_number = h.df_employee_number
LEFT JOIN manager_approvers m
  ON x.manager_df_employee_number = m.df_employee_number
WHERE x.status <> 'TERMINATED'
