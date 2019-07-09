CREATE OR ALTER VIEW powerschool.u_clg_et_stu_clean AS

SELECT sub.id
      ,sub.studentsdcid
      ,sub.exit_date
      ,sub.exit_code
FROM
    (
     SELECT CONVERT(INT, id) AS id
           ,CONVERT(INT, studentsdcid) AS studentsdcid
           ,exit_date
           ,CONVERT(VARCHAR(5), exit_code) AS exit_code
           ,ROW_NUMBER() OVER(
              PARTITION BY studentsdcid, exit_date
                ORDER BY id DESC) AS rn
     FROM powerschool.u_clg_et_stu
    ) sub
WHERE rn = 1