CREATE OR ALTER VIEW
  whetstone.schools_observation_groups_membership AS
WITH
  observation_groups AS (
    SELECT
      s._id AS school_id,
      CAST(
        JSON_VALUE(ogs.[value], '$._id') AS NVARCHAR(32)
      ) AS observation_group_id,
      CAST(
        JSON_VALUE(ogs.[value], '$.name') AS NVARCHAR(16)
      ) AS observation_group_name,
      JSON_QUERY(ogs.[value], '$.observers') AS observers,
      JSON_QUERY(ogs.[value], '$.observees') AS observees,
      JSON_QUERY(ogs.[value], '$.admins') AS admins
    FROM
      gabby.whetstone.schools AS s
      CROSS APPLY OPENJSON (s.observation_groups, '$') AS ogs
  ),
  ogs_unpivot AS (
    SELECT
      school_id,
      observation_group_id,
      observation_group_name,
      membership,
      role_name
    FROM
      observation_groups UNPIVOT (
        membership FOR role_name IN (observers, observees, admins)
      ) AS u
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
  CAST(
    JSON_VALUE(m.[value], '$._id') AS NVARCHAR(32)
  ) AS [user_id],
  CAST(
    JSON_VALUE(m.[value], '$.email') AS NVARCHAR(64)
  ) AS user_email,
  CAST(
    JSON_VALUE(m.[value], '$.name') AS NVARCHAR(32)
  ) AS [user_name]
FROM
  ogs_unpivot AS og
  CROSS APPLY OPENJSON (og.membership) AS m
