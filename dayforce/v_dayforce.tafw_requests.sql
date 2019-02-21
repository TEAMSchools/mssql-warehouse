USE gabby
GO

--CREATE OR ALTER VIEW dayforce.tafw_requests AS

SELECT r.df_employee_number
       ,r.preferred_name AS employee_name
       ,r.userprincipalname AS employee_email
       ,r.location_description AS location
       ,r.home_department_description AS department
       ,r.job_title_description AS job_title
       ,r.position_status
       ,r.manager_df_employee_number
       ,r.manager_name

       ,rm.userprincipalname AS manager_email

       ,t.tafw_status
       ,CONVERT(DATE,LEFT(t.time_requested,10)) AS tafw_request_date
       ,CONVERT(DATE,LEFT(t.start_date_time,10)) AS tafw_start_date
       ,CONVERT(DATE,LEFT(t.end_date_time,10)) AS tafw_end_date

FROM tableau.staff_roster r LEFT OUTER JOIN tableau.staff_roster rm
  ON r.manager_df_employee_number = rm.df_employee_number
LEFT OUTER JOIN dayforce.tafw_requests t 
  ON r.df_employee_number = t.reference_code