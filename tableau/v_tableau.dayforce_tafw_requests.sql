USE gabby
GO

CREATE OR ALTER VIEW tableau.dayforce_tafw_requests AS

SELECT t.reference_code AS df_employee_number
      ,t.tafw_status
      ,DATEADD(MINUTE, DATEPART(TZOFFSET, t.time_requested), CONVERT(DATETIME2,t.time_requested)) AS tafw_request_date
      ,DATEADD(MINUTE, DATEPART(TZOFFSET, t.start_date_time), CONVERT(DATETIME2,t.start_date_time)) AS tafw_start_date
      ,DATEADD(MINUTE, DATEPART(TZOFFSET, t.end_date_time), CONVERT(DATETIME2,t.end_date_time)) AS tafw_end_date

      ,r.preferred_name AS employee_name
      ,r.userprincipalname AS employee_email
      ,r.location_description AS location
      ,r.home_department_description AS department
      ,r.job_title_description AS job_title
      ,r.position_status
      ,r.manager_df_employee_number
      ,r.manager_name
      ,r.manager_mail
FROM dayforce.tafw_requests t 
JOIN gabby.tableau.staff_roster r
  ON t.reference_code = r.df_employee_number 