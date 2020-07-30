USE gabby
GO

CREATE OR ALTER VIEW gabby.people.staff_attendance_clean AS:

WITH attendance_clean AS (

  SELECT SUBSTRING(a.staff_member,CHARINDEX('(',a.staff_member)+1,6) AS df_number
        ,LEFT(a.staff_member,CHARINDEX('(',a.staff_member)-2) AS staff_name
        ,RIGHT(a.staff_member,LEN(a.staff_member) - CHARINDEX('-',a.staff_member)) AS attendance_location
        ,staff_member AS staff_info_string
        ,a.submitter_apps_account AS submitted_by
        ,a.attendance_date
        ,a.attendance_status
        ,CASE WHEN attendance_status LIKE '%Sick Day%' THEN 1 ELSE 0 END AS sick_day
        ,CASE WHEN attendance_status LIKE '%Personal Day%' THEN 1 ELSE 0 END AS personal_day
        ,CASE WHEN attendance_status LIKE '%Late/Tardy%' THEN 1 ELSE 0 END AS late_tardy
        ,CASE WHEN attendance_status LIKE '%Left_early%' THEN 1 ELSE 0 END AS left_early
        ,CASE WHEN attendance_status LIKE '%other%' THEN 1 ELSE 0 END AS absent_other
        ,CASE WHEN attendance_status LIKE '%override%' THEN 1 ELSE 0 END AS at_work
        ,CASE WHEN attendance_status LIKE '%Unapproved%' THEN 0 ELSE 1 END AS approved
        ,a.additional_notes
        ,a.timestamp AS submitted_on
  FROM gabby.people.staff_attendance a

  )

SELECT a.df_number
      ,a.staff_name
      ,a.attendance_location
      ,a.staff_info_string
      ,a.submitted_by
      ,a.attendance_date
      ,a.attendance_status
      ,a.sick_day
      ,a.personal_day
      ,a.late_tardy
      ,a.left_early
      ,a.absent_other
      ,a.at_work
      ,a.approved
      ,a.additional_notes
      ,a.submitted_on
      
      ,c.manager_name
      ,LOWER(c.manager_samaccountname) AS manager_samaccountname
      ,LOWER(c.samaccountname) AS samaccountname
      ,c.primary_site AS current_location
      ,c.legal_entity_name AS current_legal_entity

      ,ROW_NUMBER() OVER( PARTITION BY a.df_number, a.attendance_date ORDER BY a.submitted_on) AS rn_curr
FROM attendance_clean a
JOIN gabby.people.staff_crosswalk_static c
  ON a.df_number = c.df_employee_number