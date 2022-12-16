CREATE OR ALTER VIEW
  qa.powerschool_transfer_record_overlap AS
SELECT
  [db_name],
  student_number,
  studentid,
  academic_year,
  schoolid,
  grade_level,
  entrydate,
  exitdate,
  exitdate_prev
FROM
  (
    SELECT
      pea.[db_name],
      pea.studentid,
      pea.yearid + 1990 AS academic_year,
      pea.schoolid,
      pea.grade_level,
      pea.entrydate,
      pea.exitdate,
      LAG(pea.exitdate) OVER (
        PARTITION BY
          pea.[db_name],
          pea.studentid,
          pea.yearid
        ORDER BY
          pea.exitdate
      ) AS exitdate_prev,
      s.student_number
    FROM
      gabby.powerschool.ps_enrollment_all AS pea
      INNER JOIN gabby.powerschool.students AS s ON pea.studentid = s.id
      AND pea.[db_name] = s.[db_name]
      INNER JOIN gabby.powerschool.schools AS sch ON pea.schoolid = sch.school_number
      AND pea.[db_name] = sch.[db_name]
      AND sch.state_excludefromreporting = 0 /* exclude grads & ss */
  ) AS sub
WHERE
  entrydate <= exitdate_prev
