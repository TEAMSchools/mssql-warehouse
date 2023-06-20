CREATE OR ALTER VIEW
  extracts.deanslist_finalgrades AS
SELECT
  co.student_number,
  co.academic_year,
  fg.course_number,
  fg.sectionid,
  fg.storecode AS term,
  fg.rt1_term_grade_percent_adjusted AS [Q1_pct],
  fg.rt1_term_grade_letter_adjusted AS [Q1_letter],
  fg.rt2_term_grade_percent_adjusted AS [Q2_pct],
  fg.rt2_term_grade_letter_adjusted AS [Q2_letter],
  fg.rt3_term_grade_percent_adjusted AS [Q3_pct],
  fg.rt3_term_grade_letter_adjusted AS [Q3_letter],
  fg.rt4_term_grade_percent_adjusted AS [Q4_pct],
  fg.rt4_term_grade_letter_adjusted AS [Q4_letter],
  COALESCE(
    sgy1.[percent],
    fg.y1_grade_percent_adj
  ) AS y1_pct,
  COALESCE(sgy1.grade, fg.y1_grade_letter) AS y1_letter,
  sec.dcid AS sections_dcid,
  sec.section_number,
  sec.teacher_lastfirst AS teacher_name,
  sec.course_name,
  sec.credit_hours,
  cat.f_cur AS f_term,
  cat.s_cur AS s_term,
  cat.w_cur AS w_term,
  cat.w_rt1,
  cat.w_rt2,
  cat.w_rt3,
  cat.w_rt4,
  NULL AS e1_pct,
  NULL AS e2_pct,
  ABS(sec.excludefromgpa - 1) AS include_grades_display,
  ISNULL(cc.currentabsences, 0) AS currentabsences,
  ISNULL(cc.currenttardies, 0) AS currenttardies,
  COALESCE(
    LEAD(fg.need_60, 1) OVER (
      PARTITION BY
        fg.studentid,
        fg.course_number
      ORDER BY
        fg.storecode
    ),
    fg.need_60
  ) AS need_60,
  COALESCE(kctz.ctz_cur, cat.ctz_cur) AS ctz_cur,
  COALESCE(kctz.ctz_rt1, cat.ctz_rt1) AS ctz_rt1,
  COALESCE(kctz.ctz_rt2, cat.ctz_rt2) AS ctz_rt2,
  COALESCE(kctz.ctz_rt3, cat.ctz_rt3) AS ctz_rt3,
  COALESCE(kctz.ctz_rt4, cat.ctz_rt4) AS ctz_rt4,
  REPLACE(comm.comment_value, '"', '''') AS comment_value
FROM
  powerschool.cohort_static AS co
  INNER JOIN powerschool.final_grades_wide_static AS fg ON (
    co.studentid = fg.studentid
    AND co.yearid = fg.yearid
    AND co.[db_name] = fg.[db_name]
    AND fg.reporting_term != 'CUR'
  )
  INNER JOIN powerschool.sections_identifiers AS sec ON (
    fg.sectionid = sec.sectionid
    AND fg.[db_name] = sec.[db_name]
  )
  LEFT JOIN powerschool.cc ON (
    fg.studentid = cc.studentid
    AND fg.sectionid = cc.sectionid
    AND fg.[db_name] = cc.[db_name]
  )
  LEFT JOIN powerschool.category_grades_wide_static AS cat ON (
    co.studentid = cat.studentid
    AND fg.course_number = cat.course_number
    AND fg.reporting_term = cat.reporting_term
    AND fg.[db_name] = cat.[db_name]
  )
  LEFT JOIN powerschool.category_grades_wide_static AS kctz ON (
    co.studentid = kctz.studentid
    AND fg.reporting_term = kctz.reporting_term
    AND fg.[db_name] = kctz.[db_name]
    AND kctz.course_number = 'HR'
    AND sec.section_number LIKE '0%'
  )
  LEFT JOIN powerschool.pgfinalgrades AS comm ON (
    fg.studentid = comm.studentid
    AND fg.sectionid = comm.sectionid
    AND fg.storecode = comm.finalgradename
    AND fg.[db_name] = comm.[db_name]
  )
  LEFT JOIN powerschool.storedgrades AS sgy1 ON (
    co.studentid = sgy1.studentid
    AND co.academic_year = sgy1.academic_year
    AND co.[db_name] = sgy1.[db_name]
    AND fg.course_number = sgy1.course_number
    AND fg.storecode = 'Q4'
    AND sgy1.storecode = 'Y1'
  )
WHERE
  co.academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.rn_year = 1
  AND co.grade_level != 99
