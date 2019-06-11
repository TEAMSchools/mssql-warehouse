USE gabby
GO

CREATE OR ALTER VIEW tableau.staff_onboarding AS

SELECT o.employee_reference_code
      ,o.employee_first_name
      ,o.employee_last_name
      ,o.employee_display_name
      ,o.first_day
      ,REPLACE(RIGHT(LEFT(o.location_name,CHARINDEX(')',o.location_name)-1),4),'(','') AS region
      ,LEFT(o.location_name,CHARINDEX('(',o.location_name)-2) AS primary_site
      ,o.department_description
      ,RIGHT(o.position_name,LEN(o.position_name)-CHARINDEX('-',o.position_name)-1) AS primary_job
      ,o.manager_display_name
      ,o.manager_employee_number
      ,o.onboarding_task_completed_date
      ,o.onboarding_task_due_date
      ,o.onboarding_task_name
      ,o.onboarding_task_status
      ,o.onboarding_task_type

      ,r.userprincipalname AS employee_email
      ,r.manager_mail

      ,c.personal_email
FROM dayforce.onboarding o 
LEFT JOIN tableau.staff_roster r
  ON o.employee_reference_code = r.df_employee_number
LEFT JOIN dayforce.personal_contact_info c
  ON o.employee_reference_code = c.employee_number