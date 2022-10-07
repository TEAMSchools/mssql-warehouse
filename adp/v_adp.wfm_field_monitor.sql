USE gabby
GO

CREATE OR ALTER VIEW adp.wfm_field_monitor AS

WITH unpivoted AS (
  SELECT associate_id
        ,position_id
        ,date_modified
        ,row_hash AS new_value
        ,LAG(row_hash, 1) OVER(PARTITION BY position_id ORDER BY date_modified) AS prev_value
  FROM
      (
       SELECT associate_id
             ,position_id
             ,_modified AS date_modified
             ,HASHBYTES(
                'SHA2_512'
               ,CONCAT(
                  business_unit_description, '_'
                 ,location_description, '_'
                 ,home_department_description, '_'
                 ,job_title_description, '_'
                 ,reports_to_associate_id, '_'
                 ,annual_salary, '_'
                 ,flsa_description, '_'
                 ,wfmgr_pay_rule, '_'
                 ,wfmgr_accrual_profile, '_'
                 ,wfmgr_ee_type, '_'
                 ,wfmgr_badge_number
                )
              ) AS row_hash
       FROM gabby.adp.employees_archive
       WHERE position_id IS NOT NULL
         AND position_status <> 'Terminated'
         AND CAST(COALESCE(rehire_date, hire_date) AS DATE) >= CAST(CURRENT_TIMESTAMP AS DATE)
      ) sub
 )

SELECT u.associate_id
      ,u.position_id
      ,u.date_modified
      ,u.prev_value
      ,u.new_value

      ,w.associate_oid
FROM unpivoted u
INNER JOIN gabby.adp.workers_clean_static w
  ON u.associate_id = w.worker_id
WHERE (u.new_value <> u.prev_value)
   OR u.prev_value IS NULL
   OR u.new_value IS NULL
