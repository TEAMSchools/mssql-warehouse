USE gabby
GO

CREATE OR ALTER VIEW mcs.lunch_info AS

SELECT CONVERT(INT,s.studentnumber) AS studentnumber
      ,s.currentapplicationid

      ,CONVERT(VARCHAR(125),e.description) AS description

      ,LEFT(mbs.description, 1) AS mealbenefitstatus /* returns F/R/P */
      ,CONVERT(VARCHAR(25),mbs.description) AS shortdesc

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

SELECT CONVERT(INT,s.studentnumber) AS studentnumber
      ,s.currentapplicationid

      ,CONVERT(VARCHAR(125),e.description) AS description

      ,LEFT(mbs.description, 1) AS mealbenefitstatus /* returns F/R/P */
      ,CONVERT(VARCHAR(25),mbs.description) AS shortdesc

      ,c.reimbursableonlybalance
      ,c.unallocatedbalance
      ,c.reimbursableonlybalance + c.unallocatedbalance AS balance
FROM [winsql06\yoda].[franklin].[dbo].[student] s
LEFT JOIN [winsql06\yoda].[franklin].[dbo].[eligibility] e 
  ON s.[eligibilityid] = e.[eligibility_recid]
LEFT JOIN [winsql06\yoda].[franklin].[dbo].[meal_benefits_status] mbs
  ON e.meal_benefits_statusid = mbs.meal_benefits_status_recid
LEFT JOIN [winsql06\yoda].[newton].[dbo].[student_guid_link] g
  ON s.globaluid = g.studentguid
LEFT JOIN [winsql06\yoda].[newton].[dbo].[customer] c 
  ON g.[customerid] = c.[customer_recid]
WHERE s.inactivedate IS NULL