USE gabby;
GO

CREATE OR ALTER VIEW tableau.staff_tracker AS

WITH emp_att AS (
  SELECT p.employee_number
        ,p.pay_date
        ,[absent]
        ,[late]
        ,[early out] AS early_out
        ,[partial day] AS partial_day
  FROM
      (
       SELECT employee_number
             ,pay_date
             ,excused_status
             ,absence_type
       FROM gabby.dayforce.employee_attendance
      ) sub
  PIVOT (
    MAX(excused_status)
    FOR absence_type IN ([absent], [late], [early out], [partial day])
   ) p
 )

,tafw AS (
  SELECT sub.df_employee_number
        ,CONVERT(DATE, sub.tafw_start_date) AS tafw_start_date
        ,CONVERT(DATE, sub.tafw_end_date) AS tafw_end_date
        ,CASE
          WHEN DATEDIFF(HOUR, sub.tafw_start_date, sub.tafw_end_date) > 9 THEN 9.5
          ELSE DATEDIFF(HOUR, sub.tafw_start_date, sub.tafw_end_date)
         END AS tafw_hours
  FROM
      (
       SELECT t.reference_code AS df_employee_number
             ,DATEADD(MINUTE, DATEPART(TZOFFSET, t.start_date_time), CONVERT(DATETIME2, t.start_date_time)) AS tafw_start_date
             ,DATEADD(MINUTE, DATEPART(TZOFFSET, t.end_date_time), CONVERT(DATETIME2, t.end_date_time)) AS tafw_end_date
       FROM gabby.dayforce.tafw_requests t
       WHERE t.tafw_status IN ('Approved', 'Pending', 'Cancellation Pending')
      ) sub
 )

,leave AS (
  SELECT s.number AS df_employee_number
        ,s.[status]
        ,CONVERT(DATE, s.effective_start) AS effective_start
        ,COALESCE(CONVERT(DATE, s.effective_end), CONVERT(DATE, GETDATE())) AS effective_end
  FROM gabby.dayforce.employee_status s
  WHERE s.[status] IN ('Administrative Leave', 'Medical Leave of Absence', 'Personal Leave of Absence')
 )

SELECT df.df_employee_number
      ,df.preferred_name AS preferred_lastfirst
      ,df.legal_entity_name
      ,df.primary_site_school_level
      ,df.primary_site_schoolid AS schoolid
      ,df.primary_site AS [location]
      ,df.primary_job AS job_title
      ,df.manager_name AS manager
      ,df.[status] AS position_status
      ,df.position_effective_from_date AS academic_year_start_date
      ,COALESCE(df.termination_date, CONVERT(DATE,GETDATE())) AS academic_year_end_date
      ,df.userprincipalname AS email_address
      
      ,cal.date_value
      ,cal.insession
      ,gabby.utilities.DATE_TO_SY(cal.date_value) AS academic_year
      
      ,CONVERT(VARCHAR(5), dt.alt_name) AS term
      
      ,pt.[absent]
      ,pt.late
      ,pt.early_out
      ,pt.partial_day

      ,COALESCE(l.[status], cal.[type]) COLLATE Latin1_General_BIN AS day_status
      ,CASE 
        WHEN cal.[type] IN ('HOL','VAC') THEN 0
        WHEN l.[status] IS NOT NULL THEN 0
        ELSE 9.5 - ISNULL(t.tafw_hours, 0)
       END AS hours_worked
FROM gabby.people.staff_crosswalk_static df
JOIN gabby.powerschool.calendar_day cal
  ON df.primary_site_schoolid = cal.schoolid 
 AND cal.date_value BETWEEN df.position_effective_from_date AND COALESCE(df.termination_date, GETDATE()) 
 AND (cal.insession = 1 OR cal.[type] = 'PD') 
 AND cal.date_value BETWEEN DATEFROMPARTS((gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1), 7, 1) AND GETDATE()
JOIN gabby.reporting.reporting_terms dt
  ON cal.schoolid = dt.schoolid
 AND cal.date_value BETWEEN dt.[start_date] AND dt.end_date
 AND dt.identifier = 'RT'
 AND dt._fivetran_deleted = 0
LEFT JOIN emp_att pt
  ON df.df_employee_number = pt.employee_number
 AND cal.date_value = pt.pay_date
LEFT JOIN tafw t
  ON df.df_employee_number = t.df_employee_number
 AND cal.date_value BETWEEN t.tafw_start_date AND t.tafw_end_date
LEFT JOIN leave l
  ON df.df_employee_number = l.df_employee_number
 AND cal.date_value BETWEEN l.effective_start AND l.effective_end
WHERE COALESCE(df.termination_date, GETDATE()) >= DATEFROMPARTS((gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1), 7, 1)
  AND df.primary_site_schoolid != 0