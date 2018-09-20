USE gabby
GO

--CREATE OR ALTER VIEW whetstone.observations_observer AS

SELECT wo._id AS observation_id
      
      ,o.name AS observed_by_name
      ,o.accountingId AS observed_by_df_id
      ,o.email AS observed_by_email
FROM gabby.whetstone.observations wo
CROSS APPLY OPENJSON(wo.observer, '$')
  WITH (
    name NVARCHAR(25),
    accountingId NVARCHAR(25),
    email NVARCHAR(50)
   ) AS o
