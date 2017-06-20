USE gabby
GO

ALTER VIEW powerschool.spenrollments_gen WITH SCHEMABINDING AS

SELECT sp.studentid
      ,sp.dcid
      ,sp.enter_date
      ,sp.exit_date
      ,sp.id
      ,sp.exitcode
      ,sp.programid
      ,sp.sp_comment
      ,sp.gradelevel
      ,gen.name AS specprog_name
FROM powerschool.spenrollments sp
JOIN powerschool.gen
  ON sp.programid = gen.id
 AND gen.cat = 'specprog'