CREATE OR ALTER VIEW
  tableau.gradebook_dashboard AS
WITH
  section_teacher AS (
    SELECT
      scaff.studentid,
      scaff.yearid,
      scaff.course_number,
      scaff.sectionid,
      scaff.[db_name],
      sec.credittype,
      sec.course_name,
      sec.section_number,
      sec.external_expression,
      sec.termid,
      sec.teacher_lastfirst AS teacher_name
    FROM
      powerschool.course_section_scaffold AS scaff
      LEFT JOIN powerschool.sections_identifiers AS sec ON (
        scaff.sectionid = sec.sectionid
        AND scaff.[db_name] = sec.[db_name]
      )
    WHERE
      scaff.is_curterm = 1
  ),
  final_grades AS (
    SELECT
      fg.studentid,
      fg.yearid,
      fg.[db_name],
      fg.course_number,
      fg.sectionid,
      fg.storecode,
      fg.exclude_from_gpa,
      fg.potential_credit_hours,
      fg.term_grade_percent_adj,
      fg.term_grade_letter_adj,
      fg.term_grade_pts,
      fg.y1_grade_percent_adj,
      fg.y1_grade_letter,
      fg.y1_grade_pts,
      fg.need_60,
      fg.need_70,
      fg.need_80,
      fg.need_90,
      CASE
        WHEN (
          CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN fg.termbin_start_date AND fg.termbin_end_date -- noqa: L016
        ) THEN 1
        ELSE 0
      END AS is_curterm,
      cou.credittype,
      cou.course_name
    FROM
      powerschool.final_grades_static AS fg
      INNER JOIN powerschool.courses AS cou ON (
        fg.course_number = cou.course_number
        AND fg.[db_name] = cou.[db_name]
      )
    WHERE
      fg.termbin_start_date <= CURRENT_TIMESTAMP
  )
  /* current year - term grades */
SELECT
  co.student_number,
  co.lastfirst,
  co.reporting_schoolid AS schoolid,
  co.grade_level,
  co.team,
  co.advisor_name,
  co.enroll_status,
  co.academic_year,
  co.iep_status,
  co.cohort,
  co.region,
  co.gender,
  co.school_level,
  CASE
    WHEN sp.studentid IS NOT NULL THEN 1
  END AS is_counselingservices,
  CASE
    WHEN sa.studentid IS NOT NULL THEN 1
  END AS is_studentathlete,
  gr.course_number,
  gr.storecode AS term_name,
  gr.storecode AS finalgradename,
  gr.exclude_from_gpa AS excludefromgpa,
  gr.potential_credit_hours AS credit_hours,
  gr.term_grade_percent_adj AS term_grade_percent_adjusted,
  gr.term_grade_letter_adj AS term_grade_letter_adjusted,
  gr.term_grade_pts AS term_gpa_points,
  gr.y1_grade_percent_adj AS y1_grade_percent_adjusted,
  gr.y1_grade_letter,
  gr.y1_grade_pts AS y1_gpa_points,
  gr.is_curterm,
  gr.credittype,
  gr.course_name,
  NULL AS earnedcrhrs,
  CASE
    WHEN pgf.citizenship != '' THEN pgf.citizenship
  END AS citizenship,
  CASE
    WHEN pgf.comment_value != '' THEN pgf.comment_value
  END AS comment_value,
  st.sectionid,
  st.termid,
  st.teacher_name,
  st.section_number,
  st.section_number AS [period],
  st.external_expression,
  MAX(
    CASE
      WHEN gr.is_curterm = 1 THEN gr.need_60
    END
  ) OVER (
    PARTITION BY
      co.student_number,
      co.academic_year,
      gr.course_number
  ) AS need_65,
  MAX(
    CASE
      WHEN gr.is_curterm = 1 THEN gr.need_70
    END
  ) OVER (
    PARTITION BY
      co.student_number,
      co.academic_year,
      gr.course_number
  ) AS need_70,
  MAX(
    CASE
      WHEN gr.is_curterm = 1 THEN gr.need_80
    END
  ) OVER (
    PARTITION BY
      co.student_number,
      co.academic_year,
      gr.course_number
  ) AS need_80,
  MAX(
    CASE
      WHEN gr.is_curterm = 1 THEN gr.need_90
    END
  ) OVER (
    PARTITION BY
      co.student_number,
      co.academic_year,
      gr.course_number
  ) AS need_90
FROM
  powerschool.cohort_identifiers_static AS co
  LEFT JOIN final_grades AS gr ON (
    co.studentid = gr.studentid
    AND co.yearid = gr.yearid
    AND co.[db_name] = gr.[db_name]
  )
  LEFT JOIN powerschool.pgfinalgrades AS pgf ON (
    gr.studentid = pgf.studentid
    AND gr.sectionid = pgf.sectionid
    AND gr.storecode = pgf.finalgradename
    AND gr.[db_name] = pgf.[db_name]
  )
  LEFT JOIN section_teacher AS st ON (
    co.studentid = st.studentid
    AND co.yearid = st.yearid
    AND co.[db_name] = st.[db_name]
    AND gr.course_number = st.course_number
  )
  LEFT JOIN powerschool.spenrollments_gen_static AS sp ON (
    co.studentid = sp.studentid
    AND (
      CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN sp.enter_date AND sp.exit_date
    )
    AND sp.specprog_name = 'Counseling Services'
    AND co.[db_name] = sp.[db_name]
  )
  LEFT JOIN powerschool.spenrollments_gen_static AS sa ON (
    co.studentid = sa.studentid
    AND (
      CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN sa.enter_date AND sa.exit_date
    )
    AND sa.specprog_name = 'Student Athlete'
    AND co.[db_name] = sa.[db_name]
  )
WHERE
  co.rn_year = 1
  AND co.grade_level != 99
  AND co.academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
UNION ALL
/* current year - Y1 grades */
SELECT
  co.student_number,
  co.lastfirst,
  co.reporting_schoolid AS schoolid,
  co.grade_level,
  co.team,
  co.advisor_name,
  co.enroll_status,
  co.academic_year,
  co.iep_status,
  co.cohort,
  co.region,
  co.gender,
  co.school_level,
  CASE
    WHEN sp.studentid IS NOT NULL THEN 1
  END AS is_counselingservices,
  CASE
    WHEN sa.studentid IS NOT NULL THEN 1
  END AS is_studentathlete,
  gr.course_number,
  'Y1' AS term_name,
  'Y1' AS finalgradename,
  gr.exclude_from_gpa AS excludefromgpa,
  gr.potential_credit_hours AS credit_hours,
  gr.y1_grade_percent_adj AS term_grade_percent_adjusted,
  gr.y1_grade_letter AS term_grade_letter_adjusted,
  gr.y1_grade_pts AS term_gpa_points,
  gr.y1_grade_percent_adj AS y1_grade_percent_adjusted,
  gr.y1_grade_letter,
  gr.y1_grade_pts AS y1_gpa_points,
  gr.is_curterm,
  gr.credittype,
  gr.course_name,
  y1.earnedcrhrs,
  NULL AS citizenship,
  NULL AS comment_value,
  st.sectionid,
  st.termid,
  st.teacher_name,
  st.section_number,
  st.section_number AS [period],
  st.external_expression,
  MAX(
    CASE
      WHEN gr.is_curterm = 1 THEN gr.need_60
    END
  ) OVER (
    PARTITION BY
      co.student_number,
      co.academic_year,
      gr.course_number
  ) AS need_65,
  MAX(
    CASE
      WHEN gr.is_curterm = 1 THEN gr.need_70
    END
  ) OVER (
    PARTITION BY
      co.student_number,
      co.academic_year,
      gr.course_number
  ) AS need_70,
  MAX(
    CASE
      WHEN gr.is_curterm = 1 THEN gr.need_80
    END
  ) OVER (
    PARTITION BY
      co.student_number,
      co.academic_year,
      gr.course_number
  ) AS need_80,
  MAX(
    CASE
      WHEN gr.is_curterm = 1 THEN gr.need_90
    END
  ) OVER (
    PARTITION BY
      co.student_number,
      co.academic_year,
      gr.course_number
  ) AS need_90
FROM
  powerschool.cohort_identifiers_static AS co
  LEFT JOIN final_grades AS gr ON (
    co.studentid = gr.studentid
    AND co.yearid = gr.yearid
    AND co.[db_name] = gr.[db_name]
    AND gr.is_curterm = 1
  )
  LEFT JOIN powerschool.storedgrades AS y1 ON (
    co.studentid = y1.studentid
    AND co.academic_year = y1.academic_year
    AND co.[db_name] = y1.[db_name]
    AND gr.course_number = y1.course_number
    AND y1.storecode = 'Y1'
  )
  LEFT JOIN section_teacher AS st ON (
    co.studentid = st.studentid
    AND co.yearid = st.yearid
    AND co.[db_name] = st.[db_name]
    AND gr.course_number = st.course_number
  )
  LEFT JOIN powerschool.spenrollments_gen_static AS sp ON (
    co.studentid = sp.studentid
    AND (
      CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN sp.enter_date AND sp.exit_date
    )
    AND sp.specprog_name = 'Counseling Services'
    AND co.[db_name] = sp.[db_name]
  )
  LEFT JOIN powerschool.spenrollments_gen_static AS sa ON (
    co.studentid = sa.studentid
    AND (
      CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN sa.enter_date AND sa.exit_date
    )
    AND sa.specprog_name = 'Student Athlete'
    AND co.[db_name] = sa.[db_name]
  )
WHERE
  co.rn_year = 1
  AND co.grade_level != 99
  AND co.academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
UNION ALL
/* historical grades */
SELECT
  co.student_number,
  co.lastfirst,
  co.reporting_schoolid AS schoolid,
  co.grade_level,
  co.team,
  co.advisor_name,
  co.enroll_status,
  co.academic_year,
  co.iep_status,
  co.cohort,
  co.region,
  co.gender,
  co.school_level,
  CASE
    WHEN sp.studentid IS NOT NULL THEN 1
  END AS is_counselingservices,
  CASE
    WHEN sa.studentid IS NOT NULL THEN 1
  END AS is_studentathlete,
  sg.course_number,
  'Y1' AS term_name,
  'Y1' AS finalgradename,
  sg.excludefromgpa,
  sg.potentialcrhrs AS credit_hours,
  sg.[percent] AS term_grade_percent_adjusted,
  sg.grade AS term_grade_letter_adjusted,
  sg.gpa_points AS term_gpa_points,
  sg.[percent] AS y1_grade_percent_adjusted,
  sg.grade AS y1_grade_letter,
  sg.gpa_points AS y1_gpa_points,
  1 AS is_curterm,
  sg.credit_type AS credittype,
  sg.course_name,
  sg.earnedcrhrs,
  NULL AS citizenship,
  NULL AS comment_value,
  st.sectionid,
  st.termid,
  st.teacher_name,
  st.section_number,
  st.section_number AS [period],
  st.external_expression,
  NULL AS need_65,
  NULL AS need_70,
  NULL AS need_80,
  NULL AS need_90
FROM
  powerschool.cohort_identifiers_static AS co
  LEFT JOIN powerschool.storedgrades AS sg ON (
    co.studentid = sg.studentid
    AND co.academic_year = sg.academic_year
    AND co.[db_name] = sg.[db_name]
    AND sg.storecode = 'Y1'
    AND sg.course_number IS NOT NULL
  )
  LEFT JOIN section_teacher AS st ON (
    co.studentid = st.studentid
    AND co.yearid = st.yearid
    AND co.[db_name] = st.[db_name]
    AND sg.course_number = st.course_number
  )
  LEFT JOIN powerschool.spenrollments_gen_static AS sp ON (
    co.studentid = sp.studentid
    AND (
      CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN sp.enter_date AND sp.exit_date
    )
    AND sp.specprog_name = 'Counseling Services'
    AND co.[db_name] = sp.[db_name]
  )
  LEFT JOIN powerschool.spenrollments_gen_static AS sa ON (
    co.studentid = sa.studentid
    AND (
      CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN sa.enter_date AND sa.exit_date
    )
    AND sa.specprog_name = 'Student Athlete'
    AND co.[db_name] = sa.[db_name]
  )
WHERE
  co.rn_year = 1
  AND co.academic_year != utilities.GLOBAL_ACADEMIC_YEAR ()
UNION ALL
/* transfer grades */
SELECT
  COALESCE(
    co.student_number,
    e1.student_number
  ) AS student_number,
  COALESCE(co.lastfirst, e1.lastfirst) AS lastfirst,
  COALESCE(co.schoolid, e1.schoolid) AS schoolid,
  COALESCE(co.grade_level, e1.grade_level) AS grade_level,
  COALESCE(co.team, e1.team) AS team,
  NULL AS advisor_name,
  COALESCE(
    co.enroll_status,
    e1.enroll_status
  ) AS enroll_status,
  tr.academic_year,
  COALESCE(co.iep_status, e1.iep_status) AS iep_status,
  COALESCE(co.cohort, e1.cohort) AS cohort,
  COALESCE(co.region, e1.region) AS region,
  COALESCE(co.gender, e1.gender) AS gender,
  COALESCE(co.school_level, e1.school_level) AS school_level,
  CASE
    WHEN sp.studentid IS NOT NULL THEN 1
  END AS is_counselingservices,
  CASE
    WHEN sa.studentid IS NOT NULL THEN 1
  END AS is_studentathlete,
  CONCAT(
    'TRANSFER',
    tr.termid,
    tr.[db_name],
    tr.dcid
  ) AS course_number,
  'Y1' AS term_name,
  'Y1' AS finalgradename,
  tr.excludefromgpa,
  tr.potentialcrhrs AS credit_hours,
  tr.[percent] AS term_grade_percent_adjusted,
  tr.grade AS term_grade_letter_adjusted,
  tr.gpa_points AS term_gpa_points,
  tr.[percent] AS y1_grade_percent_adjusted,
  tr.grade AS y1_grade_letter,
  tr.gpa_points AS y1_gpa_points,
  1 AS is_curterm,
  'TRANSFER' AS credittype,
  tr.course_name,
  tr.earnedcrhrs,
  NULL AS citizenship,
  NULL AS comment_value,
  tr.sectionid,
  tr.termid,
  'TRANSFER' AS teacher_name,
  'TRANSFER' AS section_number,
  NULL AS [period],
  NULL AS external_expression,
  NULL AS need_65,
  NULL AS need_70,
  NULL AS need_80,
  NULL AS need_90
FROM
  powerschool.storedgrades AS tr
  LEFT JOIN powerschool.cohort_identifiers_static AS co ON (
    tr.studentid = co.studentid
    AND tr.schoolid = co.schoolid
    AND tr.[db_name] = co.[db_name]
    AND tr.academic_year = co.academic_year
    AND co.rn_year = 1
  )
  LEFT JOIN powerschool.cohort_identifiers_static AS e1 ON (
    tr.studentid = e1.studentid
    AND tr.schoolid = e1.schoolid
    AND tr.[db_name] = e1.[db_name]
    AND e1.year_in_school = 1
  )
  LEFT JOIN powerschool.spenrollments_gen_static AS sp ON (
    co.studentid = sp.studentid
    AND (
      CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN sp.enter_date AND sp.exit_date
    )
    AND sp.specprog_name = 'Counseling Services'
    AND co.[db_name] = sp.[db_name]
  )
  LEFT JOIN powerschool.spenrollments_gen_static AS sa ON (
    co.studentid = sa.studentid
    AND (
      CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN sa.enter_date AND sa.exit_date
    )
    AND sa.specprog_name = 'Student Athlete'
    AND co.[db_name] = sa.[db_name]
  )
WHERE
  tr.storecode = 'Y1'
  AND tr.course_number IS NULL
UNION ALL
/* category grades - term */
SELECT
  co.student_number,
  co.lastfirst,
  co.reporting_schoolid AS schoolid,
  co.grade_level,
  co.team,
  co.advisor_name,
  co.enroll_status,
  co.academic_year,
  co.iep_status,
  co.cohort,
  co.region,
  co.gender,
  co.school_level,
  CASE
    WHEN sp.studentid IS NOT NULL THEN 1
  END AS is_counselingservices,
  CASE
    WHEN sa.studentid IS NOT NULL THEN 1
  END AS is_studentathlete,
  cg.course_number,
  REPLACE(cg.reporting_term, 'RT', 'Q') AS term_name,
  cg.storecode_type AS finalgradename,
  NULL AS excludefromgpa,
  NULL AS credit_hours,
  cg.category_pct AS term_grade_percent_adjusted,
  NULL AS term_grade_letter_adjusted,
  NULL AS term_gpa_points,
  cg.category_pct_y1 AS y1_grade_percent_adjusted,
  NULL AS y1_grade_letter,
  NULL AS y1_gpa_points,
  CASE
    WHEN (
      CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN cg.termbin_start_date AND cg.termbin_end_date -- noqa: L016
    ) THEN 1
    ELSE 0
  END AS is_curterm,
  st.credittype,
  st.course_name,
  NULL AS earnedcrhrs,
  NULL AS citizenship,
  NULL AS comment_value,
  st.sectionid,
  st.termid,
  st.teacher_name,
  st.section_number,
  st.section_number AS [period],
  st.external_expression,
  NULL AS need_65,
  NULL AS need_70,
  NULL AS need_80,
  NULL AS need_90
FROM
  powerschool.cohort_identifiers_static AS co
  LEFT JOIN powerschool.category_grades_static AS cg ON (
    co.studentid = cg.studentid
    AND co.yearid = cg.yearid
    AND co.[db_name] = cg.[db_name]
    AND cg.storecode_type != 'Q'
  )
  LEFT JOIN section_teacher AS st ON (
    co.studentid = st.studentid
    AND co.yearid = st.yearid
    AND co.[db_name] = st.[db_name]
    AND cg.course_number = st.course_number
  )
  LEFT JOIN powerschool.spenrollments_gen_static AS sp ON (
    co.studentid = sp.studentid
    AND (
      CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN sp.enter_date AND sp.exit_date
    )
    AND sp.specprog_name = 'Counseling Services'
    AND co.[db_name] = sp.[db_name]
  )
  LEFT JOIN powerschool.spenrollments_gen_static AS sa ON (
    co.studentid = sa.studentid
    AND (
      CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN sa.enter_date AND sa.exit_date
    )
    AND sa.specprog_name = 'Student Athlete'
    AND co.[db_name] = sa.[db_name]
  )
WHERE
  co.rn_year = 1
  AND co.grade_level != 99
  AND co.academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
UNION ALL
/* category grades - year */
SELECT
  co.student_number,
  co.lastfirst,
  co.reporting_schoolid AS schoolid,
  co.grade_level,
  co.team,
  co.advisor_name,
  co.enroll_status,
  co.academic_year,
  co.iep_status,
  co.cohort,
  co.region,
  co.gender,
  co.school_level,
  CASE
    WHEN sp.studentid IS NOT NULL THEN 1
  END AS is_counselingservices,
  CASE
    WHEN sa.studentid IS NOT NULL THEN 1
  END AS is_studentathlete,
  cy.course_number,
  'Y1' AS term_name,
  CONCAT(cy.storecode_type, 'Y1') AS finalgradename,
  NULL AS excludefromgpa,
  NULL AS credit_hours,
  cy.category_pct_y1 AS term_grade_percent_adjusted,
  NULL AS term_grade_letter_adjusted,
  NULL AS term_gpa_points,
  cy.category_pct_y1 AS y1_grade_percent_adjusted,
  NULL AS y1_grade_letter,
  NULL AS y1_gpa_points,
  1 AS is_curterm,
  st.credittype,
  st.course_name,
  NULL AS earnedcrhrs,
  NULL AS citizenship,
  NULL AS comment_value,
  st.sectionid,
  st.termid,
  st.teacher_name,
  st.section_number,
  st.section_number AS [period],
  st.external_expression,
  NULL AS need_65,
  NULL AS need_70,
  NULL AS need_80,
  NULL AS need_90
FROM
  powerschool.cohort_identifiers_static AS co
  LEFT JOIN powerschool.category_grades_static AS cy ON (
    co.studentid = cy.studentid
    AND co.yearid = cy.yearid
    AND co.[db_name] = cy.[db_name]
    AND cy.storecode_type != 'Q'
    AND (
      CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN cy.termbin_start_date AND cy.termbin_end_date -- noqa: L016
    )
  )
  LEFT JOIN section_teacher AS st ON (
    co.studentid = st.studentid
    AND co.yearid = st.yearid
    AND co.[db_name] = st.[db_name]
    AND cy.course_number = st.course_number
  )
  LEFT JOIN powerschool.spenrollments_gen_static AS sp ON (
    co.studentid = sp.studentid
    AND (
      CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN sp.enter_date AND sp.exit_date
    )
    AND sp.specprog_name = 'Counseling Services'
    AND co.[db_name] = sp.[db_name]
  )
  LEFT JOIN powerschool.spenrollments_gen_static AS sa ON (
    co.studentid = sa.studentid
    AND (
      CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN sa.enter_date AND sa.exit_date
    )
    AND sa.specprog_name = 'Student Athlete'
    AND co.[db_name] = sa.[db_name]
  )
WHERE
  co.rn_year = 1
  AND co.grade_level != 99
  AND co.academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
  -- noqa: disable=L016
  -- /* current year - HS exam grades
  -- UNION ALL
  -- SELECT
  --   co.student_number,
  --   co.lastfirst,
  --   co.reporting_schoolid AS schoolid,
  --   co.grade_level,
  --   co.team,
  --   co.advisor_name,
  --   co.enroll_status,
  --   co.academic_year,
  --   co.iep_status,
  --   co.cohort,
  --   co.region,
  --   co.gender,
  --   co.school_level,
  --   CASE
  --     WHEN sp.studentid IS NOT NULL THEN 1
  --   END AS is_counselingservices,
  --   ex.credittype,
  --   ex.course_number,
  --   ex.course_name,
  --   CASE
  --     WHEN ex.e1 IS NOT NULL THEN 'Q2'
  --     WHEN ex.e2 IS NOT NULL THEN 'Q4'
  --   END AS term_name,
  --   CASE
  --     WHEN ex.e1 IS NOT NULL THEN 'E1'
  --     WHEN ex.e2 IS NOT NULL THEN 'E2'
  --   END AS finalgradename,
  --   ex.is_curterm,
  --   ex.excludefromgpa,
  --   ex.credit_hours,
  --   COALESCE(ex.e1, ex.e2) AS term_grade_percent_adjusted,
  --   NULL AS term_grade_letter_adjusted,
  --   NULL AS term_gpa_points,
  --   NULL AS y1_grade_percent_adjusted,
  --   NULL AS y1_grade_letter,
  --   NULL AS y1_gpa_points,
  --   NULL AS earnedcrhrs,
  --   NULL AS citizenship,
  --   NULL AS comment_value,
  --   st.sectionid,
  --   st.termid,
  --   st.teacher_name,
  --   st.section_number,
  --   st.section_number AS [period],
  --   st.external_expression,
  --   NULL AS need_65,
  --   NULL AS need_70,
  --   NULL AS need_80,
  --   NULL AS need_90
  -- FROM
  --   powerschool.cohort_identifiers_static AS co
  --   LEFT JOIN powerschool.final_grades_static AS ex ON co.student_number = ex.student_number
  --   AND co.academic_year = ex.academic_year
  --   AND co.[db_name] = ex.[db_name]
  --   AND (
  --     ex.e1 IS NOT NULL
  --     OR ex.e2 IS NOT NULL
  --   )
  --   LEFT JOIN section_teacher AS st ON co.studentid = st.studentid
  --   AND co.yearid = st.yearid
  --   AND co.[db_name] = st.[db_name]
  --   AND ex.course_number = st.course_number
  --   LEFT JOIN powerschool.spenrollments_gen_static AS sp ON co.studentid = sp.studentid
  --   AND (
  --     CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN sp.enter_date AND sp.exit_date
  --   )
  --   AND sp.specprog_name = 'Counseling Services'
  --   AND co.[db_name] = sp.[db_name]
  -- WHERE
  --   co.rn_year = 1
  --   AND co.school_level = 'HS'
  --   AND co.academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
  --*/
