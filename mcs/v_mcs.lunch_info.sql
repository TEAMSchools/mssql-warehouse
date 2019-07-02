USE gabby
GO

CREATE OR ALTER VIEW mcs.lunch_info AS

/* Newark */
SELECT CONVERT(INT,s.studentnumber) AS studentnumber
      ,s.currentapplicationid

      ,CONVERT(VARCHAR(125),e.[description]) AS [description]

      ,LEFT(mbs.[description], 1) AS mealbenefitstatus
      ,CONVERT(VARCHAR(125),mbs.[description]) AS shortdesc

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
JOIN kippnewark.powerschool.students ps
  ON s.studentnumber = ps.student_number

UNION ALL

/* Camden */
SELECT sub.studentnumber
      ,sub.currentapplicationid
      ,sub.[description]
      ,LEFT(sub.shortdesc, 1) AS mealbenefitstatus
      ,sub.shortdesc
      ,sub.reimbursableonlybalance
      ,sub.unallocatedbalance
      ,sub.balance
FROM
    (
     SELECT CONVERT(INT,s.studentnumber) AS studentnumber
           ,s.applicationid AS currentapplicationid
           ,CASE
             WHEN s.isdc = 1 THEN 'Direct Certification'
             ELSE COALESCE(s.application_approval_result_description, 'No Application')
            END AS [description]
           ,CASE
             WHEN s.isdc = 1 THEN 'Free'
             WHEN s.application_approval_result_description = 'Zero Income' THEN 'Free'
             WHEN s.application_approval_result_description LIKE 'Free%' THEN 'Free'
             WHEN s.application_approval_result_description LIKE 'Denied%' THEN 'Paying'
             ELSE COALESCE(s.application_approval_result_description, 'Paying')
            END AS shortdesc

           ,c.reimbursableonlybalance
           ,c.unallocatedbalance
           ,c.reimbursableonlybalance + c.unallocatedbalance AS balance
     FROM [winsql06\yoda].[franklin].[dbo].[view_student_data] s
     LEFT JOIN [winsql06\yoda].[newton].[dbo].[student_guid_link] g
       ON s.studentguid = g.studentguid
     LEFT JOIN [winsql06\yoda].[newton].[dbo].[customer] c 
       ON g.[customerid] = c.[customer_recid]
     JOIN kippcamden.powerschool.students ps
       ON s.studentnumber = ps.student_number
    ) sub