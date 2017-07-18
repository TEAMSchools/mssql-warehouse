USE gabby
GO

ALTER VIEW mcs.lunch_info AS

SELECT c.studentnumber
      ,c.reimbursableonlybalance
      ,c.unallocatedbalance
      ,c.reimbursableonlybalance + c.unallocatedbalance AS [balance]
      ,LEFT(cat.shortdesc, 1) AS mealbenefitstatus /* returns f, r, p */
      ,cat.shortdesc
      ,e.description
      --,ROW_NUMBER() OVER(
      --   PARTITION BY c.studentnumber
      --     ORDER BY c.permanentstatusdate DESC) AS rn
FROM [winsql06\han].[newton].[dbo].[customer] c
INNER JOIN [winsql06\han].[newton].[dbo].[student_guid_link] g
  ON c.[customer_recid] = g.[customerid]
INNER JOIN [winsql06\han].[newton].[dbo].[customer_category] cat
  ON c.[customer_categoryid] = cat.[customer_category_recid]
INNER JOIN [winsql06\han].[franklin].[dbo].student s
  ON g.studentguid = s.globaluid
INNER JOIN [winsql06\han].[franklin].[dbo].[eligibility] e
  ON s.[eligibilityid] = e.[eligibility_recid]
WHERE cat.[isstudent] = 1 /* only students */
  AND ISNUMERIC(c.[studentnumber]) = 1

UNION ALL

SELECT c.studentnumber
      ,c.reimbursableonlybalance
      ,c.unallocatedbalance
      ,c.reimbursableonlybalance + c.unallocatedbalance AS balance
      ,LEFT(cat.shortdesc, 1) AS mealbenefitstatus /* returns f, r, p */
      ,cat.shortdesc
      ,e.description
      --,ROW_NUMBER() OVER(
      --   PARTITION BY C.STUDENTNUMBER
      --     ORDER BY C.PERMANENTSTATUSDATE DESC) AS RN
FROM [winsql06\yoda].[newton].[dbo].[customer] c 
INNER JOIN [winsql06\yoda].[newton].[dbo].[student_guid_link] g 
  ON c.[customer_recid] = g.[customerid]
INNER JOIN [winsql06\yoda].[newton].[dbo].[customer_category] cat 
  ON c.[customer_categoryid] = cat.[customer_category_recid]
INNER JOIN [winsql06\yoda].[franklin].[dbo].student s 
  ON g.studentguid = s.globaluid
INNER JOIN [winsql06\yoda].[franklin].[dbo].[eligibility] e 
  ON s.[eligibilityid] = e.[eligibility_recid]
WHERE cat.[isstudent] = 1 /* only students */
  AND ISNUMERIC(c.[studentnumber]) = 1