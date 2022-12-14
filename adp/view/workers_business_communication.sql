USE gabby GO
CREATE OR ALTER VIEW
  adp.workers_business_communication AS
SELECT
  gabby.adp.workers.associate_oid,
  bc.itemid AS item_id,
  bc.emailuri AS email_uri,
  JSON_VALUE(gabby.adp.workers.worker_id, '$.idValue') AS worker_id,
  CAST(
    JSON_VALUE(bc.namecode, '$.codeValue') AS NVARCHAR(128)
  ) AS code_value,
  CAST(
    JSON_VALUE(bc.namecode, '$.shortName') AS NVARCHAR(128)
  ) AS short_name
FROM
  gabby.adp.workers
  CROSS APPLY OPENJSON (
    gabby.adp.workers.business_communication,
    '$.emails'
  )
WITH
  (
    itemID NVARCHAR(128),
    emailUri NVARCHAR(128),
    nameCode NVARCHAR(MAX) AS JSON
  ) bc
WHERE
  w.business_communication <> '{}'
