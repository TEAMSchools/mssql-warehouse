USE gabby
GO

CREATE OR ALTER VIEW nwea.assessment_result_identifiers AS

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
      ,sub.percentile_2008_norms
      ,sub.percentile_2011_norms
      ,sub.percentile_2015_norms
      ,sub.rn_term_subj

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
FROM
    (
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

           ,norms_2008.student_percentile AS percentile_2008_norms
           ,norms_2011.student_percentile AS percentile_2011_norms
           ,norms_2015.student_percentile AS percentile_2015_norms

           ,CONVERT(INT,ROW_NUMBER() OVER(
              PARTITION BY sub.student_id, sub.term_name, sub.measurement_scale
                ORDER BY sub.growth_measure_yn DESC
                        ,test_start_date DESC
                        ,test_standard_error)) AS rn_term_subj
     FROM
         (
          SELECT CONVERT(INT,student_id) AS student_id
                ,CONVERT(VARCHAR(25),term_name) AS term_name
                ,CONVERT(INT,test_duration_minutes) AS test_duration_minutes
                ,CONVERT(INT,test_id) AS test_id
                ,CONVERT(VARCHAR(125),test_name) AS test_name
                ,test_percentile
                ,CONVERT(INT,test_ritscore) AS test_ritscore
                ,test_standard_error
                ,CONVERT(DATE,test_start_date) AS test_start_date
                ,CONVERT(TIME,test_start_time) AS test_start_time
                ,CONVERT(VARCHAR(25),test_type) AS test_type
                ,CONVERT(VARCHAR(25),discipline) AS discipline
                ,growth_measure_yn           
                ,CONVERT(INT,norms_reference_data) AS norms_reference_data
                ,CONVERT(FLOAT,percent_correct) AS percent_correct
                ,CONVERT(VARCHAR(125),school_name) AS school_name
                ,fall_to_fall_conditional_growth_index
                ,fall_to_fall_conditional_growth_percentile
                ,CONVERT(VARCHAR(25),fall_to_fall_met_projected_growth) AS fall_to_fall_met_projected_growth
                ,fall_to_fall_observed_growth
                ,fall_to_fall_observed_growth_se
                ,fall_to_fall_projected_growth
                ,fall_to_spring_conditional_growth_index
                ,fall_to_spring_conditional_growth_percentile
                ,CONVERT(VARCHAR(25),fall_to_spring_met_projected_growth) AS fall_to_spring_met_projected_growth
                ,fall_to_spring_observed_growth
                ,fall_to_spring_observed_growth_se
                ,fall_to_spring_projected_growth
                ,fall_to_winter_conditional_growth_index
                ,fall_to_winter_conditional_growth_percentile
                ,CONVERT(VARCHAR(25),fall_to_winter_met_projected_growth) AS fall_to_winter_met_projected_growth
                ,fall_to_winter_observed_growth
                ,fall_to_winter_observed_growth_se
                ,fall_to_winter_projected_growth
                ,CONVERT(VARCHAR(25),goal_1_adjective) AS goal_1_adjective
                ,CONVERT(VARCHAR(50),goal_1_name) AS goal_1_name
                ,CONVERT(VARCHAR(25),goal_1_range) AS goal_1_range
                ,goal_1_rit_score
                ,goal_1_std_err
                ,CONVERT(VARCHAR(25),goal_2_adjective) AS goal_2_adjective
                ,CONVERT(VARCHAR(50),goal_2_name) AS goal_2_name
                ,CONVERT(VARCHAR(25),goal_2_range) AS goal_2_range
                ,goal_2_rit_score
                ,goal_2_std_err
                ,CONVERT(VARCHAR(25),goal_3_adjective) AS goal_3_adjective
                ,CONVERT(VARCHAR(50),goal_3_name) AS goal_3_name
                ,CONVERT(VARCHAR(25),goal_3_range) AS goal_3_range
                ,goal_3_rit_score
                ,goal_3_std_err
                ,CONVERT(VARCHAR(25),goal_4_adjective) AS goal_4_adjective
                ,CONVERT(VARCHAR(50),goal_4_name) AS goal_4_name
                ,CONVERT(VARCHAR(25),goal_4_range) AS goal_4_range
                ,goal_4_rit_score
                ,goal_4_std_err
                ,CONVERT(VARCHAR(25),goal_5_adjective) AS goal_5_adjective
                ,CONVERT(VARCHAR(50),goal_5_name) AS goal_5_name
                ,CONVERT(VARCHAR(25),goal_5_range) AS goal_5_range
                ,goal_5_rit_score
                ,goal_5_std_err
                ,CONVERT(VARCHAR(25),goal_6_adjective) AS goal_6_adjective
                ,CONVERT(VARCHAR(50),goal_6_name) AS goal_6_name
                ,CONVERT(VARCHAR(25),goal_6_range) AS goal_6_range
                ,goal_6_rit_score
                ,goal_6_std_err
                ,CONVERT(VARCHAR(25),projected_proficiency_level_1) AS projected_proficiency_level_1
                ,CONVERT(VARCHAR(25),projected_proficiency_level_2) AS projected_proficiency_level_2
                ,CONVERT(VARCHAR(25),projected_proficiency_level_3) AS projected_proficiency_level_3
                ,CONVERT(VARCHAR(125),projected_proficiency_study_1) AS projected_proficiency_study_1
                ,CONVERT(VARCHAR(125),projected_proficiency_study_2) AS projected_proficiency_study_2
                ,CONVERT(VARCHAR(125),projected_proficiency_study_3) AS projected_proficiency_study_3
                ,CONVERT(VARCHAR(5),ritto_reading_max) AS ritto_reading_max
                ,CONVERT(VARCHAR(5),ritto_reading_min) AS ritto_reading_min
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
                ,CONVERT(FLOAT,wiselected_ayspring) AS wiselected_ayspring
                ,wiselected_aywinter

                ,CONVERT(INT,SUBSTRING(term_name, CHARINDEX('-', term_name) - 4, 4)) AS academic_year
                ,CASE
                  WHEN term_name LIKE 'Fall%' THEN CONVERT(INT,SUBSTRING(term_name, (CHARINDEX('-', term_name) - 4), 4))
                  ELSE CONVERT(INT,SUBSTRING(term_name, (CHARINDEX('-', term_name) + 1), 4))
                 END AS test_year                      
                ,CONVERT(VARCHAR(25),LEFT(term_name, (CHARINDEX(' ', term_name) - 1))) AS term
                ,CASE
                  WHEN LEFT(term_name, CHARINDEX(' ', term_name) - 1) = 'Fall'   THEN 1 
                  WHEN LEFT(term_name, CHARINDEX(' ', term_name) - 1) = 'Winter' THEN 2
                  WHEN LEFT(term_name, CHARINDEX(' ', term_name) - 1) = 'Spring' THEN 3
                  ELSE NULL
                 END term_numeric      
                ,CASE WHEN measurement_scale LIKE 'Language%' THEN 'Language Usage' ELSE CONVERT(VARCHAR(125),measurement_scale) END AS measurement_scale            
                ,CASE
                  WHEN ritto_reading_score IN ('BR','<100') THEN 0
                  WHEN ISNUMERIC(ritto_reading_score) = 0 THEN CONVERT(FLOAT,REPLACE(REPLACE(ritto_reading_score, 'L', ''), 'BR', ''))
                  ELSE CONVERT(FLOAT,ritto_reading_score) 
                 END AS ritto_reading_score
          FROM gabby.nwea.assessment_results
         ) sub
     JOIN gabby.powerschool.cohort_identifiers_static co
       ON sub.student_id = co.student_number
      AND sub.academic_year = co.academic_year
      AND co.rn_year = 1
     LEFT JOIN gabby.nwea.percentile_norms norms_2008
       ON co.grade_level = norms_2008.grade_level
      AND sub.measurement_scale = norms_2008.measurementscale_clean COLLATE Latin1_General_BIN
      AND sub.test_ritscore = norms_2008.testritscore
      AND sub.term = norms_2008.term_clean COLLATE Latin1_General_BIN
      AND norms_2008.norms_year = 2008
     LEFT JOIN gabby.nwea.percentile_norms norms_2011
       ON co.grade_level = norms_2011.grade_level
      AND sub.measurement_scale = norms_2011.measurementscale_clean COLLATE Latin1_General_BIN
      AND sub.test_ritscore = norms_2011.testritscore
      AND sub.term = norms_2011.term_clean COLLATE Latin1_General_BIN
      AND norms_2011.norms_year = 2011
     LEFT JOIN gabby.nwea.percentile_norms norms_2015
       ON co.grade_level = norms_2015.grade_level
      AND sub.measurement_scale = norms_2015.measurementscale_clean COLLATE Latin1_General_BIN
      AND sub.test_ritscore = norms_2015.testritscore
      AND sub.term = norms_2015.term_clean COLLATE Latin1_General_BIN
      AND norms_2015.norms_year = 2015
     ) sub