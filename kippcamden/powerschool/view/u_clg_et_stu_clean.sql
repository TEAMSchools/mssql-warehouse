CREATE OR ALTER VIEW
  powerschool.u_clg_et_stu_clean AS
SELECT
  id,
  studentsdcid,
  exit_date,
  exit_code
FROM
  (
    SELECT
      CAST(id AS INT) AS id,
      CAST(studentsdcid AS INT) AS studentsdcid,
      exit_date,
      CAST(exit_code AS VARCHAR(5)) AS exit_code,
      ROW_NUMBER() OVER (
        PARTITION BY
          studentsdcid,
          exit_date
        ORDER BY
          id DESC
      ) AS rn
    FROM
      powerschool.u_clg_et_stu
  ) AS sub
WHERE
  rn = 1
