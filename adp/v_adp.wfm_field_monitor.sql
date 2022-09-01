USE gabby
GO

CREATE OR ALTER VIEW adp.wfm_field_monitor AS

WITH unpivoted AS (
  SELECT associate_id
        ,position_id
        ,date_modified
        ,field
        ,ISNULL([value], '') AS new_value
        ,LAG([value], 1, '') OVER(PARTITION BY position_id, field ORDER BY date_modified) AS prev_value
  FROM
      (
       SELECT associate_id
             ,position_id
             ,_modified AS date_modified
             ,CAST(business_unit_description AS NVARCHAR(MAX)) AS business_unit_description
             ,CAST(location_description AS NVARCHAR(MAX)) AS location_description
             ,CAST(home_department_description AS NVARCHAR(MAX)) AS home_department_description
             ,CAST(job_title_description AS NVARCHAR(MAX)) AS job_title_description
             ,CAST(reports_to_associate_id AS NVARCHAR(MAX)) AS reports_to_associate_id
             ,CAST(annual_salary AS NVARCHAR(MAX)) AS annual_salary
             ,CAST(flsa_description AS NVARCHAR(MAX)) AS flsa_description
             ,CAST(wfmgr_pay_rule AS NVARCHAR(MAX)) AS wfmgr_pay_rule
             ,CAST(wfmgr_accrual_profile AS NVARCHAR(MAX)) AS wfmgr_accrual_profile
             ,CAST(wfmgr_ee_type AS NVARCHAR(MAX)) AS wfmgr_ee_type
             ,CAST(wfmgr_badge_number AS NVARCHAR(MAX)) AS wfmgr_badge_number
       FROM gabby.adp.employees_archive
       WHERE position_id IS NOT NULL
         AND position_status <> 'Terminated'
      ) sub
  UNPIVOT(
    [value]
    FOR field IN (
       business_unit_description
      ,location_description
      ,home_department_description
      ,job_title_description
      ,reports_to_associate_id
      ,annual_salary
      ,flsa_description
      ,wfmgr_pay_rule
      ,wfmgr_accrual_profile
      ,wfmgr_ee_type
      ,wfmgr_badge_number
     )
   ) u
 )

SELECT u.associate_id
      ,u.position_id
      ,u.date_modified
      ,u.field
      ,u.prev_value
      ,u.new_value

      ,w.associate_oid
FROM unpivoted u
JOIN gabby.adp.workers_clean_static w
  ON u.associate_id = w.worker_id
WHERE u.new_value <> u.prev_value
