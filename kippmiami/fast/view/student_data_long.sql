CREATE OR ALTER VIEW
  fast.student_data_long AS
SELECT
    sub2.fleid,
    sub2.pm_round,
    sub2.academic_year,
    sub2.date_taken,
    sub2.test_completion_date,
    sub2.fast_test,
    sub2.fast_subject,
    sub2.enrolled_grade,
    REPLACE(
        REPLACE(
            SUBSTRING(
                sub2.standard_domain,
                CHARINDEX('_', sub2.standard_domain) + 3,
                LEN(sub2.standard_domain)
            ),
            '_performance',
            ''
        ),
        '_',
        ' '
    ) AS standard_domain,
    sub2.mastery_indicator,
    sub2.scale_score,
    sub2.achievement_level,
    RIGHT(sub2.achievement_level, 1) AS achievement_level_numeric,
    ROW_NUMBER() OVER (
        PARTITION BY sub2.fleid,
        sub2.pm_round,
        sub2.academic_year,
        sub2.fast_test
        ORDER BY
            sub2.standard_domain
    ) AS rn_test
FROM
    (
        SELECT
            student_id AS fleid,
            test_reason AS pm_round,
            gabby.utilities.DATE_TO_SY(test_completion_date) AS academic_year,
            date_taken,
            test_completion_date,
            CASE WHEN CHARINDEX('ELAReading', _file) > 0 THEN 'ELA ' + CAST (
                SUBSTRING (
                    _file,
                    CHARINDEX('FASTGrade', _file) + 9,
                    1
                ) AS VARCHAR(10)
            ) WHEN CHARINDEX('Math', _file) > 0 THEN 'MATH ' + CAST (
                SUBSTRING (
                    _file,
                    CHARINDEX('FASTGrade', _file) + 9,
                    1
                ) AS VARCHAR(10)
            ) ELSE NULL END AS fast_test,
            CASE WHEN CHARINDEX('ELAReading', _file) > 0 THEN 'Reading' WHEN CHARINDEX('Math', _file) > 0 THEN 'Math' ELSE NULL END AS fast_subject,
            enrolled_grade,
            [standard_domain],
            [mastery_indicator],
            [scale_score],
            [achievement_level]
        FROM
            (
                SELECT
                    student_id,
                    test_reason,
                    test_completion_date,
                    _file,
                    enrolled_grade,
                    test_opp_number,
                    date_taken,
                    _4_geometric_reasoning_performance,
                    _4_geometric_reasoning_measurement_and_data_analysis_and_probability_performance,
                    _4_data_analysis_and_probability_performance,
                    _3_reading_across_genres_vocabulary_performance,
                    _3_linear_relationships_data_analysis_and_functions_performance,
                    _3_geometric_reasoning_performance,
                    _3_geometric_reasoning_measurement_and_data_analysis_and_probability_performance,
                    _3_geometric_reasoning_data_analysis_and_probability_performance,
                    _3_fractional_reasoning_performance,
                    _3_algebraic_reasoning_performance,
                    _2_reading_informational_text_performance,
                    _2_proportional_reasoning_and_relationships_performance,
                    _2_number_sense_and_operations_with_fractions_and_decimals_performance,
                    _2_number_sense_and_multiplicative_reasoning_performance,
                    _2_algebraic_reasoning_performance,
                    _1_reading_prose_and_poetry_performance,
                    _1_number_sense_and_operations_with_whole_numbers_performance,
                    _1_number_sense_and_operations_performance,
                    _1_number_sense_and_operations_and_probability_performance,
                    _1_number_sense_and_operations_and_algebraic_reasoning_performance,
                    _1_number_sense_and_additive_reasoning_performance,
                    CAST (
                        fast_grade_8_mathematics_scale_score AS NVARCHAR
                    ) AS fast_grade_8_mathematics_scale_score,
                    CAST (
                        fast_grade_8_ela_reading_scale_score AS NVARCHAR
                    ) AS fast_grade_8_ela_reading_scale_score,
                    CAST (
                        fast_grade_7_mathematics_scale_score AS NVARCHAR
                    ) AS fast_grade_7_mathematics_scale_score,
                    CAST (
                        fast_grade_7_ela_reading_scale_score AS NVARCHAR
                    ) AS fast_grade_7_ela_reading_scale_score,
                    CAST (
                        fast_grade_6_mathematics_scale_score AS NVARCHAR
                    ) AS fast_grade_6_mathematics_scale_score,
                    CAST (
                        fast_grade_6_ela_reading_scale_score AS NVARCHAR
                    ) AS fast_grade_6_ela_reading_scale_score,
                    CAST (
                        fast_grade_5_mathematics_scale_score AS NVARCHAR
                    ) AS fast_grade_5_mathematics_scale_score,
                    CAST (
                        fast_grade_5_ela_reading_scale_score AS NVARCHAR
                    ) AS fast_grade_5_ela_reading_scale_score,
                    CAST (
                        fast_grade_4_mathematics_scale_score AS NVARCHAR
                    ) AS fast_grade_4_mathematics_scale_score,
                    CAST (
                        fast_grade_4_ela_reading_scale_score AS NVARCHAR
                    ) AS fast_grade_4_ela_reading_scale_score,
                    CAST (
                        fast_grade_3_mathematics_scale_score AS NVARCHAR
                    ) AS fast_grade_3_mathematics_scale_score,
                    CAST (
                        fast_grade_3_ela_reading_scale_score AS NVARCHAR
                    ) AS fast_grade_3_ela_reading_scale_score,
                    fast_grade_8_mathematics_achievement_level,
                    fast_grade_8_ela_reading_achievement_level,
                    fast_grade_7_mathematics_achievement_level,
                    fast_grade_7_ela_reading_achievement_level,
                    fast_grade_6_mathematics_achievement_level,
                    fast_grade_6_ela_reading_achievement_level,
                    fast_grade_5_mathematics_achievement_level,
                    fast_grade_5_ela_reading_achievement_level,
                    fast_grade_4_mathematics_achievement_level,
                    fast_grade_4_ela_reading_achievement_level,
                    fast_grade_3_mathematics_achievement_level,
                    fast_grade_3_ela_reading_achievement_level
                FROM
                    kippmiami.fast.student_data
            ) AS sub1 UNPIVOT (
                [mastery_indicator] FOR [standard_domain] IN (
                    _4_geometric_reasoning_performance,
                    _4_geometric_reasoning_measurement_and_data_analysis_and_probability_performance,
                    _4_data_analysis_and_probability_performance,
                    _3_reading_across_genres_vocabulary_performance,
                    _3_linear_relationships_data_analysis_and_functions_performance,
                    _3_geometric_reasoning_performance,
                    _3_geometric_reasoning_measurement_and_data_analysis_and_probability_performance,
                    _3_geometric_reasoning_data_analysis_and_probability_performance,
                    _3_fractional_reasoning_performance,
                    _3_algebraic_reasoning_performance,
                    _2_reading_informational_text_performance,
                    _2_proportional_reasoning_and_relationships_performance,
                    _2_number_sense_and_operations_with_fractions_and_decimals_performance,
                    _2_number_sense_and_multiplicative_reasoning_performance,
                    _2_algebraic_reasoning_performance,
                    _1_reading_prose_and_poetry_performance,
                    _1_number_sense_and_operations_with_whole_numbers_performance,
                    _1_number_sense_and_operations_performance,
                    _1_number_sense_and_operations_and_probability_performance,
                    _1_number_sense_and_operations_and_algebraic_reasoning_performance,
                    _1_number_sense_and_additive_reasoning_performance
                )
            ) AS up1 UNPIVOT (
                [scale_score] FOR [scale_score_type] IN (
                    fast_grade_8_mathematics_scale_score,
                    fast_grade_8_ela_reading_scale_score,
                    fast_grade_7_mathematics_scale_score,
                    fast_grade_7_ela_reading_scale_score,
                    fast_grade_6_mathematics_scale_score,
                    fast_grade_6_ela_reading_scale_score,
                    fast_grade_5_mathematics_scale_score,
                    fast_grade_5_ela_reading_scale_score,
                    fast_grade_4_mathematics_scale_score,
                    fast_grade_4_ela_reading_scale_score,
                    fast_grade_3_mathematics_scale_score,
                    fast_grade_3_ela_reading_scale_score
                )
            ) AS up2 UNPIVOT (
                [achievement_level] FOR [achievement_level_type] IN (
                    fast_grade_8_mathematics_achievement_level,
                    fast_grade_8_ela_reading_achievement_level,
                    fast_grade_7_mathematics_achievement_level,
                    fast_grade_7_ela_reading_achievement_level,
                    fast_grade_6_mathematics_achievement_level,
                    fast_grade_6_ela_reading_achievement_level,
                    fast_grade_5_mathematics_achievement_level,
                    fast_grade_5_ela_reading_achievement_level,
                    fast_grade_4_mathematics_achievement_level,
                    fast_grade_4_ela_reading_achievement_level,
                    fast_grade_3_mathematics_achievement_level,
                    fast_grade_3_ela_reading_achievement_level
                )
            ) AS up3
    ) sub2