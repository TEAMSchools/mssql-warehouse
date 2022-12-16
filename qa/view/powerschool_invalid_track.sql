USE gabby GO
CREATE OR ALTER VIEW
  qa.powerschool_invalid_track AS
SELECT
  co.[db_name],
  co.student_number,
  co.yearid,
  co.schoolid,
  co.track,
  co.entrydate,
  co.exitdate
FROM
  gabby.powerschool.cohort_static AS co
  LEFT JOIN gabby.powerschool.calendar_rollup_static AS c ON co.yearid = c.yearid
  AND co.schoolid = c.schoolid
  AND co.track = c.track
  AND co.[db_name] = c.[db_name]
WHERE
  co.grade_level != 99
  AND c.schoolid IS NULL
