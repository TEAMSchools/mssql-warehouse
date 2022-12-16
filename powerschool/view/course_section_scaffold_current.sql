CREATE OR ALTER VIEW
  powerschool.course_section_scaffold_current AS
SELECT
  sub.studentid,
  sub.student_number,
  sub.yearid,
  sub.term_name,
  sub.is_curterm,
  sub.course_number,
  sub.course_name,
  sub.credittype,
  sub.credit_hours,
  COALESCE(
    sub.gradescaleid,
    LAG(sub.gradescaleid, 1) OVER (
      PARTITION BY
        sub.studentid,
        sub.yearid,
        sub.course_number
      ORDER BY
        sub.term_name
    ),
    LAG(sub.gradescaleid, 2) OVER (
      PARTITION BY
        sub.studentid,
        sub.yearid,
        sub.course_number
      ORDER BY
        sub.term_name
    ),
    LAG(sub.gradescaleid, 3) OVER (
      PARTITION BY
        sub.studentid,
        sub.yearid,
        sub.course_number
      ORDER BY
        sub.term_name
    )
  ) AS gradescaleid,
  sub.excludefromgpa,
  COALESCE(
    sub.abs_sectionid,
    LAG(sub.abs_sectionid, 1) OVER (
      PARTITION BY
        sub.studentid,
        sub.yearid,
        sub.course_number
      ORDER BY
        sub.term_name
    ),
    LAG(sub.abs_sectionid, 2) OVER (
      PARTITION BY
        sub.studentid,
        sub.yearid,
        sub.course_number
      ORDER BY
        sub.term_name
    ),
    LAG(sub.abs_sectionid, 3) OVER (
      PARTITION BY
        sub.studentid,
        sub.yearid,
        sub.course_number
      ORDER BY
        sub.term_name
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
      LEFT JOIN powerschool.section_scaffold_current_static AS ss ON cs.studentid = ss.studentid
      AND cs.yearid = ss.yearid
      AND cs.term_name = ss.term_name
      AND cs.course_number = ss.course_number
      AND ss.rn_term = 1
  ) AS sub
