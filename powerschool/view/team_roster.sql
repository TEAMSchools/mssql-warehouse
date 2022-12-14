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
      enr.studentid,
      enr.student_number,
      enr.academic_year,
      enr.schoolid,
      CASE
        WHEN gabby.utilities.STRIP_CHARACTERS (enr.section_number, '0-9') = '' THEN enr.teacher_name
        ELSE gabby.utilities.STRIP_CHARACTERS (enr.section_number, '0-9')
      END
    COLLATE Latin1_General_BIN AS team,
    ROW_NUMBER() OVER (
      PARTITION BY
        enr.student_number,
        enr.academic_year,
        enr.schoolid
      ORDER BY
        enr.section_enroll_status ASC,
        enr.dateleft DESC,
        enr.dateenrolled DESC
    ) AS rn_year
    FROM
      powerschool.course_enrollments enr
    WHERE
      enr.course_number = 'HR'
  ) sub
WHERE
  rn_year = 1
