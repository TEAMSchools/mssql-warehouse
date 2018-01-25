USE gabby
GO

CREATE OR ALTER VIEW mcs.lunch_info AS

SELECT CONVERT(INT,c.studentnumber) AS studentnumber
      ,c.reimbursableonlybalance
      ,c.unallocatedbalance
      ,c.reimbursableonlybalance + c.unallocatedbalance AS [balance]      

      ,LEFT(cat.shortdesc, 1) AS mealbenefitstatus /* returns f, r, p */
      ,cat.shortdesc
      
      ,s.currentapplicationid

      ,e.description
FROM [winsql06\han].[newton].[dbo].[customer] c
LEFT OUTER JOIN [winsql06\han].[newton].[dbo].[student_guid_link] g
  ON c.[customer_recid] = g.[customerid]
LEFT OUTER JOIN [winsql06\han].[newton].[dbo].[customer_category] cat
  ON c.[customer_categoryid] = cat.[customer_category_recid]
LEFT OUTER JOIN [winsql06\han].[franklin].[dbo].student s
  ON g.studentguid = s.globaluid
LEFT OUTER JOIN [winsql06\han].[franklin].[dbo].[eligibility] e
  ON s.[eligibilityid] = e.[eligibility_recid]
WHERE cat.[isstudent] = 1 /* only students */
  AND ISNUMERIC(c.[studentnumber]) = 1
  AND c.studentnumber IN (SELECT student_number FROM gabby.powerschool.students WHERE schoolid NOT LIKE '1799%')
  AND c.inactive = 0
  
UNION ALL

SELECT CONVERT(INT,c.studentnumber) AS studentnumber
      ,c.reimbursableonlybalance
      ,c.unallocatedbalance
      ,c.reimbursableonlybalance + c.unallocatedbalance AS balance
      
      ,LEFT(cat.shortdesc, 1) AS mealbenefitstatus /* returns f, r, p */
      ,cat.shortdesc
      
      ,s.currentapplicationid

      ,e.description
FROM [winsql06\yoda].[newton].[dbo].[customer] c 
LEFT OUTER JOIN [winsql06\yoda].[newton].[dbo].[student_guid_link] g 
  ON c.[customer_recid] = g.[customerid]
LEFT OUTER JOIN [winsql06\yoda].[newton].[dbo].[customer_category] cat 
  ON c.[customer_categoryid] = cat.[customer_category_recid]
LEFT OUTER JOIN [winsql06\yoda].[franklin].[dbo].student s 
  ON g.studentguid = s.globaluid
LEFT OUTER JOIN [winsql06\yoda].[franklin].[dbo].[eligibility] e 
  ON s.[eligibilityid] = e.[eligibility_recid]
WHERE cat.[isstudent] = 1 /* only students */
  AND ISNUMERIC(c.[studentnumber]) = 1
  AND c.studentnumber IN (SELECT student_number FROM gabby.powerschool.students WHERE schoolid LIKE '1799%')
  AND c.inactive = 0