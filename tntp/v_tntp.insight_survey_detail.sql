USE gabby
GO

CREATE OR ALTER VIEW tntp.insight_survey_detail AS

SELECT ird.administration_year
      ,ird.administration_academic_year
      ,ird.administration_round
      ,ird.state_cmo
      ,ird.region_id
      ,ird.region
      ,ird.school_id
      ,ird.school
      ,ird.survey_type
      ,ird.[index]
      ,ird.variable
      ,CONVERT(FLOAT,ird.value) AS value

      ,vars.label AS question_label

      ,vals.label AS value_label

      ,ivm.is_ici

      ,CASE
        WHEN ird.value IS NULL THEN NULL
        WHEN vals.label IN ('Agree','Strongly Agree') THEN 1.0
        WHEN vals.label NOT IN ('Agree','Strongly Agree') THEN 0.0
       END AS is_agree
FROM gabby.tntp.insight_raw_data ird
JOIN gabby.tntp.insight_variables vars
  ON ird.variable = vars.variable
JOIN gabby.tntp.insight_values vals
  ON ird.variable = vals.variable
 AND CONVERT(FLOAT,ird.value) = vals.value
LEFT JOIN gabby.tntp.insight_variables_metadata ivm
  ON ird.variable = ivm.variable