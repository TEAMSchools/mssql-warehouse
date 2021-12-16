USE gabby
GO

CREATE OR ALTER VIEW adp.workers_custom_field_group_wide AS

WITH grouped_data AS (
  SELECT associate_oid
        ,worker_id
        ,name_code_value
        ,gabby.dbo.GROUP_CONCAT(item_value) AS item_value
  FROM gabby.adp.workers_custom_field_group
  GROUP BY associate_oid, worker_id, name_code_value
 )

SELECT p.associate_oid
      ,p.worker_id
      ,p.[Attended Relay]
      ,p.[COVID 19 Vaccine Type]
      ,p.[Date of last vaccine]
      ,p.[Employee Number]
      ,p.[KIPP Alumni Status]
      ,p.[NJ Pension Number]
      ,p.[Preferred Gender]
      ,p.[WFMgr Accrual Profile]
      ,p.[WFMgr Badge Number]
      ,p.[WFMgr EE Type]
      ,p.[WFMgr Home Hyperfind]
      ,p.[WFMgr LOA Return Date]
      ,p.[WFMgr Pay Rule]
      ,p.[WFMgr Trigger]
      ,p.[Years Teaching - In NJ or FL]
      ,p.[Years of Professional Experience before joining]
      ,p.[Years Teaching - In any State]
      ,p.[Life Experience in Communities We Serve]
      ,p.[Preferred Race/Ethnicity]
      ,p.[Professional Experience in Communities We Serve]
      ,p.[Teacher Prep Program]
      ,CASE
        WHEN p.[WFMgr LOA] = 'true' THEN 1
        WHEN p.[WFMgr LOA] = 'false' THEN 0
       END AS [WFMgr LOA]
FROM grouped_data
PIVOT(
  MAX(item_value)
  FOR name_code_value IN (
        [Attended Relay]
       ,[COVID 19 Vaccine Type]
       ,[Date of last vaccine]
       ,[Employee Number]
       ,[KIPP Alumni Status]
       ,[NJ Pension Number]
       ,[Preferred Gender]
       ,[WFMgr Accrual Profile]
       ,[WFMgr Badge Number]
       ,[WFMgr EE Type]
       ,[WFMgr Home Hyperfind]
       ,[WFMgr LOA Return Date]
       ,[WFMgr LOA]
       ,[WFMgr Pay Rule]
       ,[WFMgr Trigger]
       ,[Years Teaching - In NJ or FL]
       ,[Years of Professional Experience before joining]
       ,[Years Teaching - In any State]
       ,[Life Experience in Communities We Serve]
       ,[Preferred Race/Ethnicity]
       ,[Professional Experience in Communities We Serve]
       ,[Teacher Prep Program]
      )
 ) p
