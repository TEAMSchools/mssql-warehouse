USE gabby GO
CREATE OR ALTER VIEW
  tableau.fsa_iready_analysis AS
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
      STRING_SPLIT ('Reading,Math', ',') s
  ),
  current_week AS (
    SELECT
      tw.[date]
    FROM
      gabby.utilities.reporting_days td
      INNER JOIN gabby.utilities.reporting_days tw ON td.week_part = tw.week_part
      AND td.year_part = tw.year_part
    WHERE
      td.[date] = CAST(CURRENT_TIMESTAMP AS DATE)
  ),
  iready_lessons AS (
    SELECT
      pl.student_id,
      pl.[subject],
      CAST(
        SUM(
          CASE
            WHEN pl.passed_or_not_passed = 'Passed' THEN 1
            ELSE 0
          END
        ) AS FLOAT
      ) AS lessons_passed,
      CAST(COUNT(DISTINCT pl.lesson_id) AS FLOAT) AS total_lessons,
      ROUND(
        SUM(
          CASE
            WHEN pl.passed_or_not_passed = 'Passed' THEN 1.0
            ELSE 0.0
          END
        ) / CAST(COUNT(pl.lesson_id) AS FLOAT),
        2
      ) AS pct_passed
    FROM
      gabby.iready.personalized_instruction_by_lesson pl
    WHERE
      pl.completion_date IN (
        SELECT
          [date]
        FROM
          current_week
      )
    GROUP BY
      pl.student_id,
      pl.[subject]
  ),
  fsp AS (
    SELECT
      student_id,
      fsa_grade,
      fsa_level,
      fsa_scale,
      iready_subject,
      CAST(CONCAT('20', RIGHT(fsa_year, 2)) AS INT) AS fsa_year,
      CONCAT(fsa_subject, ' ', fsa_grade) AS test_name,
      RANK() OVER (
        PARTITION BY
          fsa_grade,
          iready_subject
        ORDER BY
          fsa_scale ASC
      ) AS fsa_gr_subj_rank,
      COUNT(*) OVER (
        PARTITION BY
          fsa_grade,
          iready_subject
      ) AS fsa_gr_subj_count
    FROM
      (
        SELECT
          student_id,
          fsa_year,
          fsa_grade,
          fsa_level,
          fsa_scale_s AS fsa_scale,
          CASE
            WHEN _file LIKE '%Math%' THEN 'MATH'
            WHEN _file LIKE '%ELA%' THEN 'ELA'
          END AS fsa_subject,
          CASE
            WHEN _file LIKE '%Math%' THEN 'Math'
            WHEN _file LIKE '%ELA%' THEN 'Reading'
          END AS iready_subject
        FROM
          kippmiami.fsa.student_scores_previous
        WHERE
          fsa_scale_s <> ''
      ) sub
  )
SELECT
  co.student_number,
  co.state_studentnumber AS mdcps_id,
  co.lastfirst,
  co.grade_level,
  co.schoolid,
  co.school_name,
  co.is_retained_year,
  co.year_in_network,
  co.gender,
  co.ethnicity,
  co.iep_status,
  co.lep_status,
  co.lunchstatus,
  subj.iready_subject,
  subj.fsa_subject,
  suf.fleid,
  ce.course_number,
  ce.course_name,
  ce.teacher_name,
  di.diagnostic_overall_scale_score_most_recent_,
  di.diagnostic_completion_date_most_recent_,
  di.diagnostic_overall_relative_placement_most_recent_,
  di.diagnostic_percentile_most_recent_,
  di.[subject],
  di.annual_stretch_growth_measure,
  di.annual_typical_growth_measure,
  di.diagnostic_gain_note_negative_gains_zero_,
  COALESCE(
    di.diagnostic_overall_scale_score_1_,
    di.diagnostic_overall_scale_score_most_recent_
  ) AS iready_scale_boy,
  ir.total_lessons,
  ir.lessons_passed,
  ir.pct_passed,
  fsp.fsa_year - 1 AS fsa_year,
  fsp.fsa_grade,
  fsp.fsa_level,
  fsp.fsa_scale,
  CAST(fsp.fsa_gr_subj_rank AS FLOAT) / CAST(fsp.fsa_gr_subj_count AS FLOAT) AS fl_fsa_percentile,
  cw1.sublevel_name AS fsa_sublevel_name,
  cw1.sublevel_number AS fsa_sublevel_number,
  cw2.sublevel_name AS iready_sublevel_predict_name,
  cw2.sublevel_number AS iready_sublevel_predict_number,
  cw3.scale_low AS predicted_proficiency_scale,
  cw4.scale_low AS fsa_scale_for_growth,
  cw5.scale_low AS fsa_scale_for_proficiency,
  cw6.scale_low AS predicted_growth_scale
FROM
  kippmiami.powerschool.cohort_identifiers_static co
  CROSS JOIN subjects subj
  LEFT JOIN kippmiami.powerschool.u_studentsuserfields suf ON co.students_dcid = suf.studentsdcid
  LEFT JOIN kippmiami.powerschool.course_enrollments_current_static ce ON ce.student_number = co.student_number
  AND ce.credittype = subj.credittype
  AND ce.section_enroll_status = 0
  AND ce.rn_subject = 1
  LEFT JOIN gabby.iready.diagnostic_and_instruction di ON di.student_id = co.student_number
  AND LEFT(di.academic_year, 4) = co.academic_year
  AND di.[subject] = subj.iready_subject
  LEFT JOIN iready_lessons ir ON co.student_number = ir.student_id
  AND subj.iready_subject = ir.[subject]
  LEFT JOIN fsp ON co.state_studentnumber = fsp.student_id
  AND co.academic_year = fsp.fsa_year
  AND subj.iready_subject = fsp.iready_subject
  LEFT JOIN gabby.assessments.fsa_iready_crosswalk cw1 ON cw1.test_name = fsp.test_name
  AND fsp.fsa_scale BETWEEN cw1.scale_low AND cw1.scale_high
  AND cw1.source_system = 'FSA'
  LEFT JOIN gabby.assessments.fsa_iready_crosswalk cw2 ON co.grade_level = cw2.grade_level
  AND di.[subject] = cw2.test_name
  AND di.diagnostic_overall_scale_score_most_recent_ BETWEEN cw2.scale_low AND cw2.scale_high
  AND cw2.source_system = 'i-Ready'
  LEFT JOIN gabby.assessments.fsa_iready_crosswalk cw3 ON co.grade_level = cw3.grade_level
  AND di.[subject] = cw3.test_name
  AND cw3.source_system = 'i-Ready'
  AND cw3.sublevel_name = 'Level 3'
  LEFT JOIN gabby.assessments.fsa_iready_crosswalk cw4 ON cw4.test_name = CONCAT(subj.fsa_subject, ' ', co.grade_level)
  AND (cw1.sublevel_number + 1) = cw4.sublevel_number
  AND cw4.source_system = 'FSA'
  LEFT JOIN gabby.assessments.fsa_iready_crosswalk cw5 ON cw5.test_name = CONCAT(subj.fsa_subject, ' ', co.grade_level)
  AND cw5.sublevel_name = 'Level 3'
  AND cw5.source_system = 'FSA'
  LEFT JOIN gabby.assessments.fsa_iready_crosswalk cw6 ON cw6.test_name = subj.iready_subject
  AND cw1.sublevel_number + 1 = cw6.sublevel_number
  AND cw6.grade_level = co.grade_level
  AND cw6.source_system = 'i-Ready'
WHERE
  co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.rn_year = 1
  AND co.enroll_status = 0
  AND co.grade_level >= 3
