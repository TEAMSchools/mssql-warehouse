USE gabby
GO

CREATE OR ALTER VIEW tableau.apm_iready_weekly AS

WITH iready_lessons AS (

SELECT pil.student_id
      ,pil.lesson_id
      ,pil.passed_or_not_passed
      ,pil.[subject]
      ,pil.total_time_on_lesson_min_
      ,pil.completion_date

FROM gabby.iready.personalized_instruction_by_lesson pil

WHERE LEFT(pil.academic_year,4) = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

)

,iready_diagnostic_recent AS (

SELECT di.student_id
      ,di.[subject]
      ,di.diagnostic_completion_date_most_recent_
      ,di.diagnostic_overall_scale_score_most_recent_
      ,di.diagnostic_overall_placement_most_recent_
      ,di.diagnostic_overall_relative_placement_most_recent_
      ,di.diagnostic_percentile_most_recent_
      ,di.annual_stretch_growth_measure
      ,di.annual_typical_growth_measure
      ,di.diagnostic_gain_note_negative_gains_zero_

FROM gabby.iready.diagnostic_and_instruction di

WHERE LEFT(di.academic_year,4) = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

)

SELECT cis.student_number
      ,cis.[date]
      ,cis.lastfirst
      ,cis.grade_level
      ,cis.region
      ,cis.school_name
      ,cis.advisor_name
      ,cis.team
      ,cis.lep_status
      ,cis.iep_status
      ,cis.term
      ,cis.school_level
      ,cis.gender
      ,cis.ethnicity
      ,cis.schoolid
      ,il.lesson_id
      ,il.passed_or_not_passed
      ,'Reading' AS [subject]
      ,il.total_time_on_lesson_min_
      ,dr.diagnostic_completion_date_most_recent_
      ,dr.diagnostic_overall_scale_score_most_recent_
      ,dr.diagnostic_overall_placement_most_recent_
      ,dr.diagnostic_overall_relative_placement_most_recent_
      ,dr.diagnostic_percentile_most_recent_
      ,dr.annual_stretch_growth_measure
      ,dr.annual_typical_growth_measure
      ,dr.diagnostic_gain_note_negative_gains_zero_


FROM gabby.powerschool.cohort_identifiers_scaffold_current_static cis
LEFT JOIN iready_lessons il
  ON cis.student_number = il.student_id
 AND cis.[date] = CAST(il.completion_date AS date)
 AND il.[subject] = 'Reading'
LEFT JOIN iready_diagnostic_recent dr
  ON cis.student_number = dr.student_id
 AND dr.[subject] = 'Reading' 

WHERE cis.grade_level BETWEEN 5 AND 8
  AND cis.is_enrolled = 1
  AND cis.[date] <= GETDATE()

UNION ALL

SELECT cis.student_number
      ,cis.[date]
      ,cis.lastfirst
      ,cis.grade_level
      ,cis.region
      ,cis.school_name
      ,cis.advisor_name
      ,cis.team
      ,cis.lep_status
      ,cis.iep_status
      ,cis.term
      ,cis.school_level
      ,cis.gender
      ,cis.ethnicity
      ,cis.schoolid
      ,il.lesson_id
      ,il.passed_or_not_passed
      ,'Math' AS [subject]
      ,il.total_time_on_lesson_min_
      ,dr.diagnostic_completion_date_most_recent_
      ,dr.diagnostic_overall_scale_score_most_recent_
      ,dr.diagnostic_overall_placement_most_recent_
      ,dr.diagnostic_overall_relative_placement_most_recent_
      ,dr.diagnostic_percentile_most_recent_
      ,dr.annual_stretch_growth_measure
      ,dr.annual_typical_growth_measure
      ,dr.diagnostic_gain_note_negative_gains_zero_

FROM gabby.powerschool.cohort_identifiers_scaffold_current_static cis
LEFT JOIN iready_lessons il
  ON cis.student_number = il.student_id
 AND cis.[date] = CAST(il.completion_date AS date)
 AND il.[subject] = 'Math'
LEFT JOIN iready_diagnostic_recent dr
  ON cis.student_number = dr.student_id
 AND dr.[subject] = 'Math' 

WHERE cis.grade_level BETWEEN 0 AND 8
  AND cis.is_enrolled = 1
  AND cis.[date] <= GETDATE()
