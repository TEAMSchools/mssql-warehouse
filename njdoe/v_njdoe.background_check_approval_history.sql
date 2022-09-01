USE gabby
GO

CREATE OR ALTER VIEW njdoe.background_check_approval_history AS

SELECT bg.employee_number

      ,ah.approvaldate
      ,ah.countycode
      ,ah.districtcode
      ,ah.schoolcode
      ,CASE WHEN ah.contractorcode = '' THEN NULL ELSE ah.contractorcode END AS contractorcode
      ,ah.jobposition
      ,CAST(CONVERT(FLOAT, CASE WHEN ah.pcn <> '' THEN ah.pcn END) AS BIGINT) AS pcn
      ,CASE WHEN ah.transferind = '' THEN NULL ELSE ah.transferind END AS transferind

      ,s.primary_job
      ,s.legal_entity_name
      ,s.primary_site
      ,s.original_hire_date
      ,s.[status]
      ,s.preferred_name
      ,s.userprincipalname
FROM gabby.njdoe.background_check bg
LEFT JOIN gabby.people.staff_crosswalk_static s
  ON bg.df_employee_number = s.df_employee_number
CROSS APPLY OPENJSON(bg.approval_history, '$')
  WITH (
    approvaldate DATE,
    countycode NVARCHAR(256),
    districtcode NVARCHAR(256),
    schoolcode NVARCHAR(256),
    contractorcode NVARCHAR(256),
    jobposition NVARCHAR(256),
    pcn NVARCHAR(256),
    transferind DATE
   ) AS ah
WHERE bg.approval_history <> '[]'
