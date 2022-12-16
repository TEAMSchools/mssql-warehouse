 SELECT
  ga.[db_name],
  MIN(ga.assignmentcategoryassocid) AS min_assignmentcategoryassocid,
  MAX(ga.assignmentcategoryassocid) + 1 AS next_min_assignmentcategoryassocid,
  rt.alt_name,
  rt.[start_date],
  rt.end_date
FROM
  (
    SELECT
      asec.assignmentsectionid,
      asec.duedate,
      asec.[db_name],
      aca.assignmentcategoryassocid
    FROM
      powerschool.assignmentsection AS asec
      LEFT JOIN powerschool.assignmentcategoryassoc AS aca ON asec.assignmentsectionid = aca.assignmentsectionid
      AND asec.[db_name] = aca.[db_name]
    WHERE
      asec.duedate >= DATEFROMPARTS(
        gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
        7,
        1
      )
  ) ga
  INNER JOIN gabby.reporting.reporting_terms AS rt ON (
    ga.duedate BETWEEN rt.[start_date] AND rt.end_date
  )
  AND rt.identifier = 'RT'
  AND rt.schoolid = 0
GROUP BY
  ga.[db_name],
  rt.alt_name,
  rt.[start_date],
  rt.end_date
ORDER BY
  ga.[db_name],
  rt.alt_name
