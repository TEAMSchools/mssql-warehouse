USE gabby GO
CREATE OR ALTER VIEW
  adp.workers_business_communication AS
WITH
  business_comm AS (
    SELECT
      w.associate_oid,
      JSON_VALUE(w.worker_id, '$.idValue') AS worker_id,
      JSON_VALUE(bc.[value], '$.itemID') AS item_id,
      JSON_VALUE(bc.[value], '$.emailUri') AS email_uri,
      JSON_QUERY(bc.[value], '$.nameCode') AS namecode
    FROM
      gabby.adp.workers AS w
      CROSS APPLY OPENJSON (w.business_communication, '$.emails') AS bc
    WHERE
      w.business_communication != '{}'
  )
SELECT
  bc.associate_oid,
  bc.worker_id,
  bc.item_id,
  bc.email_uri,
  CAST(
    JSON_VALUE(bc.namecode, '$.codeValue') AS NVARCHAR(128)
  ) AS code_value,
  CAST(
    JSON_VALUE(bc.namecode, '$.shortName') AS NVARCHAR(128)
  ) AS short_name
FROM
  business_comm AS bc
