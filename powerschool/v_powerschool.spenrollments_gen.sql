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
      ,CASE 
        WHEN DATEPART(MONTH,sp.enter_date) < 7 THEN (DATEPART(YEAR,sp.enter_date) - 1) 
        ELSE DATEPART(YEAR,sp.enter_date) 
       END AS academic_year

      ,gen.name AS specprog_name
FROM powerschool.spenrollments sp
JOIN powerschool.gen
  ON sp.programid = gen.id
 AND gen.cat = 'specprog'