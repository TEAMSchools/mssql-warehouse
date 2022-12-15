USE gabby GO
CREATE OR ALTER VIEW
  extracts.deanslist_college_admission_tests AS
SELECT
  ktc.student_number,
  st.test_type_c AS test_type,
  CONCAT(
    LEFT(DATENAME(MONTH, st.date_c), 3),
    ' ',
    DATENAME(YEAR, st.date_c)
  ) AS test_date,
  st.act_composite_c AS act_composite,
  st.act_math_c AS act_math,
  st.act_science_c AS act_science,
  st.act_english_c AS act_english,
  st.act_reading_c AS act_reading,
  st.act_writing_c AS act_writing,
  NULL AS sat_total,
  NULL AS sat_math,
  NULL AS sat_reading,
  NULL AS sat_writing,
  NULL AS sat_mc,
  NULL AS sat_essay
FROM
  gabby.alumni.standardized_test_c AS st
  LEFT JOIN gabby.alumni.ktc_roster AS ktc ON st.contact_c = ktc.sf_contact_id
WHERE
  st.test_type_c = 'ACT'
  AND st.act_composite_c IS NOT NULL
UNION ALL
SELECT
  ktc.student_number,
  st.test_type_c AS test_type,
  CONCAT(
    LEFT(DATENAME(MONTH, st.date_c), 3),
    ' ',
    DATENAME(YEAR, st.date_c)
  ) AS test_date,
  NULL AS act_composite,
  NULL AS act_math,
  NULL AS act_science,
  NULL AS act_english,
  NULL AS act_reading,
  NULL AS act_writing,
  st.sat_total_score_c AS sat_total,
  COALESCE(st.sat_math_c, st.sat_math_pre_2016_c) AS sat_math,
  COALESCE(
    st.sat_ebrw_c,
    st.sat_verbal_c,
    st.sat_critical_reading_pre_2016_c
  ) AS sat_reading,
  COALESCE(st.sat_writing_c, st.sat_writing_pre_2016_c) AS sat_writing,
  NULL AS sat_mc,
  NULL AS sat_essay
FROM
  gabby.alumni.standardized_test_c AS st
  LEFT JOIN gabby.alumni.ktc_roster AS ktc ON st.contact_c = ktc.sf_contact_id
WHERE
  st.sat_total_score_c IS NOT NULL
  AND st.test_type_c = 'SAT'
