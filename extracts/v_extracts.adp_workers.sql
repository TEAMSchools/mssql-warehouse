USE gabby
GO

CREATE OR ALTER VIEW extracts.adp_workers AS

SELECT w.associate_oid
      ,LOWER(scw.mail) AS mail
FROM gabby.people.staff_crosswalk_static scw
JOIN gabby.adp.workers_clean_static w
  ON scw.adp_associate_id = w.worker_id
WHERE scw.[status] <> 'Terminated'
  AND scw.mail IS NOT NULL
