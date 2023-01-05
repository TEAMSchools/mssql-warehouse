CREATE OR ALTER VIEW
  tableau.apm_a3k_weekly AS
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
  ae.editions,
  ae.total_logins,
  ae.first_login,
  ae.last_login,
  ae.after_school_logins,
  ae.activities,
  ae.average_first_try_score,
  ae.passing_activities,
  ae.invalid_activities,
  ae.total_activities,
  ae.average_weekly_activities,
  ae.writing_assignments,
  ae.program_hours,
  ae.pre_test_date,
  ae.pre_test_reading_level,
  ae.pre_test_lexile,
  ae.last_adjustment_date,
  ae.current_reading_level,
  ae.current_lexile_level,
  ae.college_and_career_readiness_current_,
  ae.college_and_career_readiness_pre_test_,
  ae.program,
  ae.pre_test_percentile_rank,
  ae.pre_test_normal_curve_equivalent
FROM
  powerschool.cohort_identifiers_scaffold_current_static AS cis
  LEFT JOIN achieve3k.students_english AS ae ON (
    cis.student_number = ae.student_id
    AND cis.[date] = CAST(
      LEFT(RIGHT(ae._file, 22), 10) AS DATE
    )
  )
WHERE
  cis.grade_level > 8
  AND cis.is_enrolled = 1
  AND cis.[date] <= CURRENT_TIMESTAMP
