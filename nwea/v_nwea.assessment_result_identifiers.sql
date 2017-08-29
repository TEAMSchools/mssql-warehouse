USE gabby
GO

ALTER VIEW nwea.assessment_result_identifiers AS

SELECT sub.student_id
      ,sub.term_name
      ,sub.test_duration_minutes
      ,sub.test_id
      ,sub.test_name
      ,sub.test_percentile
      ,sub.test_ritscore
      ,sub.test_standard_error
      ,sub.test_start_date
      ,sub.test_start_time
      ,sub.test_type
      ,sub.discipline
      ,sub.growth_measure_yn
      ,sub.norms_reference_data
      ,sub.percent_correct
      ,sub.school_name
      ,sub.fall_to_fall_conditional_growth_index
      ,sub.fall_to_fall_conditional_growth_percentile
      ,sub.fall_to_fall_met_projected_growth
      ,sub.fall_to_fall_observed_growth
      ,sub.fall_to_fall_observed_growth_se
      ,sub.fall_to_fall_projected_growth
      ,sub.fall_to_spring_conditional_growth_index
      ,sub.fall_to_spring_conditional_growth_percentile
      ,sub.fall_to_spring_met_projected_growth
      ,sub.fall_to_spring_observed_growth
      ,sub.fall_to_spring_observed_growth_se
      ,sub.fall_to_spring_projected_growth
      ,sub.fall_to_winter_conditional_growth_index
      ,sub.fall_to_winter_conditional_growth_percentile
      ,sub.fall_to_winter_met_projected_growth
      ,sub.fall_to_winter_observed_growth
      ,sub.fall_to_winter_observed_growth_se
      ,sub.fall_to_winter_projected_growth
      ,sub.goal_1_adjective
      ,sub.goal_1_name
      ,sub.goal_1_range
      ,sub.goal_1_rit_score
      ,sub.goal_1_std_err
      ,sub.goal_2_adjective
      ,sub.goal_2_name
      ,sub.goal_2_range
      ,sub.goal_2_rit_score
      ,sub.goal_2_std_err
      ,sub.goal_3_adjective
      ,sub.goal_3_name
      ,sub.goal_3_range
      ,sub.goal_3_rit_score
      ,sub.goal_3_std_err
      ,sub.goal_4_adjective
      ,sub.goal_4_name
      ,sub.goal_4_range
      ,sub.goal_4_rit_score
      ,sub.goal_4_std_err
      ,sub.goal_5_adjective
      ,sub.goal_5_name
      ,sub.goal_5_range
      ,sub.goal_5_rit_score
      ,sub.goal_5_std_err
      ,sub.goal_6_adjective
      ,sub.goal_6_name
      ,sub.goal_6_range
      ,sub.goal_6_rit_score
      ,sub.goal_6_std_err
      ,sub.projected_proficiency_level_1
      ,sub.projected_proficiency_level_2
      ,sub.projected_proficiency_level_3
      ,sub.projected_proficiency_study_1
      ,sub.projected_proficiency_study_2
      ,sub.projected_proficiency_study_3
      ,sub.ritto_reading_max
      ,sub.ritto_reading_min
      ,sub.ritto_reading_score
      ,sub.spring_to_spring_conditional_growth_index
      ,sub.spring_to_spring_conditional_growth_percentile
      ,sub.spring_to_spring_met_projected_growth
      ,sub.spring_to_spring_observed_growth
      ,sub.spring_to_spring_observed_growth_se
      ,sub.spring_to_spring_projected_growth
      ,sub.typical_fall_to_fall_growth
      ,sub.typical_fall_to_spring_growth
      ,sub.typical_fall_to_winter_growth
      ,sub.typical_spring_to_spring_growth
      ,sub.typical_winter_to_spring_growth
      ,sub.typical_winter_to_winter_growth
      ,sub.winter_to_spring_conditional_growth_index
      ,sub.winter_to_spring_conditional_growth_percentile
      ,sub.winter_to_spring_met_projected_growth
      ,sub.winter_to_spring_observed_growth
      ,sub.winter_to_spring_observed_growth_se
      ,sub.winter_to_spring_projected_growth
      ,sub.winter_to_winter_conditional_growth_index
      ,sub.winter_to_winter_conditional_growth_percentile
      ,sub.winter_to_winter_met_projected_growth
      ,sub.winter_to_winter_observed_growth
      ,sub.winter_to_winter_observed_growth_se
      ,sub.winter_to_winter_projected_growth
      ,sub.wiprevious_ayfall
      ,sub.wiprevious_ayspring
      ,sub.wiprevious_aywinter
      ,sub.wiselected_ayfall
      ,sub.wiselected_ayspring
      ,sub.wiselected_aywinter
      ,sub.academic_year
      ,sub.test_year
      ,sub.term
      ,sub.term_numeric
      ,sub.measurement_scale
      ,sub.rn_term_subj
      ,norms_2008.student_percentile AS percentile_2008_norms
      ,norms_2011.student_percentile AS percentile_2011_norms
      ,norms_2015.student_percentile AS percentile_2015_norms
      ,ROW_NUMBER() OVER(
         PARTITION BY sub.student_id, sub.measurement_scale
           ORDER BY sub.academic_year ASC, sub.term_numeric ASC, sub.rn_term_subj ASC, sub.test_start_date DESC, sub.test_start_time DESC) AS rn_base_all
      ,ROW_NUMBER() OVER( 
         PARTITION BY sub.student_id, sub.measurement_scale
           ORDER BY sub.academic_year DESC, sub.term_numeric DESC, sub.rn_term_subj ASC, sub.test_start_date DESC, sub.test_start_time DESC) AS rn_curr_all
      ,ROW_NUMBER() OVER(
         PARTITION BY sub.student_id, sub.measurement_scale, sub.academic_year
           ORDER BY sub.term_numeric ASC, sub.rn_term_subj ASC, sub.test_start_date DESC, sub.test_start_time DESC) AS rn_base_yr
      ,ROW_NUMBER() OVER( 
         PARTITION BY sub.student_id, sub.measurement_scale, sub.academic_year
           ORDER BY sub.term_numeric DESC, sub.rn_term_subj ASC, sub.test_start_date DESC, sub.test_start_time DESC) AS rn_curr_yr
      --,ROW_NUMBER() OVER( 
      --   PARTITION BY sub.student_id, sub.measurement_scale
      --     ORDER BY sub.academic_year ASC, sub.term_numeric ASC, sub.rn ASC, sub.test_start_date ASC, sub.test_start_time ASC) AS rn_asc
      --,CASE
      --  /* MATH ACT model */
      --  WHEN sub.measurement_scale = 'Mathematics'
      --       THEN ROUND(-28.193 -- intercept
      --                    + (0.307 * sub.test_ritscore)
      --                    + ((-4.256 * co.grade_level) + (0.183 * (co.grade_level * co.grade_level)))
      --                    + CASE
      --                       WHEN sub.term = 'Fall' THEN 0
      --                       WHEN sub.term = 'Winter' THEN -1.173 -- half of Spring
      --                       WHEN sub.term = 'Spring' THEN -2.346
      --                       ELSE NULL
      --                      END,0)
      --  /* READING ACT model */
      --  WHEN sub.measurement_scale = 'Reading'
      --       THEN ROUND(-52.748 -- intercept
      --                    + (0.417 * sub.test_ritscore)
      --                    + ((-3.433 * co.grade_level) + (0.132 * (co.grade_level * co.grade_level)))
      --                    + CASE
      --                       WHEN sub.term = 'Fall' THEN 0
      --                       WHEN sub.term = 'Winter' THEN -0.829 -- half of Spring
      --                       WHEN sub.term = 'Spring' THEN -1.655
      --                       ELSE NULL
      --                      END, 0)
      --  ELSE NULL
      -- END AS proj_ACT_subj_score
FROM
    (
     SELECT student_id
           ,term_name
           ,test_duration_minutes
           ,test_id
           ,test_name
           ,test_percentile
           ,test_ritscore
           ,test_standard_error
           ,CONVERT(DATE,test_start_date) AS test_start_date
           ,test_start_time
           ,test_type
           ,discipline
           ,growth_measure_yn
           --,measurement_scale
           ,norms_reference_data
           ,percent_correct
           ,school_name
           ,fall_to_fall_conditional_growth_index
           ,fall_to_fall_conditional_growth_percentile
           ,fall_to_fall_met_projected_growth
           ,fall_to_fall_observed_growth
           ,fall_to_fall_observed_growth_se
           ,fall_to_fall_projected_growth
           ,fall_to_spring_conditional_growth_index
           ,fall_to_spring_conditional_growth_percentile
           ,fall_to_spring_met_projected_growth
           ,fall_to_spring_observed_growth
           ,fall_to_spring_observed_growth_se
           ,fall_to_spring_projected_growth
           ,fall_to_winter_conditional_growth_index
           ,fall_to_winter_conditional_growth_percentile
           ,fall_to_winter_met_projected_growth
           ,fall_to_winter_observed_growth
           ,fall_to_winter_observed_growth_se
           ,fall_to_winter_projected_growth
           ,goal_1_adjective
           ,goal_1_name
           ,goal_1_range
           ,goal_1_rit_score
           ,goal_1_std_err
           ,goal_2_adjective
           ,goal_2_name
           ,goal_2_range
           ,goal_2_rit_score
           ,goal_2_std_err
           ,goal_3_adjective
           ,goal_3_name
           ,goal_3_range
           ,goal_3_rit_score
           ,goal_3_std_err
           ,goal_4_adjective
           ,goal_4_name
           ,goal_4_range
           ,goal_4_rit_score
           ,goal_4_std_err
           ,goal_5_adjective
           ,goal_5_name
           ,goal_5_range
           ,goal_5_rit_score
           ,goal_5_std_err
           ,goal_6_adjective
           ,goal_6_name
           ,goal_6_range
           ,goal_6_rit_score
           ,goal_6_std_err
           ,projected_proficiency_level_1
           ,projected_proficiency_level_2
           ,projected_proficiency_level_3
           ,projected_proficiency_study_1
           ,projected_proficiency_study_2
           ,projected_proficiency_study_3
           ,ritto_reading_max
           ,ritto_reading_min
           ,ritto_reading_score
           ,spring_to_spring_conditional_growth_index
           ,spring_to_spring_conditional_growth_percentile
           ,spring_to_spring_met_projected_growth
           ,spring_to_spring_observed_growth
           ,spring_to_spring_observed_growth_se
           ,spring_to_spring_projected_growth
           ,typical_fall_to_fall_growth
           ,typical_fall_to_spring_growth
           ,typical_fall_to_winter_growth
           ,typical_spring_to_spring_growth
           ,typical_winter_to_spring_growth
           ,typical_winter_to_winter_growth
           ,winter_to_spring_conditional_growth_index
           ,winter_to_spring_conditional_growth_percentile
           ,winter_to_spring_met_projected_growth
           ,winter_to_spring_observed_growth
           ,winter_to_spring_observed_growth_se
           ,winter_to_spring_projected_growth
           ,winter_to_winter_conditional_growth_index
           ,winter_to_winter_conditional_growth_percentile
           ,winter_to_winter_met_projected_growth
           ,winter_to_winter_observed_growth
           ,winter_to_winter_observed_growth_se
           ,winter_to_winter_projected_growth
           ,wiprevious_ayfall
           ,wiprevious_ayspring
           ,wiprevious_aywinter
           ,wiselected_ayfall
           ,wiselected_ayspring
           ,wiselected_aywinter

           ,CONVERT(INT,SUBSTRING(term_name, CHARINDEX('-', term_name) - 4, 4)) AS academic_year
           ,CASE
             WHEN term_name LIKE 'Fall%' THEN CONVERT(INT,SUBSTRING(term_name, (CHARINDEX('-', term_name) - 4), 4))
             ELSE CONVERT(INT,SUBSTRING(term_name, (CHARINDEX('-', term_name) + 1), 4))
            END AS test_year                      
           ,LEFT(term_name, (CHARINDEX(' ', term_name) - 1)) AS term
           ,CASE
             WHEN LEFT(term_name, CHARINDEX(' ', term_name) - 1) = 'Fall'   THEN 1 
             WHEN LEFT(term_name, CHARINDEX(' ', term_name) - 1) = 'Winter' THEN 2
             WHEN LEFT(term_name, CHARINDEX(' ', term_name) - 1) = 'Spring' THEN 3
             ELSE NULL
            END term_numeric      
           ,CASE WHEN measurement_scale LIKE 'Language%' THEN 'Language Usage' ELSE measurement_scale END AS measurement_scale            
           ,ROW_NUMBER() OVER(
              PARTITION BY student_id, term_name, measurement_scale
                ORDER BY growth_measure_yn DESC
                        ,CONVERT(DATE,test_start_date) DESC
                        ,test_standard_error ASC) AS rn_term_subj
     FROM gabby.nwea.assessmentresult
    ) sub
JOIN gabby.powerschool.cohort_identifiers_static co
  ON sub.student_id = co.student_number
 AND sub.academic_year = co.academic_year
 AND co.rn_year = 1
LEFT OUTER JOIN gabby.nwea.percentile_norms norms_2008
  ON co.grade_level = norms_2008.grade_level
 AND sub.measurement_scale = norms_2008.measurementscale
 AND sub.test_ritscore = norms_2008.testritscore
 AND sub.term = norms_2008.term
 AND norms_2008.norms_year = 2008
LEFT OUTER JOIN gabby.nwea.percentile_norms norms_2011
  ON co.grade_level = norms_2011.grade_level
 AND sub.measurement_scale = norms_2011.measurementscale
 AND sub.test_ritscore = norms_2011.testritscore
 AND sub.term = norms_2011.term
 AND norms_2011.norms_year = 2011
LEFT OUTER JOIN gabby.nwea.percentile_norms norms_2015
  ON co.grade_level = norms_2015.grade_level
 AND sub.measurement_scale = norms_2015.measurementscale
 AND sub.test_ritscore = norms_2015.testritscore
 AND sub.term = norms_2015.term
 AND norms_2015.norms_year = 2015