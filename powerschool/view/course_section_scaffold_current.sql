CREATE OR ALTER VIEW
  powerschool.course_section_scaffold_current AS
SELECT
  studentid,
  student_number,
  yearid,
  term_name,
  is_curterm,
  course_number,
  course_name,
  credittype,
  credit_hours,
  COALESCE(
    gradescaleid,
    LAG(gradescaleid, 1) OVER (
      PARTITION BY
        studentid,
        yearid,
        course_number
      ORDER BY
        term_name
    ),
    LAG(gradescaleid, 2) OVER (
      PARTITION BY
        studentid,
        yearid,
        course_number
      ORDER BY
        term_name
    ),
    LAG(gradescaleid, 3) OVER (
      PARTITION BY
        studentid,
        yearid,
        course_number
      ORDER BY
        term_name
    )
  ) AS gradescaleid,
  excludefromgpa,
  COALESCE(
    abs_sectionid,
    LAG(abs_sectionid, 1) OVER (
      PARTITION BY
        studentid,
        yearid,
        course_number
      ORDER BY
        term_name
    ),
    LAG(abs_sectionid, 2) OVER (
      PARTITION BY
        studentid,
        yearid,
        course_number
      ORDER BY
        term_name
    ),
    LAG(abs_sectionid, 3) OVER (
      PARTITION BY
        studentid,
        yearid,
        course_number
      ORDER BY
        term_name
    )
  ) AS sectionid
FROM
  (
    SELECT
      cs.studentid,
      cs.student_number,
      cs.yearid,
      cs.term_name,
      cs.course_number,
      cs.course_name,
      cs.credittype,
      cs.credit_hours,
      cs.excludefromgpa,
      cs.gradescaleid,
      cs.is_curterm,
      ss.abs_sectionid
    FROM
      powerschool.course_scaffold_current_static AS cs
      LEFT JOIN powerschool.section_scaffold_current_static AS ss ON (
        cs.studentid = ss.studentid
        AND cs.yearid = ss.yearid
        AND cs.term_name = ss.term_name
        AND cs.course_number = ss.course_number
        AND ss.rn_term = 1
      )
  ) AS sub
