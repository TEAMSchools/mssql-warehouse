USE gabby
GO

CREATE OR ALTER VIEW tableau.staff_onboarding AS

SELECT o.employee_reference_code
      ,o.onboarding_task_type
      ,o.onboarding_task_name
      ,o.onboarding_task_status
      ,CONVERT(DATE, o.onboarding_task_due_date) AS onboarding_task_due_date
      ,CONVERT(DATE, o.onboarding_task_completed_date) AS onboarding_task_completed_date
      ,CONVERT(DATE, o.first_day) AS first_day

      ,r.preferred_first_name AS employee_first_name
      ,r.preferred_last_name AS employee_last_name
      ,r.preferred_name AS employee_display_name
      ,r.legal_entity_name AS region
      ,r.primary_site
      ,r.primary_job
      ,r.primary_on_site_department AS department_description
      ,r.userprincipalname AS employee_email
      ,r.manager_df_employee_number AS manager_employee_number
      ,r.manager_name AS manager_display_name
      ,r.manager_userprincipalname AS manager_mail
      ,r.personal_email
FROM gabby.dayforce.onboarding o 
JOIN gabby.people.staff_crosswalk_static r
  ON o.employee_reference_code = r.df_employee_number
 AND r.[status] <> 'Terminated'
