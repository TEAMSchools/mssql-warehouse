USE gabby
GO

--CREATE OR ALTER VIEW whetstone.observations_teacher AS

SELECT wo._id AS observation_id
      
      ,o.name AS teacher_name
      ,o.accountingId AS teacher_df_id
      ,o.email AS teacher_email
FROM gabby.whetstone.observations wo
CROSS APPLY OPENJSON(wo.teacher, '$')
  WITH (
    name NVARCHAR(25),
    accountingId NVARCHAR(25),
    email NVARCHAR(50)
   ) AS o
