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
    ON CASE WHEN r.primary_site = 'KIPP Pathways at Bragaw' THEN 'KIPP Life Academy'
            WHEN r.primary_site = 'KIPP Pathways at 18th Ave' THEN 'KIPP BOLD Academy'
            ELSE r.primary_site 
       END = c.school_name COLLATE Latin1_General_BIN
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
    )

SELECT e.*
      ,CASE WHEN e.day_status IN ('HOL','VAC') THEN 0
            ELSE COALESCE(9.5-t.hours,9.5) 
       END AS hours_worked
FROM employee_scaffold e LEFT OUTER JOIN tafw t
  ON e.df_employee_number = t.df_employee_number
 AND e.date_value >= tafw_start_date
 AND e.date_value <= tafw_end_date
WHERE status != 'Terminated'
  AND date_value IS NOT NULL
  AND e.df_employee_number IN ('100278'
                              ,'100185'
                              ,'100173'
                              ,'100292'
                              ,'100378'
                              ,'100017'
                              ,'100837'
                              ,'100879'
                              ,'100843'
                              ,'100677'
                              ,'100115'
                              ,'100585'
                              ,'101122'
                              ,'101180'
                              ,'100489'
                              ,'101474'
                              ,'101635'
                              ,'100896'
                              ,'101082'
                              ,'100670'
                              ,'100604'
                              ,'100785'
                              ,'100531'
                              ,'100472'
                              ,'100801'
                              ,'100816'
                              ,'100915'
                              ,'100486'
                              ,'100586'
                              ,'100787'
                              ,'100014'
                              ,'100789')
ORDER BY e.df_employee_number, date_value
