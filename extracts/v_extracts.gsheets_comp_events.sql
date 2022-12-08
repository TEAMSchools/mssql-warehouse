USE gabby
GO

CREATE OR ALTER VIEW extracts.gsheets_comp_events

WITH approvers AS (

SELECT primary_site
      ,userprincipalname AS sl_email
      ,manager_userprincipalname AS hos_email
FROM gabby.people.staff_crosswalk_static
WHERE primary_job = 'School Leader'
  AND status <> 'TERMINATED'
)


SELECT x.df_employee_number
      ,x.preferred_name
      ,x.primary_site
      ,x.primary_job
      ,x.legal_entity_name
      ,x.google_email
      ,x.userprincipalname
      
      ,a.sl_email
      ,a.hos_email

FROM gabby.people.staff_crosswalk_static x
LEFT JOIN approvers a
  ON x.primary_site = a.primary_site
WHERE x.status <> 'TERMINATED'