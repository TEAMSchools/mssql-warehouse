USE gabby
GO

CREATE OR ALTER VIEW adp.workers_custom_field_group_wide AS

SELECT associate_oid
      ,worker_id
      ,[Employee Number]
      ,[Miami - ACES Number]
      ,[NJ Pension Number]
      ,[WFMgr Accrual Profile]
      ,[WFMgr EE Type]
      ,[WFMgr Home Hyperfind]
      ,[WFMgr LOA]
      ,[WFMgr LOA Return Date]
      ,[WFMgr Pay Rule]
      ,[WFMgr Trigger]
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
  FOR code_value IN ([Employee Number]
                    ,[Miami - ACES Number]
                    ,[NJ Pension Number]
                    ,[WFMgr Accrual Profile]
                    ,[WFMgr EE Type]
                    ,[WFMgr Home Hyperfind]
                    ,[WFMgr LOA]
                    ,[WFMgr LOA Return Date]
                    ,[WFMgr Pay Rule]
                    ,[WFMgr Trigger])
 ) p
