CREATE OR ALTER VIEW
  mcs.lunch_info AS
SELECT
  sub.studentnumber,
  sub.currentapplicationid,
  sub.[description],
  LEFT(sub.shortdesc, 1) AS mealbenefitstatus,
  sub.shortdesc,
  sub.reimbursableonlybalance,
  sub.unallocatedbalance,
  sub.balance
FROM
  (
    SELECT
      CAST(s.studentnumber AS INT) AS studentnumber,
      s.applicationid AS currentapplicationid,
      CASE
        WHEN s.isdc = 1 THEN 'Direct Certification'
        ELSE COALESCE(
          s.application_approval_result_description,
          'No Application'
        )
      END AS [description],
      CASE
        WHEN s.isdc = 1 THEN 'Free'
        WHEN s.application_approval_result_description = 'Zero Income' THEN 'Free'
        WHEN s.application_approval_result_description LIKE 'Free%' THEN 'Free'
        WHEN s.application_approval_result_description LIKE 'Denied%' THEN 'Paying'
        ELSE COALESCE(
          s.application_approval_result_description,
          'Paying'
        )
      END AS shortdesc,
      c.reimbursableonlybalance,
      c.unallocatedbalance,
      c.reimbursableonlybalance + c.unallocatedbalance AS balance
    FROM
      [winsql06\han].[franklin].[dbo].[view_student_data] s
      LEFT JOIN [winsql06\han].[newton].[dbo].[student_guid_link] g ON s.studentguid = g.studentguid
      LEFT JOIN [winsql06\han].[newton].[dbo].[customer] c ON g.[customerid] = c.[customer_recid]
      INNER JOIN kippnewark.powerschool.students AS ps ON s.studentnumber = ps.student_number
    UNION ALL
    SELECT
      CAST(s.studentnumber AS INT) AS studentnumber,
      s.applicationid AS currentapplicationid,
      CASE
        WHEN s.isdc = 1 THEN 'Direct Certification'
        ELSE COALESCE(
          s.application_approval_result_description,
          'No Application'
        )
      END AS [description],
      CASE
        WHEN s.isdc = 1 THEN 'Free'
        WHEN s.application_approval_result_description = 'Zero Income' THEN 'Free'
        WHEN s.application_approval_result_description LIKE 'Free%' THEN 'Free'
        WHEN s.application_approval_result_description LIKE 'Denied%' THEN 'Paying'
        ELSE COALESCE(
          s.application_approval_result_description,
          'Paying'
        )
      END AS shortdesc,
      c.reimbursableonlybalance,
      c.unallocatedbalance,
      c.reimbursableonlybalance + c.unallocatedbalance AS balance
    FROM
      [winsql06\yoda].[franklin].[dbo].[view_student_data] s
      LEFT JOIN [winsql06\yoda].[newton].[dbo].[student_guid_link] g ON s.studentguid = g.studentguid
      LEFT JOIN [winsql06\yoda].[newton].[dbo].[customer] c ON g.[customerid] = c.[customer_recid]
      INNER JOIN kippcamden.powerschool.students AS ps ON s.studentnumber = ps.student_number
  ) AS sub
