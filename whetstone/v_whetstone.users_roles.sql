USE gabby
GO

CREATE OR ALTER VIEW whetstone.users_roles AS

SELECT u._id AS [user_id]

      ,r._id AS role_id
      ,r.[name] AS role_name
FROM gabby.whetstone.users u
CROSS APPLY OPENJSON(u.roles, '$')
  WITH(
    _id NVARCHAR(32),
    [name] NVARCHAR(32)
  ) AS r
