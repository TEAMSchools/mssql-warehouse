USE gabby
GO

CREATE OR ALTER VIEW extracts.adp_workers AS

WITH wfm_updates AS (
  SELECT DISTINCT associate_id
  FROM gabby.adp.wfm_field_monitor
  WHERE date_modified BETWEEN DATEADD(DAY, -7, CONVERT(DATE, GETDATE())) 
                          AND CONVERT(DATE, GETDATE())
 )

SELECT scw.employee_number

      ,w.associate_oid

      ,LOWER(ads.mail) AS mail

      ,CASE 
        WHEN wfm.associate_id IS NOT NULL
             THEN CONCAT('DR', CONVERT(NVARCHAR(8), GETDATE(), 112))
       END AS wfm_trigger
FROM gabby.people.staff_roster scw
JOIN gabby.adp.workers_clean_static w
  ON scw.associate_id = w.worker_id
LEFT JOIN gabby.adsi.user_attributes_static ads
  ON CONVERT(VARCHAR(25), scw.employee_number) = ads.employeenumber
LEFT JOIN wfm_updates wfm
  ON scw.associate_id = wfm.associate_id
WHERE scw.position_status <> 'Terminated'
  AND ads.mail IS NOT NULL
