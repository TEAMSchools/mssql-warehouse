USE gabby GO
CREATE OR ALTER VIEW
  tableau.qa_transfer_record_audit AS
WITH
  all_enrollments AS (
    SELECT
      studentid,
      academic_year,
      schoolid,
      grade_level,
      exitcode,
      [db_name],
      LEAD(grade_level, 1) OVER (
        PARTITION BY
          studentid,
          [db_name]
        ORDER BY
          academic_year
      ) AS next_gradelevel,
      LEAD(entrydate, 1) OVER (
        PARTITION BY
          studentid,
          [db_name]
        ORDER BY
          academic_year
      ) AS next_entrydate,
      LEAD(exitdate, 1) OVER (
        PARTITION BY
          studentid,
          [db_name]
        ORDER BY
          academic_year
      ) AS next_exitdate,
      LAG(grade_level, 1) OVER (
        PARTITION BY
          studentid,
          [db_name]
        ORDER BY
          academic_year
      ) AS prev_gradelevel,
      LAG(exitcode, 1) OVER (
        PARTITION BY
          studentid,
          [db_name]
        ORDER BY
          academic_year
      ) AS prev_exitcode
    FROM
      (
        SELECT
          id AS studentid,
          schoolid,
          grade_level,
          entrydate,
          exitdate,
          exitcode,
          [db_name],
          gabby.utilities.DATE_TO_SY (entrydate) AS academic_year
        FROM
          gabby.powerschool.students
        UNION ALL
        SELECT
          studentid,
          schoolid,
          grade_level,
          entrydate,
          exitdate,
          exitcode,
          [db_name],
          gabby.utilities.DATE_TO_SY (entrydate) AS academic_year
        FROM
          gabby.powerschool.reenrollments
      ) sub
  )
SELECT
  s.student_number,
  s.lastfirst,
  s.enroll_status,
  t.academic_year,
  t.schoolid,
  t.grade_level,
  t.exitcode,
  t.next_gradelevel,
  t.next_entrydate,
  t.next_exitdate,
  t.prev_gradelevel,
  t.prev_exitcode,
  'promoted next school - no show' AS audit_type
FROM
  gabby.powerschool.students AS s
  INNER JOIN all_enrollments AS t ON s.id = t.studentid
  AND s.[db_name] = t.[db_name]
WHERE
  t.next_gradelevel != 99
  AND t.exitcode != 'G1'
  AND t.next_gradelevel > t.grade_level
  AND t.next_exitdate <= next_entrydate
  AND t.grade_level IN (4, 8)
UNION ALL
SELECT
  s.student_number,
  s.lastfirst,
  s.enroll_status,
  t.academic_year,
  t.schoolid,
  t.grade_level,
  t.exitcode,
  t.next_gradelevel,
  t.next_entrydate,
  t.next_exitdate,
  t.prev_gradelevel,
  t.prev_exitcode,
  CASE
    WHEN t.prev_exitcode = 'T2' THEN 'graduate - transferred exit code'
    WHEN t.prev_exitcode != 'G1' THEN 'transferred - graduated enrollment status'
    WHEN t.next_gradelevel IS NULL THEN 'graduated - transferred enrollment status'
    WHEN t.next_gradelevel IS NOT NULL THEN 'graduated - re-enrolled'
  END AS audit_type
FROM
  gabby.powerschool.students AS s
  INNER JOIN all_enrollments AS t ON s.id = t.studentid
  AND s.[db_name] = t.[db_name]
WHERE
  t.grade_level = 99
  AND s.enroll_status != 3
UNION ALL
SELECT
  s.student_number,
  s.lastfirst,
  s.enroll_status,
  t.academic_year,
  t.schoolid,
  t.grade_level,
  t.exitcode,
  t.next_gradelevel,
  t.next_entrydate,
  t.next_exitdate,
  t.prev_gradelevel,
  t.prev_exitcode,
  'no show - merge with previous record' AS audit_type
FROM
  gabby.powerschool.students AS s
  INNER JOIN all_enrollments AS t ON s.id = t.studentid
  AND s.[db_name] = t.[db_name]
WHERE
  t.next_entrydate = t.next_exitdate
  AND t.next_gradelevel != 99;
