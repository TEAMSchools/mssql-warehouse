USE gabby
GO

CREATE OR ALTER VIEW adp.wfm_field_monitor AS

WITH unpivoted AS (
  SELECT associate_id
        ,position_id
        ,date_modified
        ,field
        ,[value] AS new_value
        ,LAG([value], 1) OVER(PARTITION BY position_id, field ORDER BY date_modified) AS prev_value
  FROM
      (
       SELECT associate_id
             ,position_id
             ,_modified AS date_modified
             ,CONVERT(NVARCHAR(MAX), business_unit_description) AS business_unit_description
             ,CONVERT(NVARCHAR(MAX), location_description) AS location_description
             ,CONVERT(NVARCHAR(MAX), home_department_description) AS home_department_description
             ,CONVERT(NVARCHAR(MAX), job_title_description) AS job_title_description
             ,CONVERT(NVARCHAR(MAX), reports_to_associate_id) AS reports_to_associate_id
             ,CONVERT(NVARCHAR(MAX), annual_salary) AS annual_salary
             ,CONVERT(NVARCHAR(MAX), flsa_description) AS flsa_description
             ,CONVERT(NVARCHAR(MAX), wfmgr_pay_rule) AS wfmgr_pay_rule
             ,CONVERT(NVARCHAR(MAX), wfmgr_accrual_profile) AS wfmgr_accrual_profile
             ,CONVERT(NVARCHAR(MAX), wfmgr_ee_type) AS wfmgr_ee_type
       FROM gabby.adp.employees_archive
       WHERE position_id IS NOT NULL
         AND position_status <> 'Terminated'
         AND CONVERT(DATE, _modified) BETWEEN DATEADD(DAY, -4, CONVERT(DATE, GETDATE()))
                                          AND CONVERT(DATE, GETDATE())
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
