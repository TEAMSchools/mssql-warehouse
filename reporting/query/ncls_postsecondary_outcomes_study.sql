WITH
  state_assessments AS (
    SELECT
      state_studentnumber,
      g3_math_assessment_type,
      g3_math_performance_level,
      g3_math_scaled_score,
      g4_math_assessment_type,
      g4_math_performance_level,
      g4_math_scaled_score,
      g5_math_assessment_type,
      g5_math_performance_level,
      g5_math_scaled_score,
      g6_math_assessment_type,
      g6_math_performance_level,
      g6_math_scaled_score,
      g7_math_assessment_type,
      g7_math_performance_level,
      g7_math_scaled_score,
      g8_math_assessment_type,
      g8_math_performance_level,
      g8_math_scaled_score,
      g11_math_assessment_type,
      g11_math_performance_level,
      g11_math_scaled_score,
      g12_math_assessment_type,
      g12_math_performance_level,
      g12_math_scaled_score,
      alg01_assessment_type,
      alg01_performance_level,
      alg01_scaled_score,
      geo_assessment_type,
      geo_performance_level,
      geo_scaled_score,
      alg02_assessment_type,
      alg02_performance_level,
      alg02_scaled_score,
      g3_ela_assessment_type,
      g3_ela_performance_level,
      g3_ela_scaled_score,
      g4_ela_assessment_type,
      g4_ela_performance_level,
      g4_ela_scaled_score,
      g5_ela_assessment_type,
      g5_ela_performance_level,
      g5_ela_scaled_score,
      g6_ela_assessment_type,
      g6_ela_performance_level,
      g6_ela_scaled_score,
      g7_ela_assessment_type,
      g7_ela_performance_level,
      g7_ela_scaled_score,
      g8_ela_assessment_type,
      g8_ela_performance_level,
      g8_ela_scaled_score,
      g9_ela_assessment_type,
      g9_ela_performance_level,
      g9_ela_scaled_score,
      g10_ela_assessment_type,
      g10_ela_performance_level,
      g10_ela_scaled_score,
      g11_ela_assessment_type,
      g11_ela_performance_level,
      g11_ela_scaled_score,
      g12_ela_assessment_type,
      g12_ela_performance_level,
      g12_ela_scaled_score,
      g4_science_assessment_type,
      g4_science_performance_level,
      g4_science_scaled_score,
      g8_science_assessment_type,
      g8_science_performance_level,
      g8_science_scaled_score,
      g9_science_assessment_type,
      g9_science_performance_level,
      g9_science_scaled_score,
      g10_science_assessment_type,
      g10_science_performance_level,
      g10_science_scaled_score,
      g11_science_assessment_type,
      g11_science_performance_level,
      g11_science_scaled_score,
      g12_science_assessment_type,
      g12_science_performance_level,
      g12_science_scaled_score
    FROM
      (
        SELECT
          state_studentnumber,
          CONCAT(
            CASE
              WHEN subject IN ('ALG01', 'ALG02', 'GEO') THEN subject
              ELSE CONCAT('G', grade_level, '_', subject)
            END,
            '_',
            field
          ) AS pivot_field,
          VALUE
        FROM
          (
            SELECT
              co.state_studentnumber,
              co.grade_level,
              a.subject,
              CAST(a.test_type AS NVARCHAR) AS assessment_type,
              CAST(a.performance_level AS NVARCHAR) AS performance_level,
              CAST(a.scaled_score AS NVARCHAR) AS scaled_score
            FROM
              gabby.njsmart.all_state_assessments AS a
              INNER JOIN gabby.powerschool.cohort_identifiers_static AS co ON a.local_student_id = co.student_number
              AND a.academic_year = co.academic_year
              AND co.rn_year = 1
            UNION ALL
            SELECT
              state_student_identifier,
              CASE
                WHEN LEFT(test_code, 3) IN ('ALG', 'GEO') THEN NULL
                ELSE CAST(RIGHT(test_code, 2) AS INT)
              END AS grade_level,
              CASE
                WHEN LEFT(test_code, 3) = 'ALG' THEN test_code
                WHEN LEFT(test_code, 3) = 'GEO' THEN 'GEO'
                WHEN LEFT(test_code, 3) = 'MAT' THEN 'MATH'
                ELSE LEFT(test_code, 3)
              END AS subject,
              n 'PARCC' AS assessment_type,
              CAST(test_performance_level AS NVARCHAR),
              CAST(test_scale_score AS NVARCHAR)
            FROM
              gabby.parcc.summative_record_file_clean
          ) sub UNPIVOT (
            VALUE FOR field IN (
              assessment_type,
              performance_level,
              scaled_score
            )
          ) u
      ) sub PIVOT (
        MAX(VALUE) FOR pivot_field IN (
          alg01_assessment_type,
          alg01_performance_level,
          alg01_scaled_score,
          alg02_assessment_type,
          alg02_performance_level,
          alg02_scaled_score,
          g10_ela_assessment_type,
          g10_ela_performance_level,
          g10_ela_scaled_score,
          g10_science_assessment_type,
          g10_science_performance_level,
          g10_science_scaled_score,
          g11_ela_assessment_type,
          g11_ela_performance_level,
          g11_ela_scaled_score,
          g11_math_assessment_type,
          g11_math_performance_level,
          g11_math_scaled_score,
          g11_science_assessment_type,
          g11_science_performance_level,
          g11_science_scaled_score,
          g12_ela_assessment_type,
          g12_ela_performance_level,
          g12_ela_scaled_score,
          g12_math_assessment_type,
          g12_math_performance_level,
          g12_math_scaled_score,
          g12_science_assessment_type,
          g12_science_performance_level,
          g12_science_scaled_score,
          g3_ela_assessment_type,
          g3_ela_performance_level,
          g3_ela_scaled_score,
          g3_math_assessment_type,
          g3_math_performance_level,
          g3_math_scaled_score,
          g4_ela_assessment_type,
          g4_ela_performance_level,
          g4_ela_scaled_score,
          g4_math_assessment_type,
          g4_math_performance_level,
          g4_math_scaled_score,
          g4_science_assessment_type,
          g4_science_performance_level,
          g4_science_scaled_score,
          g5_ela_assessment_type,
          g5_ela_performance_level,
          g5_ela_scaled_score,
          g5_math_assessment_type,
          g5_math_performance_level,
          g5_math_scaled_score,
          g6_ela_assessment_type,
          g6_ela_performance_level,
          g6_ela_scaled_score,
          g6_math_assessment_type,
          g6_math_performance_level,
          g6_math_scaled_score,
          g7_ela_assessment_type,
          g7_ela_performance_level,
          g7_ela_scaled_score,
          g7_math_assessment_type,
          g7_math_performance_level,
          g7_math_scaled_score,
          g8_ela_assessment_type,
          g8_ela_performance_level,
          g8_ela_scaled_score,
          g8_math_assessment_type,
          g8_math_performance_level,
          g8_math_scaled_score,
          g8_science_assessment_type,
          g8_science_performance_level,
          g8_science_scaled_score,
          g9_ela_assessment_type,
          g9_ela_performance_level,
          g9_ela_scaled_score,
          g9_science_assessment_type,
          g9_science_performance_level,
          g9_science_scaled_score,
          geo_assessment_type,
          geo_performance_level,
          geo_scaled_score
        )
      ) p
  )
SELECT
  COALESCE(
    sid.local_identification_number,
    sid2.local_identification_number
  ) AS lid,
  g.sid,
  g.first_name,
  COALESCE(sid.middle_name, sid2.middle_name) AS middle_name,
  g.last_name,
  COALESCE(
    sid.generation_code_suffix,
    sid2.generation_code_suffix
  ) AS generation_code_suffix,
  g.dob,
  g.school_name AS attending_school_name,
  g.grade_level,
  g.entering_gender,
  g.entering_race_or_ethnicity,
  g.lunch_status AS entering_lunch_status,
  g.retained_display AS retained_last_year,
  g.status,
  g.entering_special_education AS entering_special_education_classification,
  g.lepprogram_enrollment AS entering_lep_program,
  g.four_year_graduation_cohort AS x4_year_graduation_cohort,
  g.four_year_graduation_status AS x4_year_graduation_cohort_status,
  COALESCE(
    sid.resident_municipal_code,
    sid2.resident_municipal_code
  ) AS resident_municipal_code,
  COALESCE(sid.city_of_birth, sid2.city_of_birth) AS city_of_birth,
  COALESCE(sid.state_of_birth, sid2.state_of_birth) AS state_of_birth,
  COALESCE(
    sid.county_code_attending,
    sid2.county_code_attending
  ) AS county_code_attending,
  COALESCE(
    sid.district_code_attending,
    sid2.district_code_attending
  ) AS district_code_attending,
  COALESCE(
    sid.school_code_attending,
    sid2.school_code_attending
  ) AS school_code_attending,
  COALESCE(
    sid.district_entry_date,
    sid2.district_entry_date
  ) AS district_entry_date,
  COALESCE(
    sid.school_entry_date,
    sid2.school_entry_date
  ) AS school_entry_date,
  COALESCE(sid.school_exit_date, sid2.school_exit_date) AS school_exit_date,
  COALESCE(
    sid.school_exit_withdrawal_code,
    sid2.school_exit_withdrawal_code
  ) AS school_exit_withdrawal_code,
  sat.math AS sat_math_score,
  sat.verbal AS sat_test_verbal_score,
  sat.writing AS sat_test_writing_score,
  sat.all_tests_total AS sat_test_composite_score,
  act.english AS act_english_score,
  act.reading AS act_reading_score,
  act.math AS act_math_score,
  act.science AS act_science_scoe,
  act.composite AS act_composite_score,
  sa.g3_math_assessment_type,
  sa.g3_math_performance_level,
  sa.g3_math_scaled_score,
  sa.g4_math_assessment_type,
  sa.g4_math_performance_level,
  sa.g4_math_scaled_score,
  sa.g5_math_assessment_type,
  sa.g5_math_performance_level,
  sa.g5_math_scaled_score,
  sa.g6_math_assessment_type,
  sa.g6_math_performance_level,
  sa.g6_math_scaled_score,
  sa.g7_math_assessment_type,
  sa.g7_math_performance_level,
  sa.g7_math_scaled_score,
  sa.g8_math_assessment_type,
  sa.g8_math_performance_level,
  sa.g8_math_scaled_score,
  sa.g11_math_assessment_type,
  sa.g11_math_performance_level,
  sa.g11_math_scaled_score,
  sa.g12_math_assessment_type,
  sa.g12_math_performance_level,
  sa.g12_math_scaled_score,
  sa.alg01_assessment_type,
  sa.alg01_performance_level,
  sa.alg01_scaled_score,
  sa.geo_assessment_type,
  sa.geo_performance_level,
  sa.geo_scaled_score,
  sa.alg02_assessment_type,
  sa.alg02_performance_level,
  sa.alg02_scaled_score,
  sa.g3_ela_assessment_type,
  sa.g3_ela_performance_level,
  sa.g3_ela_scaled_score,
  sa.g4_ela_assessment_type,
  sa.g4_ela_performance_level,
  sa.g4_ela_scaled_score,
  sa.g5_ela_assessment_type,
  sa.g5_ela_performance_level,
  sa.g5_ela_scaled_score,
  sa.g6_ela_assessment_type,
  sa.g6_ela_performance_level,
  sa.g6_ela_scaled_score,
  sa.g7_ela_assessment_type,
  sa.g7_ela_performance_level,
  sa.g7_ela_scaled_score,
  sa.g8_ela_assessment_type,
  sa.g8_ela_performance_level,
  sa.g8_ela_scaled_score,
  sa.g9_ela_assessment_type,
  sa.g9_ela_performance_level,
  sa.g9_ela_scaled_score,
  sa.g10_ela_assessment_type,
  sa.g10_ela_performance_level,
  sa.g10_ela_scaled_score,
  sa.g11_ela_assessment_type,
  sa.g11_ela_performance_level,
  sa.g11_ela_scaled_score,
  sa.g12_ela_assessment_type,
  sa.g12_ela_performance_level,
  sa.g12_ela_scaled_score,
  sa.g4_science_assessment_type,
  sa.g4_science_performance_level,
  sa.g4_science_scaled_score,
  sa.g8_science_assessment_type,
  sa.g8_science_performance_level,
  sa.g8_science_scaled_score,
  sa.g9_science_assessment_type,
  sa.g9_science_performance_level,
  sa.g9_science_scaled_score,
  sa.g10_science_assessment_type,
  sa.g10_science_performance_level,
  sa.g10_science_scaled_score,
  sa.g11_science_assessment_type,
  sa.g11_science_performance_level,
  sa.g11_science_scaled_score,
  sa.g12_science_assessment_type,
  sa.g12_science_performance_level,
  sa.g12_science_scaled_score
FROM
  gabby.njsmart.high_school_graduation_cohort_status_profile AS g
  LEFT OUTER JOIN gabby.njsmart.sid_qsac_submission_set_records AS sid ON g.sid = sid.state_identification_number
  LEFT OUTER JOIN gabby.powerschool.students AS s ON g.sid = s.state_studentnumber
  LEFT OUTER JOIN gabby.njsmart.sid_qsac_submission_set_records AS sid2 ON s.student_number = sid2.local_identification_number
  LEFT OUTER JOIN gabby.naviance.sat_scores_clean AS sat ON COALESCE(
    sid.local_identification_number,
    sid2.local_identification_number
  ) = sat.student_number
  AND sat.rn_highest = 1
  LEFT OUTER JOIN gabby.naviance.act_scores_clean AS act ON COALESCE(
    sid.local_identification_number,
    sid2.local_identification_number
  ) = act.student_number
  AND act.rn_highest = 1
  LEFT OUTER JOIN state_assessments AS sa ON g.sid = sa.state_studentnumber
WHERE
  (
    g.four_year_graduation_cohort BETWEEN 2011 AND 2016
  )
