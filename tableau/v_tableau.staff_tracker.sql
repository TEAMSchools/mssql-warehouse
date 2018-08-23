USE gabby
GO

--CREATE OR ALTER VIEW tableau.staff_tracker AS

WITH pt AS

    (SELECT employee_number
           ,pay_date
           ,pay_category
           ,pay_code
           ,excused_status
           ,absent
           ,late
           ,early_out
    FROM dayforce.employee_attendance
    PIVOT(
    MAX(absence_type) for absence_type IN ([absent]
                                          ,[late]
                                          ,[early_out])) p
                                          
    )

SELECT df.df_employee_number
      ,df.preferred_name AS preferred_lastfirst       
      ,df.primary_site_schoolid AS schoolid
      ,df.primary_site AS location
      ,df.primary_job AS job_title
      ,df.manager_name AS manager        
      ,df.status AS position_status

      ,dir.userprincipalname AS email_address
      
      ,cal.date_value            
      ,gabby.utilities.DATE_TO_SY(cal.date_value) AS academic_year

      ,CONVERT(VARCHAR(5),dt.alt_name) AS term
             
      ,pt.pay_code
      ,pt.pay_category
      ,pt.excused_status
      ,pt.absent
      ,pt.late
      ,pt.early_out
      
FROM gabby.dayforce.staff_roster df
LEFT JOIN gabby.adsi.user_attributes_static dir
  ON CONVERT(VARCHAR(25),df.df_employee_number) = dir.employeenumber
JOIN gabby.powerschool.calendar_day cal
  ON df.primary_site_schoolid = cal.schoolid
 AND df.position_effective_from_date <= cal.date_value
 AND cal.date_value BETWEEN DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1) AND GETDATE()
 AND (cal.insession = 1 OR cal.type = 'PD')  
 AND cal.schoolid != 0
 AND COALESCE(df.rehire_date,df.original_hire_date) <= cal.date_value
 AND (termination_date IS NULL OR termination_date >= cal.date_value)
JOIN gabby.reporting.reporting_terms dt
  ON cal.schoolid = dt.schoolid
 AND cal.date_value BETWEEN dt.start_date AND dt.end_date
 AND dt.identifier = 'RT' 
LEFT JOIN pt
  ON df.df_employee_number = pt.employee_number
 AND cal.date_value = pt.pay_date
 AND pt.pay_code IS NOT NULL 
WHERE COALESCE(df.termination_date, GETDATE()) >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)