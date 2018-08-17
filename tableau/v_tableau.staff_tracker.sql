USE gabby
GO

--CREATE OR ALTER VIEW tableau.staff_tracker AS

WITH prof_calendar AS (
  SELECT cal.schoolid
        ,cal.schoolid AS reporting_schoolid             
        ,cal.date_value
        ,gabby.utilities.DATE_TO_SY(cal.date_value) AS academic_year
             
        ,CONVERT(VARCHAR,dt.alt_name) AS term
  FROM gabby.powerschool.calendar_day cal
  JOIN gabby.reporting.reporting_terms dt
    ON cal.schoolid = dt.schoolid
   AND cal.date_value BETWEEN dt.start_date AND dt.end_date
   AND dt.identifier = 'RT'   
  WHERE cal.date_value BETWEEN DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1) AND GETDATE()
    AND (cal.insession = 1 OR cal.type = 'PD')  
 )

,tracking_long AS (
  SELECT employee_number
        ,pay_date as date
        ,pay_code
        ,pay_category
  FROM dayforce.employee_attendance
  )

,tracker_fields AS (
  SELECT DISTINCT
         pay_code
  FROM tracking_long
 )

,directory AS (
  SELECT CASE WHEN LEN(employeenumber) > 6 THEN RIGHT(employeenumber,LEN(employeenumber)-3) ELSE employeenumber END AS employeenumber
        ,mail
  FROM gabby.adsi.user_attributes_static
 )
 
SELECT df.df_employee_number
      ,df.preferred_name AS preferred_lastfirst       
      ,df.primary_site_schoolid AS schoolid
      ,df.primary_site AS location
      ,df.primary_job AS job_title
      ,df.manager_name AS manager        
      ,df.status AS position_status

      ,dir.mail AS email_address

      ,cal.academic_year
      ,cal.term
      ,cal.date_value            
       
      ,f.pay_code

FROM gabby.dayforce.staff_roster df
LEFT JOIN directory dir
  ON df.df_employee_number = dir.employeenumber
JOIN prof_calendar cal
  ON df.primary_site_schoolid = cal.schoolid
 AND df.position_effective_from_date <= cal.date_value
CROSS JOIN tracker_fields f
LEFT JOIN tracking_long pt
  ON df.df_employee_number = pt.employee_number
 AND cal.date_value = pt.date
 AND f.pay_code = pt.pay_code
WHERE df.status != 'TERMINATED'