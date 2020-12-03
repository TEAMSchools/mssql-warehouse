CREATE OR ALTER VIEW powerschool.spenrollments_gen AS

SELECT sub.studentid
      ,sub.dcid
      ,sub.enter_date
      ,sub.exit_date
      ,sub.id
      ,sub.exitcode
      ,sub.programid
      ,sub.sp_comment
      ,sub.gradelevel
      ,sub.academic_year
      ,sub.specprog_name
FROM
    (
     SELECT CONVERT(INT, sp.studentid) AS studentid
           ,CONVERT(INT, sp.dcid) AS dcid
           ,sp.enter_date
           ,sp.exit_date
           ,CONVERT(INT, sp.id) AS id
           ,CONVERT(VARCHAR(5), sp.exitcode) AS exitcode
           ,CONVERT(INT, sp.programid) AS programid
           ,CONVERT(VARCHAR(125), sp.sp_comment) AS sp_comment
           ,CONVERT(INT, sp.gradelevel) AS gradelevel
           ,gabby.utilities.DATE_TO_SY(sp.enter_date) AS academic_year

           ,gen.[name] AS specprog_name

           ,ROW_NUMBER() OVER(
              PARTITION BY sp.studentid, sp.programid, gabby.utilities.DATE_TO_SY(sp.enter_date)
                ORDER BY sp.enter_date DESC) AS rn
     FROM powerschool.spenrollments sp
     JOIN powerschool.gen
       ON sp.programid = gen.id
      AND gen.cat = 'specprog'
    ) sub
WHERE rn = 1
