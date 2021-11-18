USE gabby
GO

CREATE OR ALTER VIEW adp.workers_custom_field_group_wide AS

SELECT associate_oid
      ,worker_id
      ,[Attended Relay]
      ,[COVID 19 Vaccine Type]
      ,[Date of last vaccine]
      ,[Employee Number]
      ,[KIPP Alumni Status]
      ,[Life Experience in Communities We Serve]
      ,[NJ Pension Number]
      ,[Preferred Gender]
      ,[Preferred Race/Ethnicity]
      ,[Professional Experience in Communities We Serve]
      ,[Teacher Prep Program]
      ,[WFMgr Accrual Profile]
      ,[WFMgr Badge Number]
      ,[WFMgr EE Type]
      ,[WFMgr Home Hyperfind]
      ,[WFMgr LOA Return Date]
      ,[WFMgr Pay Rule]
      ,[WFMgr Trigger]
      ,CASE 
        WHEN [WFMgr LOA] = 'true' THEN 1
        WHEN [WFMgr LOA] = 'false' THEN 0
       END AS [WFMgr LOA]
FROM
    (
     SELECT associate_oid
           ,worker_id
           ,code_value
           ,string_value
     FROM gabby.adp.workers_custom_field_group
    ) sub
PIVOT(
  MAX(string_value)
  FOR code_value IN (
        [Attended Relay]
       ,[COVID 19 Vaccine Type]
       ,[Date of last vaccine]
       ,[Employee Number]
       ,[KIPP Alumni Status]
       ,[Life Experience in Communities We Serve]
       ,[NJ Pension Number]
       ,[Preferred Gender]
       ,[Preferred Race/Ethnicity]
       ,[Professional Experience in Communities We Serve]
       ,[Teacher Prep Program]
       ,[WFMgr Accrual Profile]
       ,[WFMgr Badge Number]
       ,[WFMgr EE Type]
       ,[WFMgr Home Hyperfind]
       ,[WFMgr LOA Return Date]
       ,[WFMgr LOA]
       ,[WFMgr Pay Rule]
       ,[WFMgr Trigger]
      )
 ) p
