CREATE OR ALTER VIEW
  fast.student_data_long AS
WITH
  student_data AS (
    SELECT
      _file,
      _line,
      student_id,
      test_reason,
      test_completion_date,
      enrolled_grade,
      test_opp_number,
      date_taken,
      _1_number_sense_and_additive_reasoning_performance,
      _1_number_sense_and_operations_and_algebraic_reasoning_performance,
      _1_number_sense_and_operations_and_probability_performance,
      _1_number_sense_and_operations_performance,
      _1_number_sense_and_operations_with_whole_numbers_performance,
      _1_reading_prose_and_poetry_performance,
      _2_algebraic_reasoning_performance,
      _2_number_sense_and_multiplicative_reasoning_performance,
      _2_number_sense_and_operations_with_fractions_and_decimals_performance,
      _2_proportional_reasoning_and_relationships_performance,
      _2_reading_informational_text_performance,
      _3_algebraic_reasoning_performance,
      _3_fractional_reasoning_performance,
      _3_geometric_reasoning_data_analysis_and_probability_performance,
      _3_geometric_reasoning_measurement_and_data_analysis_and_probability_performance,
      _3_geometric_reasoning_performance,
      _3_linear_relationships_data_analysis_and_functions_performance,
      _3_reading_across_genres_vocabulary_performance,
      _4_data_analysis_and_probability_performance,
      _4_geometric_reasoning_measurement_and_data_analysis_and_probability_performance,
      _4_geometric_reasoning_performance,
      COALESCE(
        fast_grade_3_ela_reading_achievement_level,
        grade_3_fast_ela_reading_achievement_level
      ) AS fast_grade_3_ela_reading_achievement_level,
      COALESCE(
        fast_grade_3_mathematics_achievement_level,
        grade_3_fast_mathematics_achievement_level
      ) AS fast_grade_3_mathematics_achievement_level,
      COALESCE(
        fast_grade_4_ela_reading_achievement_level,
        grade_4_fast_ela_reading_achievement_level
      ) AS fast_grade_4_ela_reading_achievement_level,
      COALESCE(
        fast_grade_4_mathematics_achievement_level,
        grade_4_fast_mathematics_achievement_level
      ) AS fast_grade_4_mathematics_achievement_level,
      COALESCE(
        fast_grade_5_ela_reading_achievement_level,
        grade_5_fast_ela_reading_achievement_level
      ) AS fast_grade_5_ela_reading_achievement_level,
      COALESCE(
        fast_grade_5_mathematics_achievement_level,
        grade_5_fast_mathematics_achievement_level
      ) AS fast_grade_5_mathematics_achievement_level,
      COALESCE(
        fast_grade_6_ela_reading_achievement_level,
        grade_6_fast_ela_reading_achievement_level
      ) AS fast_grade_6_ela_reading_achievement_level,
      COALESCE(
        fast_grade_6_mathematics_achievement_level,
        grade_6_fast_mathematics_achievement_level
      ) AS fast_grade_6_mathematics_achievement_level,
      COALESCE(
        fast_grade_7_ela_reading_achievement_level,
        grade_7_fast_ela_reading_achievement_level
      ) AS fast_grade_7_ela_reading_achievement_level,
      COALESCE(
        fast_grade_7_mathematics_achievement_level,
        grade_7_fast_mathematics_achievement_level
      ) AS fast_grade_7_mathematics_achievement_level,
      COALESCE(
        fast_grade_8_ela_reading_achievement_level,
        grade_8_fast_ela_reading_achievement_level
      ) AS fast_grade_8_ela_reading_achievement_level,
      COALESCE(
        fast_grade_8_mathematics_achievement_level,
        grade_8_fast_mathematics_achievement_level
      ) AS fast_grade_8_mathematics_achievement_level,
      COALESCE(
        CAST(
          fast_grade_3_ela_reading_scale_score AS NVARCHAR
        ),
        CAST(
          grade_3_fast_ela_reading_scale_score AS NVARCHAR
        )
      ) AS fast_grade_3_ela_reading_scale_score,
      COALESCE(
        CAST(
          fast_grade_3_mathematics_scale_score AS NVARCHAR
        ),
        CAST(
          grade_3_fast_mathematics_scale_score AS NVARCHAR
        )
      ) AS fast_grade_3_mathematics_scale_score,
      COALESCE(
        CAST(
          fast_grade_4_ela_reading_scale_score AS NVARCHAR
        ),
        CAST(
          grade_4_fast_ela_reading_scale_score AS NVARCHAR
        )
      ) AS fast_grade_4_ela_reading_scale_score,
      COALESCE(
        CAST(
          fast_grade_4_mathematics_scale_score AS NVARCHAR
        ),
        CAST(
          grade_4_fast_mathematics_scale_score AS NVARCHAR
        )
      ) AS fast_grade_4_mathematics_scale_score,
      COALESCE(
        CAST(
          fast_grade_5_ela_reading_scale_score AS NVARCHAR
        ),
        CAST(
          grade_5_fast_ela_reading_scale_score AS NVARCHAR
        )
      ) AS fast_grade_5_ela_reading_scale_score,
      COALESCE(
        CAST(
          fast_grade_5_mathematics_scale_score AS NVARCHAR
        ),
        CAST(
          grade_5_fast_mathematics_scale_score AS NVARCHAR
        )
      ) AS fast_grade_5_mathematics_scale_score,
      COALESCE(
        CAST(
          fast_grade_6_ela_reading_scale_score AS NVARCHAR
        ),
        CAST(
          grade_6_fast_ela_reading_scale_score AS NVARCHAR
        )
      ) AS fast_grade_6_ela_reading_scale_score,
      COALESCE(
        CAST(
          fast_grade_6_mathematics_scale_score AS NVARCHAR
        ),
        CAST(
          grade_6_fast_mathematics_scale_score AS NVARCHAR
        )
      ) AS fast_grade_6_mathematics_scale_score,
      COALESCE(
        CAST(
          fast_grade_7_ela_reading_scale_score AS NVARCHAR
        ),
        CAST(
          grade_7_fast_ela_reading_scale_score AS NVARCHAR
        )
      ) AS fast_grade_7_ela_reading_scale_score,
      COALESCE(
        CAST(
          fast_grade_7_mathematics_scale_score AS NVARCHAR
        ),
        CAST(
          grade_7_fast_mathematics_scale_score AS NVARCHAR
        )
      ) AS fast_grade_7_mathematics_scale_score,
      COALESCE(
        CAST(
          fast_grade_8_ela_reading_scale_score AS NVARCHAR
        ),
        CAST(
          grade_8_fast_ela_reading_scale_score AS NVARCHAR
        )
      ) AS fast_grade_8_ela_reading_scale_score,
      COALESCE(
        CAST(
          fast_grade_8_mathematics_scale_score AS NVARCHAR
        ),
        CAST(
          grade_8_fast_mathematics_scale_score AS NVARCHAR
        )
      ) AS fast_grade_8_mathematics_scale_score,
      gabby.utilities.DATE_TO_SY (test_completion_date) AS academic_year,
      (
        CASE
          WHEN CHARINDEX('ELAReading', _file) > 0 THEN 'ELA'
          WHEN CHARINDEX('Mathematics', _file) > 0 THEN 'MATH'
          ELSE ''
        END
      ) + ' ' + CAST(
        (
          CASE
            WHEN CHARINDEX('Grade3', _file) > 0 THEN 3
            WHEN CHARINDEX('Grade4', _file) > 0 THEN 4
            WHEN CHARINDEX('Grade5', _file) > 0 THEN 5
            WHEN CHARINDEX('Grade6', _file) > 0 THEN 6
            WHEN CHARINDEX('Grade7', _file) > 0 THEN 7
            WHEN CHARINDEX('Grade8', _file) > 0 THEN 8
            ELSE 0
          END
        ) AS VARCHAR(10)
      ) AS fast_test,
      CASE
        WHEN CHARINDEX('ELAReading', _file) > 0 THEN 'Reading'
        WHEN CHARINDEX('Math', _file) > 0 THEN 'Math'
      END AS fast_subject
    FROM
      fast.student_data
  ),
  domain_mastery AS (
    SELECT
      _file,
      _line,
      mastery_indicator,
      REPLACE(
        REPLACE(
          SUBSTRING(
            standard_domain,
            CHARINDEX('_', standard_domain) + 3,
            LEN(standard_domain)
          ),
          '_performance',
          ''
        ),
        '_',
        ' '
      ) AS standard_domain
    FROM
      student_data UNPIVOT (
        mastery_indicator FOR standard_domain IN (
          _4_geometric_reasoning_performance,
          -- trunk-ignore(sqlfluff/LT05)
          _4_geometric_reasoning_measurement_and_data_analysis_and_probability_performance,
          _4_data_analysis_and_probability_performance,
          _3_reading_across_genres_vocabulary_performance,
          _3_linear_relationships_data_analysis_and_functions_performance,
          _3_geometric_reasoning_performance,
          -- trunk-ignore(sqlfluff/LT05)
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
      ) AS u
  ),
  scale_scores AS (
    SELECT
      _file,
      _line,
      scale_score_type,
      scale_score
    FROM
      student_data UNPIVOT (
        scale_score FOR scale_score_type IN (
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
      ) AS u
  ),
  achievement_levels AS (
    SELECT
      _file,
      _line,
      achievement_level_type,
      achievement_level,
      RIGHT(achievement_level, 1) AS achievement_level_numeric
    FROM
      student_data UNPIVOT (
        achievement_level FOR achievement_level_type IN (
          fast_grade_3_ela_reading_achievement_level,
          fast_grade_3_mathematics_achievement_level,
          fast_grade_4_ela_reading_achievement_level,
          fast_grade_4_mathematics_achievement_level,
          fast_grade_5_ela_reading_achievement_level,
          fast_grade_5_mathematics_achievement_level,
          fast_grade_6_ela_reading_achievement_level,
          fast_grade_6_mathematics_achievement_level,
          fast_grade_7_ela_reading_achievement_level,
          fast_grade_7_mathematics_achievement_level,
          fast_grade_8_ela_reading_achievement_level,
          fast_grade_8_mathematics_achievement_level
        )
      ) AS u
  )
SELECT
  sd.student_id AS fleid,
  sd.test_reason AS pm_round,
  sd.academic_year,
  sd.date_taken,
  sd.test_completion_date,
  sd.fast_test,
  sd.fast_subject,
  sd.enrolled_grade,
  dm.standard_domain,
  dm.mastery_indicator,
  ss.scale_score,
  al.achievement_level,
  ROW_NUMBER() OVER (
    PARTITION BY
      sd.student_id,
      sd.test_reason,
      sd.fast_test
    ORDER BY
      dm.standard_domain
  ) AS rn_test
FROM
  student_data AS sd
  LEFT JOIN domain_mastery AS dm ON (
    sd._file = dm._file
    AND sd._line = dm._line
  )
  LEFT JOIN scale_scores AS ss ON (
    sd._file = ss._file
    AND sd._line = ss._line
  )
  LEFT JOIN achievement_levels AS al ON (
    sd._file = al._file
    AND sd._line = al._line
  )
