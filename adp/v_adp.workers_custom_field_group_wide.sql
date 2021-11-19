USE gabby
GO

CREATE OR ALTER VIEW adp.workers_custom_field_group_wide AS (

WITH multi_pivot AS (
SELECT worker_id
      ,[Life Experience in Communities We Serve]
      ,[Preferred Race/Ethnicity]
      ,[Professional Experience in Communities We Serve]
      ,[Teacher Prep Program]

FROM (
  
  SELECT worker_id
        ,code_value
        ,gabby.dbo.GROUP_CONCAT(string_value) AS string_value
  FROM gabby.adp.workers_custom_field_group
  WHERE code_value IN ('Preferred Race/Ethnicity', 'Life Experience in Communities We Serve', 'Professional Experience in Communities We Serve', 'Teacher Prep Program')
  GROUP BY worker_id, code_value
       ) sub
  PIVOT(MAX(string_value) FOR code_value IN ([Life Experience in Communities We Serve]
                                            ,[Preferred Race/Ethnicity]
                                            ,[Professional Experience in Communities We Serve]
                                            ,[Teacher Prep Program]
                                            )
      ) p
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
      ,p.[WFMgr LOA]
      ,p.[WFMgr Pay Rule]
      ,p.[WFMgr Trigger]
      ,p.[Years Teaching - In NJ or FL]
      ,p.[Years of Professional Experience before joining]
      ,p.[Years Teaching - In any State]
      ,CASE 
        WHEN p.[WFMgr LOA] = 'true' THEN 1
        WHEN p.[WFMgr LOA] = 'false' THEN 0
       END AS [WFMgr LOA]

      ,m.[Life Experience in Communities We Serve]
      ,m.[Preferred Race/Ethnicity]
      ,m.[Professional Experience in Communities We Serve]
      ,m.[Teacher Prep Program]

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
      )
 ) p

 LEFT JOIN multi_pivot m
   ON p.worker_id = m.worker_id