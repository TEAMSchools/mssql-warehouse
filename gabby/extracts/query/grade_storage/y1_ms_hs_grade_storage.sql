SELECT
  ce.student_number,
  s.grade_level,
  s.schoolid,
  CASE
    WHEN g.[name] = 'KIPP NJ 2019 (5-12) Weighted'
    AND fg.y1_grade_percent_adj = 59 THEN 1.67
    WHEN g.[name] = 'KIPP NJ 2019 (5-12) Unweighted'
    AND fg.y1_grade_percent_adj = 59 THEN 0.67
    WHEN g.[name] = 'Florida - 6-12'
    AND fg.y1_grade_percent_adj = 59 THEN 1.00
    ELSE fg.y1_grade_pts
  END AS gpa_points,
  CASE
    WHEN fg.y1_grade_percent_adj > 100 THEN 100
    WHEN fg.y1_grade_percent_adj = 59 THEN 60
    ELSE fg.y1_grade_percent_adj
  END AS [percent],
  CASE
    WHEN g.[name] = 'Florida - 6-12'
    AND fg.y1_grade_percent_adj = 59 THEN 'D'
    WHEN g.[name] IN (
      'KIPP NJ 2019 (5-12) Unweighted',
      'KIPP NJ 2019 (5-12) Weighted'
    )
    AND fg.y1_grade_percent_adj = 59 THEN 'D-'
    ELSE fg.y1_grade_letter
  END AS grade,
  'Y1' AS storecode,
  ce.credittype AS credit_type,
  ce.course_number,
  ce.course_name,
  ce.teacher_name,
  ce.sectionid,
  ce.credit_hours AS [PotentialCrHrs],
  CASE
    WHEN fg.y1_grade_percent_adj >= 59 THEN ce.credit_hours
    ELSE 0
  END AS [EarnedCrHrs],
  g.[name] AS gradescale_name,
  sch.[name] AS schoolname,
  sec.termid
FROM
  powerschool.final_grades_static AS fg
  INNER JOIN powerschool.gradescaleitem AS g ON fg.gradescaleid = g.id
  AND fg.db_name = g.db_name
  INNER JOIN powerschool.course_enrollments AS ce ON fg.studentid = ce.studentid
  AND fg.db_name = ce.db_name
  AND fg.sectionid = ce.sectionid
  INNER JOIN powerschool.schools AS sch ON ce.schoolid = sch.school_number
  INNER JOIN powerschool.sections AS sec ON fg.sectionid = sec.id
  AND fg.db_name = sec.db_name
  INNER JOIN powerschool.students AS s ON s.id = fg.studentid
  AND s.[db_name] = fg.[db_name]
WHERE
  fg.storecode = 'Q4'
  AND ce.section_enroll_status = 0
  AND ce.rn_course_yr != 0
  AND fg.y1_grade_letter IS NOT NULL
  AND fg.yearid = RIGHT(
    gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
    2
  ) + 10
