CREATE OR ALTER VIEW
  tableau.miami_fast AS
WITH
  subjects AS (
    SELECT
      s.[value] AS iready_subject,
      CASE
        WHEN s.[value] = 'Reading' THEN 'ELA'
        ELSE s.[value]
      END AS fsa_subject,
      CASE
        WHEN s.[value] = 'Reading' THEN 'ENG'
        WHEN s.[value] = 'Math' THEN 'MATH'
      END AS credittype
    FROM
      STRING_SPLIT ('Reading,Math', ',') AS s
  ),
  current_week AS (
    SELECT
      tw.[date]
    FROM
      utilities.reporting_days AS td
      INNER JOIN utilities.reporting_days AS tw ON (
        (
          td.week_part = tw.week_part
          OR td.week_part - 1 = tw.week_part
        )
        AND td.year_part = tw.year_part
      )
    WHERE
      td.[date] = CAST(CURRENT_TIMESTAMP AS DATE)
  ),
  iready_lessons AS (
    SELECT
      student_id,
      [subject],
      CAST(
        SUM(
          CASE
            WHEN passed_or_not_passed = 'Passed' THEN 1
            ELSE 0
          END
        ) AS FLOAT
      ) AS lessons_passed,
      CAST(
        COUNT(DISTINCT lesson_id) AS FLOAT
      ) AS total_lessons,
      ROUND(
        SUM(
          CASE
            WHEN passed_or_not_passed = 'Passed' THEN 1.0
            ELSE 0.0
          END
        ) / CAST(COUNT(lesson_id) AS FLOAT),
        2
      ) AS pct_passed
    FROM
      iready.personalized_instruction_by_lesson
    WHERE
      completion_date IN (
        SELECT
          [date]
        FROM
          current_week
      )
    GROUP BY
      student_id,
      [subject]
  ),
  qaf_pct_correct AS (
    SELECT
      local_student_id,
      [QAF1],
      [QAF2],
      [QAF3],
      [QAF4]
    FROM
      (
        SELECT
          a.module_number,
          asr.percent_correct,
          s.local_student_id
        FROM
          gabby.illuminate_dna_assessments.assessments_identifiers_static AS a
          INNER JOIN gabby.illuminate.stg_agg_student_responses AS asr ON (
            a.assessment_id = asr.assessment_id
          )
          -- trunk-ignore(sqlfluff/LT05)
          INNER JOIN gabby.illuminate_public.students AS s ON (asr.student_id = s.student_id)
        WHERE
          a.module_type = 'QAF'
      ) AS sub PIVOT (
        MAX(percent_correct) FOR module_number IN ([QAF1], [QAF2], [QAF3], [QAF4])
      ) AS p
  )
SELECT
  co.student_number,
  co.state_studentnumber AS mdcps_id,
  co.lastfirst,
  co.grade_level,
  co.schoolid,
  co.school_name,
  co.team,
  co.school_abbreviation,
  co.year_in_network,
  co.gender,
  co.ethnicity,
  co.iep_status,
  co.lep_status,
  co.lunchstatus,
  co.is_retained_year,
  suf.fleid,
  subj.fsa_subject,
  subj.iready_subject,
  ce.course_number,
  ce.course_name,
  ce.section_number,
  ce.teacher_name,
  ir.total_lessons,
  ir.lessons_passed,
  ir.pct_passed,
  ia.[QAF1],
  ia.[QAF2],
  ia.[QAF3],
  ia.[QAF4],
  dr1.overall_scale_score AS diagnostic_scale,
  dr1.overall_relative_placement AS diagnostic_overall_relative_placement,
  dr1.annual_typical_growth_measure,
  dr1.annual_stretch_growth_measure,
  dr2.overall_scale_score AS recent_scale,
  dr2.overall_relative_placement AS recent_overall_relative_placement,
  dr2.overall_placement AS recent_overall_placement,
  dr2.diagnostic_gain,
  dr2.lexile_measure AS lexile_recent,
  dr2.lexile_range AS lexile_range_recent,
  dr2.rush_flag,
  ROUND(
    CAST(dr2.diagnostic_gain AS FLOAT) / CAST(
      dr1.annual_typical_growth_measure AS FLOAT
    ),
    2
  ) AS progress_to_typical,
  ROUND(
    CAST(dr2.diagnostic_gain AS FLOAT) / CAST(
      dr1.annual_stretch_growth_measure AS FLOAT
    ),
    2
  ) AS progress_to_stretch,
  cw1.sublevel_name AS projected_sublevel,
  cw1.sublevel_number AS projected_sublevel_number,
  cw2.scale_low AS scale_for_proficiency,
  CASE
    WHEN cw2.scale_low - dr2.overall_scale_score <= 0 THEN 0
    ELSE cw2.scale_low - dr2.overall_scale_score
  END AS scale_points_to_proficiency,
  ft.scale_score,
  ft.scale_score_prev,
  ft.achievement_level,
  ft.mastery_indicator,
  ft.standard_domain,
  ft.rn_test AS rn_test_fast,
  LEFT(ft.pm_round, 3) AS pm_round,
  CASE
    WHEN ft.mastery_indicator = 'n/a' THEN NULL
    WHEN ft.mastery_indicator = 'Below the Standard' THEN 1
    WHEN ft.mastery_indicator = 'At/Near the Standard' THEN 2
    WHEN ft.mastery_indicator = 'Above the Standard' THEN 3
  END AS mastery_number,
  cw3.sublevel_name AS fast_sublevel_name,
  cw3.sublevel_number AS fast_sublevel_number,
  CASE
    WHEN (
      co.is_retained_year != 1
      AND RIGHT(ft.achievement_level, 1) < 2
      AND subj.fsa_subject = 'ELA'
      AND co.grade_level = 3
    ) THEN 1
    ELSE 0
  END AS gr3_retention_flag
FROM
  kippmiami.powerschool.cohort_identifiers_static AS co
  LEFT JOIN kippmiami.powerschool.u_studentsuserfields AS suf ON (
    co.students_dcid = suf.studentsdcid
  )
  CROSS JOIN subjects AS subj
  LEFT JOIN kippmiami.powerschool.course_enrollments_current_static AS ce ON (
    ce.student_number = co.student_number
    AND ce.credittype = subj.credittype
    AND ce.section_enroll_status = 0
    AND ce.rn_subject = 1
  )
  LEFT JOIN iready_lessons AS ir ON (
    co.student_number = ir.student_id
    AND subj.iready_subject = ir.[subject]
  )
  LEFT JOIN qaf_pct_correct AS ia ON (
    co.student_number = ia.local_student_id
  )
  LEFT JOIN gabby.iready.diagnostic_results AS dr1 ON (
    dr1.student_id = co.student_number
    AND LEFT(dr1.academic_year, 4) = co.academic_year
    AND (
      CASE
        WHEN dr1._file LIKE '%ela%' THEN 'Reading'
        WHEN dr1._file LIKE '%math%' THEN 'Math'
      END
    ) = subj.iready_subject
    AND dr1.baseline_diagnostic_y_n_ = 'Y'
  )
  LEFT JOIN gabby.iready.diagnostic_results AS dr2 ON (
    dr1.student_id = dr2.student_id
    AND dr1._file = dr2._file
    AND dr2.most_recent_diagnostic_y_n_ = 'Y'
  )
  LEFT JOIN assessments.fsa_iready_crosswalk AS cw1 ON (
    co.grade_level = cw1.grade_level
    AND (
      CASE
        WHEN dr1._file LIKE '%ela%' THEN 'Reading'
        WHEN dr1._file LIKE '%math%' THEN 'Math'
      END
    ) = cw1.test_name
    AND (
      (dr2.overall_scale_score) BETWEEN cw1.scale_low AND cw1.scale_high
    )
    AND cw1.source_system = 'i-Ready'
    AND cw1.destination_system = 'FL'
  )
  LEFT JOIN assessments.fsa_iready_crosswalk AS cw2 ON (
    co.grade_level = cw2.grade_level
    AND (
      CASE
        WHEN dr1._file LIKE '%ela%' THEN 'Reading'
        WHEN dr1._file LIKE '%math%' THEN 'Math'
      END
    ) = cw2.test_name
    AND cw2.source_system = 'i-Ready'
    AND cw2.destination_system = 'FL'
    AND cw2.sublevel_name = 'Level 3'
  )
  LEFT JOIN kippmiami.fast.student_data_long AS ft ON (
    ft.fleid = suf.fleid
    AND ft.fast_subject = subj.iready_subject
    AND ISNUMERIC(ft.scale_score) = 1
  )
  LEFT JOIN assessments.fsa_iready_crosswalk AS cw3 ON (
    cw3.test_name = ft.fast_test
    -- trunk-ignore(sqlfluff/CP02,sqlfluff/RF02)
    COLLATE SQL_Latin1_General_CP1_CI_AS
    AND (
      ft.scale_score BETWEEN cw3.scale_low AND cw3.scale_high
    )
    AND cw3.source_system = 'FSA'
  )
WHERE
  co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.rn_year = 1
  AND co.enroll_status = 0
  AND co.grade_level >= 3
