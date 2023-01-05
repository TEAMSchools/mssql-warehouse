CREATE OR ALTER VIEW
  whetstone.users_roles AS
SELECT
  u._id AS [user_id],
  CAST(
    JSON_VALUE(r.[value], '$._id') AS NVARCHAR(32)
  ) AS role_id,
  CAST(
    JSON_VALUE(r.[value], '$.name') AS NVARCHAR(32)
  ) AS role_name
FROM
  whetstone.users AS u
  CROSS APPLY OPENJSON (u.roles, '$') AS r
