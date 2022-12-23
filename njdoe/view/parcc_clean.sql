CREATE OR ALTER VIEW
  njdoe.parcc_clean AS
SELECT
  academic_year,
  COALESCE(test_session, test_season) AS test_session,
  UPPER(county_code) AS county_code,
  CASE
    WHEN county_name != '' THEN UPPER(county_name)
  END AS county_name,
  CASE
    WHEN district_code != '' THEN district_code
  END AS district_code,
  CASE
    WHEN district_name != '' THEN UPPER(district_name)
  END AS district_name,
  CASE
    WHEN school_code != '' THEN school_code
  END AS school_code,
  CASE
    WHEN school_name != '' THEN school_name
  END AS school_name,
  CASE
    WHEN dfg != '' THEN dfg
  END AS dfg,
  UPPER(subgroup) AS subgroup,
  UPPER(subgroup_type) AS subgroup_type,
  CASE
    WHEN test_code = 'GEO' THEN 'GEO01'
    WHEN test_code LIKE 'ELA00%' THEN REPLACE(test_code, '00', '0')
    ELSE test_code
  END AS test_code,
  CAST(
    CASE
      WHEN reg_to_test != '' THEN reg_to_test
    END AS INT
  ) AS reg_to_test,
  CAST(
    CASE
      WHEN not_tested != '' THEN not_tested
    END AS INT
  ) AS not_tested,
  valid_scores,
  mean_score,
  l_1_percent,
  l_2_percent,
  l_3_percent,
  l_4_percent,
  l_5_percent,
  (
    (l_1_percent / 100) * valid_scores
  ) AS l_1_count,
  (
    (l_2_percent / 100) * valid_scores
  ) AS l_2_count,
  (
    (l_3_percent / 100) * valid_scores
  ) AS l_3_count,
  (
    (l_4_percent / 100) * valid_scores
  ) AS l_4_count,
  (
    (l_5_percent / 100) * valid_scores
  ) AS l_5_count,
  (
    (l_4_percent / 100) * valid_scores
  ) + (
    (l_5_percent / 100) * valid_scores
  ) AS proficient_count
FROM
  gabby.njdoe.parcc
