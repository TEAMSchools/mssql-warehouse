CREATE OR ALTER VIEW
  illuminate_dna_assessments.agg_student_responses_all_current AS
WITH
  response_rollup AS (
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
      title,
      assessment_id,
      administered_at,
      performance_band_set_id,
      date_taken,
      points,
      percent_correct,
      1 AS is_normed_scope
    FROM
      gabby.illuminate_dna_assessments.assessment_responses_rollup_current_static
    UNION ALL
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
      title,
      assessment_id,
      administered_at,
      performance_band_set_id,
      date_taken,
      points,
      percent_correct,
      0 AS is_normed_scope
    FROM
      gabby.illuminate_dna_assessments.assessment_responses_long
    WHERE
      is_normed_scope = 0
      AND academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  )
SELECT
  rr.assessment_id,
  rr.academic_year,
  rr.administered_at,
  rr.date_taken,
  rr.response_type,
  rr.standard_id,
  rr.points,
  rr.percent_correct,
  rr.is_replacement,
  rr.standard_code,
  rr.standard_description,
  rr.domain_description,
  rr.performance_band_set_id,
  rr.is_normed_scope,
  pbl.label_number AS performance_band_number,
  pbl.[label] AS performance_band_label,
  pbl.is_mastery,
  CAST(rr.title AS VARCHAR(250)) AS title,
  CAST(rr.scope AS VARCHAR(125)) AS scope,
  CAST(rr.subject_area AS VARCHAR(125)) AS subject_area,
  CAST(rr.module_type AS VARCHAR(25)) AS module_type,
  CAST(rr.module_number AS VARCHAR(5)) AS module_number,
  CAST(s.local_student_id AS INT) AS local_student_id,
  CAST(rta.alt_name AS VARCHAR(5)) AS term_administered,
  CAST(rtt.alt_name AS VARCHAR(5)) AS term_taken
FROM
  response_rollup AS rr
  INNER JOIN gabby.illuminate_public.students AS s ON rr.student_id = s.student_id
  LEFT JOIN gabby.illuminate_dna_assessments.performance_band_lookup_static AS pbl ON rr.performance_band_set_id = pbl.performance_band_set_id
  AND (
    rr.percent_correct BETWEEN pbl.minimum_value AND pbl.maximum_value
  )
  INNER JOIN gabby.powerschool.cohort_identifiers_static AS co ON s.local_student_id = co.student_number
  AND rr.academic_year = co.academic_year
  AND co.rn_year = 1
  LEFT JOIN gabby.reporting.reporting_terms AS rta ON (
    rr.administered_at BETWEEN rta.[start_date] AND rta.end_date
  )
  AND co.schoolid = rta.schoolid
  AND rta.identifier = 'RT'
  AND rta._fivetran_deleted = 0
  LEFT JOIN gabby.reporting.reporting_terms AS rtt ON (
    rr.date_taken BETWEEN rtt.[start_date] AND rtt.end_date
  )
  AND co.schoolid = rtt.schoolid
  AND rtt.identifier = 'RT'
  AND rtt._fivetran_deleted = 0
