USE gabby;
GO

CREATE OR ALTER VIEW tableau.staff_tracker AS

WITH emp_att AS (
  SELECT employee_number
        ,pay_date

        ,[absent]
        ,[late]
        ,[early out] AS early_out
        ,[partial day] AS partial_day
  FROM gabby.dayforce.employee_attendance
  PIVOT (
    MAX(excused_status)
    FOR absence_type IN ([absent], [late], [early out], [partial day])
   ) p
 )

SELECT df.df_employee_number
      ,df.preferred_name AS preferred_lastfirst
      ,df.legal_entity_name
      ,df.primary_site_school_level
      ,df.primary_site_schoolid AS schoolid
      ,df.primary_site AS location
      ,df.primary_job AS job_title
      ,df.manager_name AS manager
      ,df.status AS position_status
      ,df.position_effective_from_date AS academic_year_start_date
      ,COALESCE(df.termination_date, CONVERT(DATE,GETDATE())) AS academic_year_end_date
      
      ,dir.userprincipalname AS email_address
      
      ,cal.date_value      
      ,gabby.utilities.DATE_TO_SY(cal.date_value) AS academic_year
      
      ,CONVERT(VARCHAR(5), dt.alt_name) AS term
      
      ,pt.absent
      ,pt.late
      ,pt.early_out
      ,pt.partial_day
FROM gabby.dayforce.staff_roster df
LEFT JOIN gabby.adsi.user_attributes_static dir
  ON CONVERT(VARCHAR(25),df.df_employee_number) = dir.employeenumber
JOIN gabby.powerschool.calendar_day cal
  ON df.primary_site_schoolid = cal.schoolid 
 AND cal.date_value BETWEEN df.position_effective_from_date AND COALESCE(df.termination_date, GETDATE()) 
 AND (cal.insession = 1 OR cal.type = 'PD') 
 AND cal.schoolid != 0  
JOIN gabby.reporting.reporting_terms dt
  ON cal.schoolid = dt.schoolid
 AND cal.date_value BETWEEN dt.start_date AND dt.end_date
 AND dt.identifier = 'RT'
LEFT JOIN emp_att pt
  ON df.df_employee_number = pt.employee_number
 AND cal.date_value = pt.pay_date
WHERE COALESCE(df.termination_date, GETDATE()) >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)
  AND cal.date_value BETWEEN DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1) AND GETDATE()