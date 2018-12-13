USE gabby
GO

CREATE OR ALTER VIEW tntp.insight_survey_detail AS

SELECT ird.administration_year
      ,ird.administration_academic_year
      ,ird.administration_round
      
      ,ird.region_id
      ,ird.region
      ,ird.school_id
      ,ird.school
      ,ird.survey_type
      ,ird.[index]
      ,ird.variable
      ,CONVERT(FLOAT,ird.value) AS value
      ,COALESCE(ird.state_cmo, ird.region) AS state_cmo
      ,CASE
        WHEN school = 'KIPP BOLD Academy' THEN 73258
        WHEN school = 'KIPP Lanning Square Middle School' THEN 179902
        WHEN school = 'KIPP Lanning Square Primary' THEN 179901
        WHEN school = 'KIPP Life Academy' THEN 73257
        WHEN school = 'KIPP Miami Sunrise Academy' THEN 30200801
        WHEN school = 'KIPP Newark Collegiate Academy' THEN 73253
        WHEN school = 'KIPP Pathways' THEN 732574573
        WHEN school = 'KIPP Rise Academy' THEN 73252
        WHEN school = 'KIPP Seek Academy' THEN 73256
        WHEN school = 'KIPP SPARK Academy' THEN 73254
        WHEN school = 'KIPP TEAM Academy' THEN 133570965
        WHEN school = 'KIPP THRIVE Academy' THEN 73255
        WHEN school = 'KIPP Whittier Elementary' THEN 1799015075
        WHEN school = 'KIPP Whittier Middle School' THEN 179903
       END AS reporting_schoolid

      ,vars.label AS question_label

      ,vals.label AS value_label

      ,ivm.domain
      ,ivm.is_ici

      ,CASE
        WHEN ird.value IS NULL THEN NULL
        WHEN vals.label IN ('Agree','Strongly Agree') THEN 1.0
        WHEN vals.label NOT IN ('Agree','Strongly Agree') THEN 0.0
       END AS is_agree
FROM gabby.tntp.insight_raw_data ird
LEFT JOIN gabby.tntp.insight_variables vars
  ON ird.variable = vars.variable
LEFT JOIN gabby.tntp.insight_values vals
  ON ird.variable = vals.variable
 AND CONVERT(FLOAT,ird.value) = vals.value
LEFT JOIN gabby.tntp.insight_variables_metadata ivm
  ON ird.variable = ivm.variable
 AND ivm._fivetran_deleted = 0