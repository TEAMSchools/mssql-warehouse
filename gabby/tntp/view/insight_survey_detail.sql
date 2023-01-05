CREATE OR ALTER VIEW
  tntp.insight_survey_detail AS
SELECT
  ird.administration_year,
  ird.administration_academic_year,
  ird.administration_round,
  ird.region_id,
  ird.region,
  ird.school_id,
  ird.school,
  ird.survey_type,
  ird.[index],
  ird.variable,
  CAST(ird.value AS FLOAT) AS [value],
  COALESCE(ird.state_cmo, ird.region) AS state_cmo,
  CASE
    WHEN ird.school = 'KIPP BOLD Academy' THEN 73258
    WHEN ird.school = 'KIPP Lanning Square Middle School' THEN 179902
    WHEN ird.school = 'KIPP Lanning Square Primary' THEN 179901
    WHEN ird.school = 'KIPP Life Academy' THEN 73257
    WHEN ird.school = 'KIPP Miami Sunrise Academy' THEN 30200801
    WHEN ird.school = 'KIPP Newark Collegiate Academy' THEN 73253
    WHEN ird.school = 'KIPP Pathways' THEN 732574573
    WHEN ird.school = 'KIPP Rise Academy' THEN 73252
    WHEN ird.school = 'KIPP Seek Academy' THEN 73256
    WHEN ird.school = 'KIPP SPARK Academy' THEN 73254
    WHEN ird.school = 'KIPP TEAM Academy' THEN 133570965
    WHEN ird.school = 'KIPP THRIVE Academy' THEN 73255
    WHEN ird.school = 'KIPP Whittier Elementary' THEN 1799015075
    WHEN ird.school = 'KIPP Whittier Middle School' THEN 179903
  END AS reporting_schoolid,
  vars.label AS question_label,
  vals.label AS value_label,
  ivm.domain,
  ivm.is_ici,
  CASE
    WHEN ird.value IS NULL THEN NULL
    WHEN vals.label IN ('Agree', 'Strongly Agree') THEN 1.0
    WHEN vals.label NOT IN ('Agree', 'Strongly Agree') THEN 0.0
  END AS is_agree
FROM
  tntp.insight_raw_data AS ird
  LEFT JOIN tntp.insight_variables AS vars ON (ird.variable = vars.variable)
  LEFT JOIN tntp.insight_values AS vals ON (
    ird.variable = vals.variable
    AND CAST(ird.value AS FLOAT) = vals.value
  )
  LEFT JOIN tntp.insight_variables_metadata AS ivm ON (
    ird.variable = ivm.variable
    AND ivm._fivetran_deleted = 0
  )
