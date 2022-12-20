CREATE OR ALTER VIEW
  powerschool.course_scaffold_current AS
SELECT
  studentid,
  student_number,
  yearid,
  term_name,
  course_number,
  course_name,
  credittype,
  credit_hours,
  excludefromgpa,
  gradescaleid,
  is_curterm
FROM
  (
    SELECT DISTINCT
      enr.studentid,
      enr.student_number,
      enr.yearid,
      enr.course_number,
      enr.course_name,
      enr.credittype,
      enr.credit_hours,
      enr.excludefromgpa,
      enr.gradescaleid,
      (
        CAST(terms.alt_name AS VARCHAR(25))
        COLLATE LATIN1_GENERAL_BIN
      ) AS term_name,
      terms.[start_date] AS term_start_date,
      terms.end_date AS term_end_date,
      terms.is_curterm
    FROM
      powerschool.course_enrollments_current_static AS enr
      INNER JOIN powerschool.schools ON enr.schoolid = schools.school_number
      INNER JOIN gabby.reporting.reporting_terms AS terms ON enr.yearid = terms.yearid
      AND enr.schoolid = terms.schoolid
      AND terms.identifier = 'RT'
      AND terms.alt_name NOT IN (
        'Summer School',
        'Capstone',
        'EOY'
      )
      AND terms._fivetran_deleted = 0
    WHERE
      enr.section_enroll_status = 0
      AND enr.course_enroll_status = 0
      AND enr.dateenrolled <= CAST(CURRENT_TIMESTAMP AS DATE)
  ) AS sub
