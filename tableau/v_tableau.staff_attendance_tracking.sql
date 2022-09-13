USE gabby 
GO

CREATE OR ALTER view tableau.staff_attendance_tracking AS

WITH school_ids AS (
  SELECT sub.[location]

        ,cw.ps_school_id
        ,cw.site_name_clean
        --,cw.site_abbreviation --add this after Charlie pushes update
  FROM
      (
       SELECT td.[location]
             ,SUBSTRING(
                td.[location]
               ,10
               ,LEN(td.[location]) - 10 - (LEN(td.[location]) - CHARINDEX('/', td.[location], 10))
              ) AS school_name
       FROM gabby.adp.wfm_time_details td
       WHERE td.[location] LIKE '%KIPP%'
       GROUP BY td.[location]
      ) sub
  LEFT JOIN gabby.people.school_crosswalk cw
    ON sub.school_name = cw.site_name
  )

,school_leaders AS (
  SELECT primary_site AS sl_primary_site
        ,samaccountname AS sl_samaccountname
  FROM gabby.people.staff_crosswalk_static
  WHERE primary_job = 'School Leader'
    AND [status] <> 'Terminated'
 )

,holidays AS (
  SELECT [location]
        ,transaction_apply_date
        ,transaction_type AS holiday_status
  FROM gabby.adp.wfm_time_details
  WHERE transaction_type = 'Worked Holiday Edit'
  GROUP BY [location], transaction_apply_date, transaction_type
 )

,snow_days AS (
  SELECT cal.[db_name]
        ,cal.schoolid
        ,cal.date_value
        ,cal.[type]

        ,sch.[name] AS school
  FROM gabby.powerschool.calendar_day cal
  LEFT JOIN gabby.powerschool.schools sch
    ON cal.schoolid = sch.school_number
   AND cal.[db_name] = sch.[db_name]
  WHERE cal.[type] = 'WS'
 )

,last_accrual_day AS (
  SELECT last_updated
        ,employee_name_id_
        ,accrual_code
        ,accrual_code + '_2' AS accrual_code_2
        ,accrual_taken_to_date_hours_
        ,accrual_available_balance_hours_
  FROM
      (
       SELECT _modified AS last_updated
             ,employee_name_id_
             ,accrual_code
             ,accrual_taken_to_date_hours_
             ,accrual_available_balance_hours_
             ,MAX(_modified) OVER(PARTITION BY employee_name_id_, accrual_code) AS max_last_updated
       FROM gabby.adp.wfm_accrual_reporting_period_summary
      ) sub
  WHERE last_updated = max_last_updated
 )

,accruals_taken AS (
  SELECT last_updated
        ,employee_name_id_
        ,[Vacation] AS vacation_taken
        ,[PTO] AS pto_taken
        ,[No Accrual] AS no_accrual_taken
        ,[Unused PTO] AS unused_pto_taken
        ,[Sick] AS sick_taken
  FROM
      (
       SELECT last_updated
             ,employee_name_id_
             ,accrual_code
             ,accrual_taken_to_date_hours_
       FROM last_accrual_day
      ) sub
   PIVOT(
     MAX(accrual_taken_to_date_hours_)
     FOR accrual_code IN ([Vacation], [PTO], [No Accrual], [Unused PTO], [Sick])
   ) p
 )

,accruals_balance AS (
  SELECT last_updated
        ,employee_name_id_
        ,[Vacation] AS vacation_balance
        ,[PTO] AS pto_balance
        ,[No Accrual] AS no_accrual_balance
        ,[Unused PTO] AS unused_pto_balance
        ,[Sick] AS sick_balance
  FROM 
      (
       SELECT last_updated
             ,employee_name_id_
             ,accrual_code
             ,accrual_available_balance_hours_
       FROM last_accrual_day
      ) sub
  PIVOT(
    MAX(accrual_available_balance_hours_) 
    FOR accrual_code IN ([Vacation], [PTO], [No Accrual], [Unused PTO], [Sick])
  ) p
 )

,time_details_clean AS (
  SELECT _modified
        ,employee_name
        ,job
        ,[location]
        ,transaction_apply_date
        ,transaction_apply_to
        ,transaction_type
        ,transaction_in_exceptions
        ,transaction_out_exceptions
        ,[hours]
        ,[money]
        ,[days]
        ,transaction_start_date_time
        ,transaction_end_date_time
        ,employee_payrule
  FROM gabby.adp.wfm_time_details td
  GROUP BY _modified
          ,employee_name
          ,job
          ,[location]
          ,transaction_apply_date
          ,transaction_apply_to
          ,transaction_type
          ,transaction_in_exceptions
          ,transaction_out_exceptions
          ,[hours]
          ,[money]
          ,[days]
          ,transaction_start_date_time
          ,transaction_end_date_time
          ,employee_payrule
  )

SELECT td.job AS job_title
      ,td.[location] AS budget_location
      ,td.transaction_apply_to
      ,td.transaction_type
      ,td.transaction_in_exceptions
      ,td.transaction_out_exceptions
      ,td.[hours]
      ,CONVERT(DATE, td.transaction_apply_date) AS work_date
      ,CONVERT(DATETIME2, td.transaction_start_date_time) AS transaction_start_date_time
      ,CONVERT(DATETIME2, td.transaction_end_date_time) AS transaction_end_date_time
      ,gabby.utilities.DATE_TO_SY(td.transaction_apply_date) AS academic_year
      ,SUBSTRING(
         td.employee_name
        ,LEN(td.employee_name) - 9
        ,9
       ) AS adp_associate_id
      ,CASE 
        WHEN td.transaction_in_exceptions = 'Late In' THEN 1 
        WHEN td.transaction_in_exceptions = 'Entrada tardía' THEN 1
        ELSE 0 
       END AS late_status
      ,CASE 
        WHEN td.transaction_out_exceptions = 'Early Out' THEN 1 
        WHEN td.transaction_out_exceptions = 'Salida temprana' THEN 1
        ELSE 0 
       END AS early_out_status
      ,CASE 
        WHEN td.transaction_in_exceptions = 'Missed In Punch' THEN 1
        WHEN td.transaction_out_exceptions = 'Missed Out Punch' THEN 1
        WHEN td.transaction_in_exceptions = 'Marcaje de entrada omitido' THEN 1
        WHEN td.transaction_out_exceptions = 'Marcaje de salida omitido' THEN 1
        ELSE 0 
       END AS missed_punch_status

      ,id.ps_school_id
      ,id.site_name_clean
      --,id.site_abbreviation --Add back later

      ,cw.df_employee_number
      ,cw.preferred_name
      ,cw.manager_name
      ,cw.primary_site AS location_current
      ,LOWER(cw.samaccountname) AS staff_samaccountname
      ,LOWER(cw.manager_samaccountname) AS manager_samaccountname

      ,LOWER(sl.sl_samaccountname) AS sl_samaccountname

      ,CASE 
        WHEN h.holiday_status = 'Worked Holiday Edit' 
         AND td.transaction_apply_to = 'Worked Shift Segment' 
             THEN 1
        WHEN h.holiday_status = 'Worked Holiday Edit' THEN 0
        WHEN sd.[type] = 'WS' 
         AND td.transaction_start_date_time IS NULL 
         AND td.transaction_end_date_time IS NULL 
             THEN 0
        WHEN td.transaction_apply_to IN ('Jury Duty','Bereavement','Religious Observance') THEN 0
        ELSE 1
       END AS denominator_day
      ,CASE 
        WHEN h.holiday_status = 'Worked Holiday Edit' 
             THEN 1
        WHEN sd.[type] = 'WS' 
         AND td.transaction_start_date_time IS NOT NULL 
         AND td.transaction_end_date_time IS NOT NULL 
             THEN 1
        WHEN td.transaction_apply_to = 'Professional Development' THEN 1
        WHEN td.transaction_apply_to IS NULL THEN 1 
        ELSE 0 
       END AS present_status

      ,act.last_updated AS accrual_last_update
      ,act.no_accrual_taken
      ,act.pto_taken
      ,act.sick_taken
      ,act.unused_pto_taken
      ,act.vacation_taken

      ,acb.no_accrual_balance
      ,acb.pto_balance
      ,acb.sick_balance
      ,acb.unused_pto_balance
      ,acb.vacation_balance
FROM time_details_clean td
INNER JOIN school_ids id
  ON td.[location] = id.[location]
LEFT JOIN holidays h
  ON td.[location] = h.[location]
 AND td.transaction_apply_date = h.transaction_apply_date
LEFT JOIN snow_days sd
  ON sd.schoolid = id.ps_school_id
 AND sd.date_value = CONVERT(DATE, td.transaction_apply_date)
LEFT JOIN gabby.people.staff_crosswalk_static cw
  ON SUBSTRING(td.employee_name, LEN(td.employee_name) - 9, 9) = cw.adp_associate_id
LEFT JOIN school_leaders sl
  ON  cw.primary_site = sl.sl_primary_site
LEFT JOIN accruals_taken act
  ON td.employee_name = act.employee_name_id_
LEFT JOIN accruals_balance acb
  ON td.employee_name = acb.employee_name_id_
WHERE td.transaction_type <> 'Worked Holiday Edit'
  AND td.transaction_apply_date >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 8, 15)