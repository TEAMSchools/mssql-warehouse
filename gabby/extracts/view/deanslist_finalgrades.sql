CREATE OR ALTER VIEW
  extracts.deanslist_finalgrades AS
WITH
  enr AS (
    SELECT
      studentid,
      sectionid,
      currentabsences,
      currenttardies,
      course_number,
      sections_dcid,
      section_number,
      teacher_lastfirst,
      course_name,
      credit_hours,
      is_dropped_section,
      include_grades_display,
      term,
      [db_name],
      rn,
      AVG(is_dropped_section) OVER (
        PARTITION BY
          yearid,
          course_number,
          studentid
      ) AS is_dropped_course
    FROM
      (
        SELECT
          cc.studentid,
          cc.sectionid,
          cc.[db_name],
          ISNULL(cc.currentabsences, 0) AS currentabsences,
          ISNULL(cc.currenttardies, 0) AS currenttardies,
          CAST(RIGHT(cc.studyear, 2) AS INT) AS yearid,
          CASE
            WHEN cc.sectionid < 0 THEN 1.0
            ELSE 0.0
          END AS is_dropped_section,
          sec.course_number,
          sec.course_name,
          sec.dcid AS sections_dcid,
          sec.section_number,
          sec.teacher_lastfirst,
          sec.credit_hours,
          ABS(sec.excludefromgpa - 1) AS include_grades_display,
          rt.alt_name AS term,
          ROW_NUMBER() OVER (
            PARTITION BY
              cc.studyear,
              cc.course_number,
              rt.alt_name
            ORDER BY
              CASE
                WHEN cc.sectionid < 0 THEN 1.0
                ELSE 0.0
              END ASC,
              cc.dateenrolled DESC
          ) AS rn
        FROM
          powerschool.cc
          INNER JOIN powerschool.sections_identifiers AS sec ON (
            ABS(cc.sectionid) = sec.sectionid
            AND cc.[db_name] = sec.[db_name]
          )
          INNER JOIN gabby.reporting.reporting_terms AS rt ON (
            cc.schoolid = rt.schoolid
            AND rt.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
            AND rt.identifier = 'RT'
          )
        WHERE
          cc.dateenrolled >= DATEFROMPARTS(
            gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
            7,
            1
          )
      ) AS sub
  )
SELECT
  co.student_number,
  co.academic_year,
  enr.course_number,
  enr.sectionid,
  enr.sections_dcid,
  enr.section_number,
  enr.teacher_lastfirst AS teacher_name,
  enr.course_name,
  enr.credit_hours,
  enr.include_grades_display,
  enr.currentabsences,
  enr.currenttardies,
  enr.term,
  MAX(
    fg.rt1_term_grade_percent_adjusted
  ) OVER (
    PARTITION BY
      co.studentid,
      co.yearid,
      enr.course_number
    ORDER BY
      enr.term ASC
  ) AS [Q1_pct],
  MAX(
    fg.rt1_term_grade_letter_adjusted
  ) OVER (
    PARTITION BY
      co.studentid,
      co.yearid,
      enr.course_number
    ORDER BY
      enr.term ASC
  ) AS [Q1_letter],
  MAX(
    fg.rt2_term_grade_percent_adjusted
  ) OVER (
    PARTITION BY
      co.studentid,
      co.yearid,
      enr.course_number
    ORDER BY
      enr.term ASC
  ) AS [Q2_pct],
  MAX(
    fg.rt2_term_grade_letter_adjusted
  ) OVER (
    PARTITION BY
      co.studentid,
      co.yearid,
      enr.course_number
    ORDER BY
      enr.term ASC
  ) AS [Q2_letter],
  MAX(
    fg.rt3_term_grade_percent_adjusted
  ) OVER (
    PARTITION BY
      co.studentid,
      co.yearid,
      enr.course_number
    ORDER BY
      enr.term ASC
  ) AS [Q3_pct],
  MAX(
    fg.rt3_term_grade_letter_adjusted
  ) OVER (
    PARTITION BY
      co.studentid,
      co.yearid,
      enr.course_number
    ORDER BY
      enr.term ASC
  ) AS [Q3_letter],
  MAX(
    fg.rt4_term_grade_percent_adjusted
  ) OVER (
    PARTITION BY
      co.studentid,
      co.yearid,
      enr.course_number
    ORDER BY
      enr.term ASC
  ) AS [Q4_pct],
  MAX(
    fg.rt4_term_grade_letter_adjusted
  ) OVER (
    PARTITION BY
      co.studentid,
      co.yearid,
      enr.course_number
    ORDER BY
      enr.term ASC
  ) AS [Q4_letter],
  COALESCE(
    sgy1.[percent],
    fg.y1_grade_percent_adj
  ) AS y1_pct,
  COALESCE(sgy1.grade, fg.y1_grade_letter) AS y1_letter,
  cat.f_cur AS f_term,
  cat.s_cur AS s_term,
  cat.w_cur AS w_term,
  cat.w_rt1,
  cat.w_rt2,
  cat.w_rt3,
  cat.w_rt4,
  NULL AS e1_pct,
  NULL AS e2_pct,
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
  INNER JOIN enr ON (
    co.studentid = enr.studentid
    AND co.[db_name] = enr.[db_name]
    AND enr.rn = 1
    AND enr.is_dropped_section = 0
    AND enr.is_dropped_course < 1.0
  )
  LEFT JOIN powerschool.final_grades_wide_static AS fg ON (
    co.studentid = fg.studentid
    AND co.yearid = fg.yearid
    AND co.[db_name] = fg.[db_name]
    AND enr.course_number = fg.course_number
    AND enr.term = fg.storecode
    AND fg.reporting_term != 'CUR'
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
    AND enr.section_number LIKE '0%'
  )
  LEFT JOIN powerschool.pgfinalgrades AS comm ON (
    co.studentid = comm.studentid
    AND co.[db_name] = comm.[db_name]
    AND enr.sectionid = comm.sectionid
    AND enr.term = comm.finalgradename
  )
  LEFT JOIN powerschool.storedgrades AS sgy1 ON (
    co.studentid = sgy1.studentid
    AND co.academic_year = sgy1.academic_year
    AND co.[db_name] = sgy1.[db_name]
    AND enr.course_number = sgy1.course_number
    AND enr.term = 'Q4'
    AND sgy1.storecode = 'Y1'
  )
WHERE
  co.academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.rn_year = 1
  AND co.grade_level != 99
