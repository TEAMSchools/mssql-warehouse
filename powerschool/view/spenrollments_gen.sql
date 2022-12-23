CREATE OR ALTER VIEW
  powerschool.spenrollments_gen AS
SELECT
  studentid,
  dcid,
  enter_date,
  exit_date,
  id,
  exitcode,
  programid,
  sp_comment,
  gradelevel,
  academic_year,
  specprog_name
FROM
  (
    SELECT
      CAST(sp.studentid AS INT) AS studentid,
      CAST(sp.dcid AS INT) AS dcid,
      sp.enter_date,
      sp.exit_date,
      CAST(sp.id AS INT) AS id,
      CAST(sp.exitcode AS VARCHAR(5)) AS exitcode,
      CAST(sp.programid AS INT) AS programid,
      CAST(sp.sp_comment AS VARCHAR(125)) AS sp_comment,
      CAST(sp.gradelevel AS INT) AS gradelevel,
      gabby.utilities.DATE_TO_SY (sp.enter_date) AS academic_year,
      gen.[name] AS specprog_name,
      ROW_NUMBER() OVER (
        PARTITION BY
          sp.studentid,
          sp.programid,
          gabby.utilities.DATE_TO_SY (sp.enter_date)
        ORDER BY
          sp.enter_date DESC
      ) AS rn
    FROM
      powerschool.spenrollments AS sp
      INNER JOIN powerschool.gen ON (
        sp.programid = gen.id
        AND gen.cat = 'specprog'
      )
  ) AS sub
WHERE
  rn = 1
