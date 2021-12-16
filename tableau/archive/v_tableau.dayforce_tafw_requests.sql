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
      ,r.primary_site AS location
      ,r.primary_on_site_department AS department
      ,r.primary_job AS job_title
      ,r.status AS position_status
      ,r.manager_df_employee_number
      ,r.manager_name
      ,r.manager_userprincipalname AS manager_mail
FROM gabby.dayforce.tafw_requests t
JOIN gabby.people.staff_crosswalk_static r
  ON t.reference_code = r.df_employee_number