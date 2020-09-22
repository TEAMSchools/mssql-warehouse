USE gabby;
GO

CREATE OR ALTER VIEW extracts.renlearn_teachers AS

SELECT Staff_id AS id
      ,Staff_id AS teachernumber
      ,School_id AS schoolid
      ,Last_name AS last_name
      ,First_name AS first_name
      ,NULL AS middle_name
      ,Username AS teacherloginid
      ,Staff_email AS staff_email
FROM gabby.extracts.clever_staff
