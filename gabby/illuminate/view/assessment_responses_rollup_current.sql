CREATE OR ALTER VIEW
  illuminate_dna_assessments.assessment_responses_rollup_current AS
SELECT
  student_id,
  academic_year,
  scope,
  subject_area,
  module_type,
  module_number,
  is_replacement,
  response_type,
  standard_id,
  standard_code,
  standard_description,
  domain_description,
  CASE
    WHEN is_replacement = 0 THEN MIN(title) OVER (
      PARTITION BY
        academic_year,
        scope,
        subject_area,
        module_number,
        grade_level_id,
        is_replacement
    )
    ELSE title
  END AS title,
  CASE
    WHEN is_replacement = 0 THEN MIN(assessment_id) OVER (
      PARTITION BY
        academic_year,
        scope,
        subject_area,
        module_number,
        grade_level_id,
        is_replacement
    )
    ELSE assessment_id
  END AS assessment_id,
  CASE
    WHEN is_replacement = 0 THEN MIN(administered_at) OVER (
      PARTITION BY
        academic_year,
        scope,
        subject_area,
        module_number,
        grade_level_id,
        is_replacement
    )
    ELSE administered_at
  END AS administered_at,
  CASE
    WHEN is_replacement = 0 THEN MIN(performance_band_set_id) OVER (
      PARTITION BY
        academic_year,
        scope,
        subject_area,
        module_number,
        grade_level_id,
        response_type,
        standard_id,
        is_replacement
    )
    ELSE performance_band_set_id
  END AS performance_band_set_id,
  date_taken,
  points,
  percent_correct
FROM
  (
    SELECT
      student_id,
      academic_year,
      scope,
      subject_area,
      module_type,
      module_number,
      is_replacement,
      response_type,
      standard_id,
      standard_code,
      standard_description,
      domain_description,
      MIN(title) AS title,
      MIN(assessment_id) AS assessment_id,
      MIN(administered_at) AS administered_at,
      MIN(performance_band_set_id) AS performance_band_set_id,
      MIN(date_taken) AS date_taken,
      MIN(grade_level_id) AS grade_level_id,
      SUM(points) AS points,
      ROUND(
        (
          SUM(points) / SUM(points_possible)
        ) * 100,
        1
      ) AS percent_correct
    FROM
      illuminate_dna_assessments.assessment_responses_long
    WHERE
      is_normed_scope = 1
      AND academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
    GROUP BY
      student_id,
      academic_year,
      scope,
      subject_area,
      module_type,
      module_number,
      is_replacement,
      response_type,
      standard_id,
      standard_code,
      standard_description,
      domain_description
  ) AS sub
