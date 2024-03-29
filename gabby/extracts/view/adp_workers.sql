CREATE OR ALTER VIEW
  extracts.adp_workers AS
WITH
  wfm_updates AS (
    SELECT DISTINCT
      associate_id
    FROM
      adp.wfm_field_monitor
    WHERE
      (
        CAST(date_modified AS DATE) BETWEEN DATEADD(
          DAY,
          -7,
          CAST(CURRENT_TIMESTAMP AS DATE)
        ) AND CAST(CURRENT_TIMESTAMP AS DATE)
      )
  )
SELECT
  scw.employee_number,
  w.associate_oid,
  LOWER(ads.mail) AS mail,
  CASE
    WHEN wfm.associate_id IS NOT NULL THEN CONCAT(
      'DR',
      CONVERT(
        NVARCHAR(8),
        CURRENT_TIMESTAMP,
        112
      )
    )
  END AS wfm_trigger
FROM
  people.staff_roster AS scw
  INNER JOIN adp.workers_clean_static AS w ON (scw.associate_id = w.worker_id)
  LEFT JOIN adsi.user_attributes_static AS ads ON (
    CAST(
      scw.employee_number AS VARCHAR(25)
    ) = ads.employeenumber
  )
  LEFT JOIN wfm_updates AS wfm ON (
    scw.associate_id = wfm.associate_id
  )
WHERE
  scw.position_status != 'Terminated'
  AND ads.mail IS NOT NULL
