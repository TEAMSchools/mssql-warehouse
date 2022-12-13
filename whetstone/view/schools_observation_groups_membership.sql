USE gabby GO
CREATE OR ALTER VIEW
  whetstone.schools_observation_groups_membership AS
WITH
  observation_groups AS (
    SELECT
      s._id AS school_id,
      ogs._id AS observation_group_id,
      ogs.[name] AS observation_group_name,
      ogs.observers AS membership,
      'observers' AS role_name
    FROM
      gabby.whetstone.schools s
      CROSS APPLY OPENJSON (s.observation_groups, '$')
    WITH
      (_id NVARCHAR(MAX), [name] NVARCHAR(MAX), observers NVARCHAR(MAX) AS JSON) AS ogs
    WHERE
      ogs.observers <> '[]'
    UNION ALL
    SELECT
      s._id AS school_id,
      ogs._id AS observation_group_id,
      ogs.[name] AS observation_group_name,
      ogs.observees AS membership,
      'observees' AS role_name
    FROM
      gabby.whetstone.schools s
      CROSS APPLY OPENJSON (s.observation_groups, '$')
    WITH
      (_id NVARCHAR(MAX), [name] NVARCHAR(MAX), observees NVARCHAR(MAX) AS JSON) AS ogs
    WHERE
      ogs.observees <> '[]'
    UNION ALL
    SELECT
      s._id AS school_id,
      ogs._id AS observation_group_id,
      ogs.[name] AS observation_group_name,
      ogs.admins AS membership,
      'admins' AS role_name
    FROM
      gabby.whetstone.schools s
      CROSS APPLY OPENJSON (s.observation_groups, '$')
    WITH
      (_id NVARCHAR(MAX), [name] NVARCHAR(MAX), admins NVARCHAR(MAX) AS JSON) AS ogs
    WHERE
      ogs.admins <> '[]'
  )
SELECT
  og.school_id,
  og.observation_group_id,
  og.observation_group_name,
  og.role_name,
  CASE
    WHEN og.role_name = 'observees' THEN 'teacher'
    WHEN og.role_name = 'observers' THEN 'coach'
  END AS role_category,
  m._id AS [user_id],
  m.email AS user_email,
  m.[name] AS [user_name]
FROM
  observation_groups og
  CROSS APPLY OPENJSON (og.membership)
WITH
  (_id NVARCHAR(32), email NVARCHAR(64), [name] NVARCHAR(32)) AS m
