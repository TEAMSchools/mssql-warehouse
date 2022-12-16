USE gabby GO
CREATE OR ALTER VIEW
  tableau.apm_iready_weekly AS
SELECT
  cis.student_number,
  cis.[date],
  cis.lastfirst,
  cis.grade_level,
  cis.region,
  cis.school_name,
  cis.advisor_name,
  cis.team,
  cis.lep_status,
  cis.iep_status,
  cis.term,
  cis.school_level,
  cis.gender,
  cis.ethnicity,
  cis.schoolid,
  subjects.[value] AS [subject],
  pil.lesson_id,
  pil.passed_or_not_passed,
  pil.total_time_on_lesson_min_,
  pil.completion_date,
  di.diagnostic_completion_date_most_recent_,
  di.diagnostic_overall_scale_score_most_recent_,
  di.diagnostic_overall_placement_most_recent_,
  di.diagnostic_overall_relative_placement_most_recent_,
  di.diagnostic_percentile_most_recent_,
  di.diagnostic_completion_date_1_,
  di.diagnostic_overall_scale_score_1_,
  di.diagnostic_overall_placement_1_,
  di.diagnostic_overall_relative_placement_1_,
  di.diagnostic_percentile_1_,
  di.annual_stretch_growth_measure,
  di.annual_typical_growth_measure,
  di.diagnostic_gain_note_negative_gains_zero_
FROM
  gabby.powerschool.cohort_identifiers_scaffold_current_static AS cis
  CROSS JOIN STRING_SPLIT ('Reading,Math', ',') AS subjects
  LEFT JOIN gabby.iready.personalized_instruction_by_lesson AS pil ON cis.student_number = pil.student_id
  AND cis.[date] = pil.completion_date
  AND subjects.[value] = pil.[subject]
  LEFT JOIN gabby.iready.diagnostic_and_instruction AS di ON cis.student_number = di.student_id
  AND cis.academic_year = LEFT(di.academic_year, 4)
  AND subjects.[value] = di.[subject]
WHERE
  cis.is_enrolled = 1
  AND cis.grade_level < 9
  AND cis.[date] <= CURRENT_TIMESTAMP
