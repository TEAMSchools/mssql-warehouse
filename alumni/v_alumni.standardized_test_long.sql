USE gabby
GO

CREATE OR ALTER VIEW alumni.standardized_test_long AS

SELECT id
      ,contact_c
      ,date_c
      ,test_type_c AS test_type
      ,CASE WHEN subject_c <> '' THEN subject_c END AS test_subject

      ,score_type
      ,score
FROM gabby.alumni.standardized_test_c st
UNPIVOT(
  score
  FOR score_type IN (
         ap_c
        ,act_composite_c, act_english_c, act_math_c, act_reading_c, act_science_c, act_ela_c, act_stem_c, act_writing_c
        ,sat_total_score_c, sat_math_c, sat_math_pre_2016_c, sat_math_test_score_c, sat_verbal_c, sat_reading_test_score_c
        ,sat_ebrw_c, sat_critical_reading_pre_2016_c, sat_writing_c, sat_writing_pre_2016_c, sat_writing_and_language_test_score_c
        ,sat_essay_analysis_c, sat_essay_reading_c, sat_essay_writing_c
       )
 ) u
WHERE is_deleted = 0
  AND scoring_irregularity_c = 0
  AND test_type_c IN ('SAT', 'ACT', 'Advanced Placement')
