USE gabby
GO

CREATE OR ALTER VIEW extracts.renlearn_teachers AS

SELECT ps_teachernumber AS id
      ,ps_teachernumber AS teachernumber
      ,primary_site_schoolid AS schoolid
      ,preferred_last_name AS last_name
      ,preferred_first_name AS first_name
      ,NULL AS middle_name
      ,samaccountname AS teacherloginid
      ,userprincipalname AS staff_email
FROM gabby.people.staff_crosswalk_static
WHERE status != 'TERMINATED'
  AND primary_site_schoolid != 0