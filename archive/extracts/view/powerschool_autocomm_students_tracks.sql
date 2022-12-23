CREATE OR ALTER VIEW
  extracts.powerschool_autocomm_students_tracks AS
SELECT
  s.student_number,
  CASE
    WHEN s.grade_level IN (0, 5, 9) THEN 'A'
    WHEN s.grade_level IN (1, 6, 10) THEN 'B'
    WHEN s.grade_level IN (2, 7, 11) THEN 'C'
    WHEN s.grade_level IN (3, 8, 12) THEN 'D'
    WHEN s.grade_level = 4 THEN 'E'
  END AS track,
  t.eligibility_name,
  t.total_balance,
  s.[db_name]
FROM
  gabby.powerschool.students AS s
  LEFT JOIN gabby.titan.person_data_clean AS t ON s.student_number = t.person_identifier
  AND t.application_academic_school_year_clean = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
WHERE
  s.entrydate >= DATEFROMPARTS(
    gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
    7,
    1
  )
