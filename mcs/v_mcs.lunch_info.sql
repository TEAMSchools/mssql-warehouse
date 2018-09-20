USE gabby
GO

CREATE OR ALTER VIEW mcs.lunch_info AS

SELECT CONVERT(INT,s.studentnumber) AS studentnumber
      ,s.currentapplicationid

      ,CONVERT(VARCHAR(125),e.description) AS description

      ,LEFT(mbs.description, 1) AS mealbenefitstatus /* returns F/R/P */
      ,CONVERT(VARCHAR(125),mbs.description) AS shortdesc

      ,c.reimbursableonlybalance
      ,c.unallocatedbalance
      ,c.reimbursableonlybalance + c.unallocatedbalance AS balance
FROM [winsql06\han].[franklin].[dbo].[student] s
LEFT JOIN [winsql06\han].[franklin].[dbo].[eligibility] e 
  ON s.[eligibilityid] = e.[eligibility_recid]
LEFT JOIN [winsql06\han].[franklin].[dbo].[meal_benefits_status] mbs
  ON e.meal_benefits_statusid = mbs.meal_benefits_status_recid
LEFT JOIN [winsql06\han].[newton].[dbo].[student_guid_link] g
  ON s.globaluid = g.studentguid
LEFT JOIN [winsql06\han].[newton].[dbo].[customer] c 
  ON g.[customerid] = c.[customer_recid]
WHERE s.inactivedate IS NULL

UNION ALL

SELECT CONVERT(INT,s.StudentNumber) AS studentnumber
      ,s.ApplicationID AS currentapplicationid      
      ,CASE
        WHEN s.IsDC = 1 THEN 'Direct Certification'
        ELSE COALESCE(s.Application_Approval_Result_Description, 'No Application')
       END AS description      
      ,LEFT(CASE
             WHEN s.IsDC = 1 THEN 'Free'
             WHEN s.Application_Approval_Result_Description = 'Zero Income' THEN 'Free'
             WHEN s.Application_Approval_Result_Description LIKE 'Free%' THEN 'Free'
             WHEN s.Application_Approval_Result_Description LIKE 'Denied%' THEN 'Paying'
             ELSE COALESCE(s.Application_Approval_Result_Description, 'Paying')
            END, 1) AS mealbenefitstatus
      ,CASE        
        WHEN s.IsDC = 1 THEN 'Free'
        WHEN s.Application_Approval_Result_Description = 'Zero Income' THEN 'Free'
        WHEN s.Application_Approval_Result_Description LIKE 'Free%' THEN 'Free'
        WHEN s.Application_Approval_Result_Description LIKE 'Denied%' THEN 'Paying'
        ELSE COALESCE(s.Application_Approval_Result_Description, 'Paying')
       END AS shortdesc      

      ,c.reimbursableonlybalance
      ,c.unallocatedbalance
      ,c.reimbursableonlybalance + c.unallocatedbalance AS balance
FROM [WINSQL06\YODA].[Franklin].[dbo].[VIEW_STUDENT_DATA] s
LEFT JOIN [WINSQL06\YODA].[newton].[dbo].[student_guid_link] g
  ON s.StudentGuid = g.studentguid
LEFT JOIN [WINSQL06\YODA].[newton].[dbo].[customer] c 
  ON g.[customerid] = c.[customer_recid]
WHERE s.Inactive = 0