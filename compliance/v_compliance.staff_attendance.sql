USE gabby
GO

--CREATE OR ALTER VIEW compliance.staff_attendance AS

WITH calendars AS (
  SELECT c.db_name
        ,c.date_value
        ,c.insession
        ,c.type
        ,gabby.utilities.DATE_TO_SY(c.date_value) AS academic_year
        
        ,CASE 
          WHEN s.name = 'KIPP Sunrise Academy' THEN s.name 
          WHEN s.name = 'Lanning Sq Middle' THEN 'KIPP Lanning Square Middle'
          WHEN s.name = 'Lanning Sq Primary' THEN 'KIPP Lanning Square Primary'
          ELSE 'KIPP ' + s.name
         END AS school_name
  FROM gabby.powerschool.calendar_day c 
  LEFT OUTER JOIN gabby.powerschool.schools s
    ON c.schoolid = s.school_number 
  WHERE c.date_value > CONVERT(DATE,'2018-07-01')
    AND c.type IS NOT NULL
    AND s.name IS NOT NULL
    )

,employee_scaffold AS (
  SELECT r.df_employee_number
        ,r.first_name
        ,r.last_name
        ,r.legal_entity_name
        ,r.primary_site
        ,r.primary_job
        ,r.status
        ,c.date_value
        ,c.type AS day_status
        ,c.insession
        ,c.academic_year
  FROM gabby.dayforce.staff_roster r
  CROSS JOIN (SELECT DISTINCT date_value FROM calendars) d
  LEFT OUTER JOIN calendars c
    ON r.primary_site = c.school_name COLLATE Latin1_General_BIN
   AND d.date_value = c.date_value
  WHERE d.date_value BETWEEN original_hire_date AND CONVERT(DATE,(STR(gabby.utilities.GLOBAL_ACADEMIC_YEAR()+1) + '-07-01'))
  )	
,tafw AS (
  SELECT df_employee_number
        ,employee_name
        ,employee_email
        ,location
        ,tafw_start_date
        ,tafw_end_date
        ,CASE WHEN DATEDIFF(HOUR,tafw_start_date,tafw_end_date) > 9
              THEN 9.5
              ELSE DATEDIFF(HOUR,tafw_start_date,tafw_end_date)
         END AS hours
  FROM gabby.tableau.dayforce_tafw_requests
  WHERE tafw_status != 'Denied' 
    AND tafw_status != 'Canceled'
    AND job_title LIKE '%assistant%'
    AND job_title LIKE '%school leader%'
    )

,on_leave AS 
(SELECT s.number AS df_employee_number
       ,s.status
       ,s.effective_start AS leave_effective_start
       ,s.effective_end AS leave_effective_end
       ,d.date_value
FROM gabby.dayforce.employee_status s 
     LEFT OUTER JOIN (SELECT DISTINCT date_value FROM calendars) d
       ON d.date_value between s.effective_start AND s.effective_end
WHERE s.status != 'Active'
  AND s.status != 'Terminated'
  AND s.status != 'Pre-start'
)

SELECT e.df_employee_number
      ,e.first_name
      ,e.last_name
      ,e.legal_entity_name
      ,e.primary_site
      ,e.primary_job
      ,e.status
      ,e.date_value
      ,e.insession
      ,e.academic_year

      ,COALESCE(o.status,e.day_status) COLLATE Latin1_General_BIN AS day_status

      ,gabby.utilities.DATE_TO_SY(e.date_value) AS academic_year
      ,CASE WHEN e.day_status IN ('HOL','VAC') THEN 0
            WHEN o.status IS NOT NULL THEN 0
            ELSE COALESCE(9.5-t.hours,9.5) 
       END AS hours_worked
FROM employee_scaffold e LEFT JOIN tafw t
  ON e.df_employee_number = t.df_employee_number
 AND e.date_value >= tafw_start_date
 AND e.date_value <= tafw_end_date
 LEFT JOIN on_leave o
   ON e.df_employee_number = o.df_employee_number
  AND e.date_value = o.date_value
WHERE e.date_value IS NOT NULL