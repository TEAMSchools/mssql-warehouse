USE gabby
GO

CREATE OR ALTER VIEW mcs.lunch_info AS

SELECT CONVERT(INT,c.studentnumber) AS studentnumber
      ,c.reimbursableonlybalance
      ,c.unallocatedbalance
      ,c.reimbursableonlybalance + c.unallocatedbalance AS [balance]      

      ,LEFT(cat.shortdesc, 1) AS mealbenefitstatus /* returns f, r, p */
      ,CONVERT(VARCHAR(25),cat.shortdesc) AS shortdesc
      
      ,s.currentapplicationid

      ,CONVERT(VARCHAR(125),e.description) AS description
FROM [winsql06\han].[newton].[dbo].[customer] c
LEFT JOIN [winsql06\han].[newton].[dbo].[student_guid_link] g
  ON c.[customer_recid] = g.[customerid]
LEFT JOIN [winsql06\han].[newton].[dbo].[customer_category] cat
  ON c.[customer_categoryid] = cat.[customer_category_recid]
LEFT JOIN [winsql06\han].[franklin].[dbo].student s
  ON g.studentguid = s.globaluid
LEFT JOIN [winsql06\han].[franklin].[dbo].[eligibility] e
  ON s.[eligibilityid] = e.[eligibility_recid]
WHERE cat.[isstudent] = 1 /* only students */
  AND ISNUMERIC(c.[studentnumber]) = 1
  AND c.studentnumber IN (SELECT student_number FROM kippnewark.powerschool.students)
  AND c.inactive = 0
  
UNION ALL

SELECT CONVERT(INT,c.studentnumber) AS studentnumber
      ,c.reimbursableonlybalance
      ,c.unallocatedbalance
      ,c.reimbursableonlybalance + c.unallocatedbalance AS balance
      
      ,LEFT(cat.shortdesc, 1) AS mealbenefitstatus /* returns f, r, p */
      ,CONVERT(VARCHAR(25),cat.shortdesc) AS shortdesc
      
      ,s.currentapplicationid

      ,CONVERT(VARCHAR(125),e.description) AS description
FROM [winsql06\yoda].[newton].[dbo].[customer] c 
LEFT JOIN [winsql06\yoda].[newton].[dbo].[student_guid_link] g 
  ON c.[customer_recid] = g.[customerid]
LEFT JOIN [winsql06\yoda].[newton].[dbo].[customer_category] cat 
  ON c.[customer_categoryid] = cat.[customer_category_recid]
LEFT JOIN [winsql06\yoda].[franklin].[dbo].student s 
  ON g.studentguid = s.globaluid
LEFT JOIN [winsql06\yoda].[franklin].[dbo].[eligibility] e 
  ON s.[eligibilityid] = e.[eligibility_recid]
WHERE cat.[isstudent] = 1 /* only students */
  AND ISNUMERIC(c.[studentnumber]) = 1
  AND c.studentnumber IN (SELECT student_number FROM kippcamden.powerschool.students)
  AND c.inactive = 0