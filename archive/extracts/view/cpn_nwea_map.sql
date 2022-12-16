CREATE OR ALTER VIEW
  extracts.cpn_nwea_map AS
SELECT
  student_number,
  test_id,
  academic_year,
  term,
  measurementscale,
  rit AS test_rit_score,
  pct AS test_percentile,
  lexile_score AS test_lexile_score,
  testdurationminutes
FROM
  gabby.tableau.map_tool
WHERE
  region = 'KCNA'
  AND term != 'Baseline'
  AND goal_number = 1
