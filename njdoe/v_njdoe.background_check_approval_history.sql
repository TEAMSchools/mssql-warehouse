USE gabby
GO

CREATE OR ALTER VIEW njdoe.background_check_approval_history AS

SELECT bg.df_employee_number
      ,bg.approval_history
      
      ,CONVERT(DATETIME2,ah.approvaldate) AS approvaldate
      ,ah.countycode
      ,ah.districtcode
      ,ah.schoolcode
      ,CASE WHEN ah.contractorcode = '' THEN NULL ELSE ah.contractorcode END AS contractorcode
      ,ah.jobposition
      ,ah.pcn
      ,CONVERT(DATETIME2,CASE WHEN ah.transferind = '' THEN NULL ELSE ah.transferind END) AS transferind
FROM gabby.njdoe.background_check bg
CROSS APPLY OPENJSON(bg.approval_history, '$')
  WITH (
    approvaldate VARCHAR(25),
    countycode VARCHAR(5),
    districtcode VARCHAR(5),
    schoolcode VARCHAR(5),
    contractorcode VARCHAR(5),
    jobposition VARCHAR(125),
    pcn VARCHAR(25),
    transferind VARCHAR(25)
   ) AS ah