CREATE OR ALTER VIEW
  extracts.illuminate_enrollment AS
SELECT
  student_number AS [01 Student ID],
  state_studentnumber AS [02 Ssid],
  last_name AS [03 Last Name],
  first_name AS [04 First Name],
  NULL AS [05 Middle Name],
  dob AS [06 Birth Date],
  schoolid AS [07 Site ID],
  entrydate AS [08 Entry Date],
  exitdate AS [09 Leave Date],
  CASE
    WHEN grade_level IN (-2, -1) THEN 15
    WHEN grade_level = 99 THEN 14
    ELSE grade_level + 1
  END AS [10 Grade Level ID],
  CONCAT(
    academic_year,
    '-',
    (academic_year + 1)
  ) AS [11 Academic Year],
  1 AS [12 Is Primary Ada],
  NULL AS [13 Attendance Program ID],
  NULL AS [14 Exit Code ID],
  NULL AS [15 Session Type ID],
  NULL AS [16 Enrollment Entry Code]
FROM
  gabby.powerschool.cohort_identifiers_static
WHERE
  academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  AND grade_level != 99;
