USE gabby
GO

CREATE OR ALTER VIEW extracts.powerschool_autocomm_students_tracks AS

SELECT student_number
      ,CASE
        WHEN grade_level IN (0, 5, 9) THEN 'A'
        WHEN grade_level IN (1, 6, 10) THEN 'B'
        WHEN grade_level IN (2, 7, 11) THEN 'C'
        WHEN grade_level IN (3, 8, 12) THEN 'D'
        WHEN grade_level = 4 THEN 'E'
       END AS track
      ,db_name
FROM gabby.powerschool.students
WHERE enroll_status = 0