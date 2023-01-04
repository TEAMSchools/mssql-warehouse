CREATE OR ALTER VIEW
  extracts.deanslist_mod_standards AS
WITH
  std_avg AS (
    SELECT
      local_student_id,
      academic_year,
      term_administered,
      response_type,
      performance_band_set_id,
      standard_description,
      CASE
        WHEN subject_area = 'Writing' THEN 'Text Study'
        ELSE subject_area
      END AS subject_area,
      ROUND(AVG(percent_correct), 0) AS avg_percent_correct
    FROM
      gabby.illuminate_dna_assessments.agg_student_responses_all_current
    WHERE
      response_type = 'G'
      AND is_normed_scope = 1
      AND subject_area IN (
        'Text Study',
        'Mathematics',
        'Writing'
      )
    GROUP BY
      local_student_id,
      academic_year,
      term_administered,
      response_type,
      standard_description,
      performance_band_set_id,
      CASE
        WHEN subject_area = 'Writing' THEN 'Text Study'
        ELSE subject_area
      END
  )
SELECT
  sa.local_student_id AS student_number,
  sa.academic_year,
  sa.term_administered AS term,
  sa.response_type,
  sa.avg_percent_correct AS percent_correct,
  sa.subject_area,
  REPLACE(
    sa.standard_description,
    '"',
    ''''
  ) AS standard_description,
  CASE
    WHEN pbl.label_number = 5 THEN 'Advanced Mastery'
    WHEN pbl.label_number = 4 THEN 'Mastery'
    WHEN pbl.label_number = 3 THEN 'Approaching Mastery'
    WHEN pbl.label_number = 2 THEN 'Below Mastery'
    WHEN pbl.label_number = 1 THEN 'Far Below Mastery'
  END AS standard_proficiency
FROM
  std_avg AS sa
  INNER JOIN gabby.illuminate_dna_assessments.performance_band_lookup_static AS pbl ON (
    sa.performance_band_set_id = pbl.performance_band_set_id
    AND (
      sa.avg_percent_correct BETWEEN pbl.minimum_value AND pbl.maximum_value
    )
  )
