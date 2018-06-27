CREATE OR ALTER VIEW powerschool.spenrollments_gen AS

SELECT CONVERT(INT,sp.studentid) AS studentid
      ,CONVERT(INT,sp.dcid) AS dcid
      ,sp.enter_date
      ,sp.exit_date
      ,CONVERT(INT,sp.id) AS id
      ,CONVERT(VARCHAR(5),sp.exitcode) AS exitcode
      ,CONVERT(INT,sp.programid) AS programid
      ,CONVERT(VARCHAR(125),sp.sp_comment) AS sp_comment
      ,CONVERT(INT,sp.gradelevel) AS gradelevel
      ,CASE
        WHEN DATEPART(MONTH,sp.enter_date) < 7 THEN (DATEPART(YEAR,sp.enter_date) - 1) 
        ELSE DATEPART(YEAR,sp.enter_date) 
       END AS academic_year

      ,CONVERT(VARCHAR(125),gen.name) AS specprog_name
FROM powerschool.spenrollments sp
JOIN powerschool.gen
  ON sp.programid = gen.id
 AND gen.cat_clean = 'specprog'