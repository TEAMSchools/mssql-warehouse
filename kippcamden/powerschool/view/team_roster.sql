CREATE OR ALTER VIEW
  powerschool.team_roster AS
SELECT
  studentid,
  student_number,
  academic_year,
  schoolid,
  team
FROM
  (
    SELECT
      studentid,
      student_number,
      academic_year,
      schoolid,
      (
        CASE
          WHEN (
            gabby.utilities.STRIP_CHARACTERS (section_number, '0-9') = ''
          ) THEN teacher_name
          ELSE gabby.utilities.STRIP_CHARACTERS (section_number, '0-9')
        END
        COLLATE LATIN1_GENERAL_BIN
      ) AS team,
      ROW_NUMBER() OVER (
        PARTITION BY
          student_number,
          academic_year,
          schoolid
        ORDER BY
          section_enroll_status ASC,
          dateleft DESC,
          dateenrolled DESC
      ) AS rn_year
    FROM
      powerschool.course_enrollments
    WHERE
      course_number = 'HR'
  ) AS sub
WHERE
  rn_year = 1
