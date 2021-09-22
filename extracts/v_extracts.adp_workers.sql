USE gabby
GO

CREATE OR ALTER VIEW extracts.adp_workers AS

WITH wfm_updates AS (
  SELECT DISTINCT associate_id
  FROM gabby.adp.wfm_field_monitor
 )

SELECT w.associate_oid

      ,scw.df_employee_number AS employee_number
      ,LOWER(scw.mail) AS mail

      ,CASE 
        WHEN wfm.associate_id IS NOT NULL
             THEN CONCAT('DR', CONVERT(NVARCHAR(8), GETDATE(), 112))
       END AS wfm_trigger
FROM gabby.people.staff_crosswalk_static scw
JOIN gabby.adp.workers_clean_static w
  ON scw.adp_associate_id = w.worker_id
LEFT JOIN wfm_updates wfm
  ON scw.adp_associate_id = wfm.associate_id
WHERE scw.[status] <> 'Terminated'
  AND scw.mail IS NOT NULL
