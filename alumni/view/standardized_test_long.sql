USE gabby GO
CREATE OR ALTER VIEW
  alumni.standardized_test_long AS
SELECT
  id,
  contact_c,
  date_c,
  test_type_c AS test_type,
  CASE
    WHEN score_type = 'ap_c' THEN subject_c
    WHEN score_type = 'act_composite_c' THEN 'Composite'
    WHEN score_type = 'sat_total_score_c' THEN 'Total'
    WHEN score_type = 'act_ela_c' THEN 'ELA'
    WHEN score_type = 'act_english_c' THEN 'English'
    WHEN score_type = 'act_math_c' THEN 'Math'
    WHEN score_type = 'act_reading_c' THEN 'Reading'
    WHEN score_type = 'act_science_c' THEN 'Science'
    WHEN score_type = 'act_stem_c' THEN 'STEM'
    WHEN score_type = 'act_writing_c' THEN 'Writing'
    WHEN score_type = 'sat_math_c' THEN 'Math'
    WHEN score_type = 'sat_ebrw_c' THEN 'EBRW'
    WHEN score_type = 'sat_essay_analysis_c' THEN 'Essay Analysis'
    WHEN score_type = 'sat_essay_reading_c' THEN 'Essay Reading'
    WHEN score_type = 'sat_essay_writing_c' THEN 'Essay Writing'
    WHEN score_type = 'sat_math_test_score_c' THEN 'Math Subscore'
    WHEN score_type = 'sat_reading_test_score_c' THEN 'Reading Subscore'
    WHEN score_type = 'sat_writing_and_language_test_score_c' THEN 'Writing and Language Subscore'
    WHEN score_type = 'sat_math_pre_2016_c' THEN 'Math'
    WHEN score_type = 'sat_critical_reading_pre_2016_c' THEN 'Reading'
    WHEN score_type = 'sat_writing_pre_2016_c' THEN 'Writing'
    WHEN score_type = 'sat_verbal_c' THEN 'Verbal'
    WHEN score_type = 'sat_writing_c' THEN 'Writing'
    ELSE subject_c
  END AS test_subject,
  score_type,
  score
FROM
  gabby.alumni.standardized_test_c st UNPIVOT (
    score FOR score_type IN (
      ap_c,
      act_composite_c,
      act_english_c,
      act_math_c,
      act_reading_c,
      act_science_c,
      act_ela_c,
      act_stem_c,
      act_writing_c,
      sat_total_score_c,
      sat_math_c,
      sat_math_pre_2016_c,
      sat_math_test_score_c,
      sat_verbal_c,
      sat_reading_test_score_c,
      sat_ebrw_c,
      sat_critical_reading_pre_2016_c,
      sat_writing_c,
      sat_writing_pre_2016_c,
      sat_writing_and_language_test_score_c,
      sat_essay_analysis_c,
      sat_essay_reading_c,
      sat_essay_writing_c
    )
  ) u
WHERE
  is_deleted = 0
  AND scoring_irregularity_c = 0
  AND test_type_c IN ('SAT', 'ACT', 'Advanced Placement')
