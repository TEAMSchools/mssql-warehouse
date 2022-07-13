USE gabby
GO

--CREATE OR ALTER VIEW pm.assignment_editors

SELECT df_employee_number
      ,google_email
      ,primary_job
      ,primary_site
      ,primary_on_site_department
      ,legal_entity_name
FROM people.staff_crosswalk_static
WHERE primary_job IN('Director School Operations','School Leader','Director Campus Operations', 'Fellow School Operations Director')
   OR primary_on_site_department IN ('Data')
   OR primary_job IN ('Managing Director','Chief Academic Officer') AND primary_on_site_department IN ('KTC','Enrollment and Compliance','Teaching and Learning')