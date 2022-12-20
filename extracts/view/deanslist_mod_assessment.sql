CREATE OR ALTER VIEW
  extracts.deanslist_mod_assessment AS
WITH
  assessments_long AS (
    SELECT
      local_student_id,
      academic_year,
      term_administered,
      subject_area,
      module_type,
      module_number,
      percent_correct,
      performance_band_number,
      performance_band_set_id,
      performance_band_label,
      /* if a student takes a replacement assessment, it will be preferred */
      ROW_NUMBER() OVER (
        PARTITION BY
          local_student_id,
          subject_area,
          module_number
        ORDER BY
          is_replacement DESC,
          percent_correct DESC
      ) AS rn_subj_modnum
    FROM
      gabby.illuminate_dna_assessments.agg_student_responses_all_current
    WHERE
      response_type = 'O'
      AND subject_area IN (
        'Text Study',
        'Mathematics'
      )
      AND module_type IN (
        'QA',
        'CRQ',
        'CGI',
        'CP'
      )
      AND percent_correct IS NOT NULL
  )
SELECT
  sub.local_student_id AS student_number,
  sub.academic_year,
  sub.term_administered,
  CASE
    WHEN sub.subject_area = 'Text Study' THEN 'ELA'
    WHEN sub.subject_area = 'Mathematics' THEN 'MATH'
  END AS subject_area,
  sub.subject_area AS subject_area_label,
  sub.module_type AS scope,
  sub.module_number AS module_num,
  RIGHT(sub.module_number, 1) AS rn_unit,
  sub.percent_correct,
  sub.performance_band_label AS proficiency_label
FROM
  (
    SELECT
      al.local_student_id,
      al.academic_year,
      al.term_administered,
      al.subject_area,
      al.module_type,
      al.module_number,
      al.percent_correct,
      al.performance_band_label
    FROM
      assessments_long AS al
    WHERE
      al.rn_subj_modnum = 1
    UNION ALL
    SELECT
      sub.local_student_id,
      sub.academic_year,
      sub.term_administered,
      sub.subject_area,
      sub.module_type,
      sub.module_type + 'A' AS module_number,
      sub.avg_percent_correct,
      pbl.[label] AS performance_band_label
    FROM
      (
        SELECT
          al.local_student_id,
          al.academic_year,
          al.term_administered,
          al.subject_area,
          al.module_type,
          ROUND(
            AVG(al.percent_correct),
            1
          ) AS avg_percent_correct,
          MIN(
            al.performance_band_set_id
          ) AS min_performance_band_set_id
        FROM
          assessments_long AS al
        WHERE
          al.rn_subj_modnum = 1
        GROUP BY
          al.local_student_id,
          al.academic_year,
          al.term_administered,
          al.subject_area,
          al.module_type
      ) AS sub
      INNER JOIN gabby.illuminate_dna_assessments.performance_band_lookup_static AS pbl ON sub.min_performance_band_set_id = pbl.performance_band_set_id
      AND (
        sub.avg_percent_correct BETWEEN pbl.minimum_value AND pbl.maximum_value
      )
  ) AS sub
UNION ALL
/* Enrichment UA avgs */
SELECT
  sub.student_number,
  sub.academic_year,
  sub.term_administered,
  sub.subject_area,
  sub.subject_area_label,
  sub.scope,
  sub.module_num,
  NULL AS rn_unit,
  sub.avg_pct_correct,
  pbl.[label] AS proficiency_label
FROM
  (
    SELECT
      s.local_student_id AS student_number,
      a.academic_year_clean AS academic_year,
      a.term_administered,
      a.subject_area AS subject_area_label,
      'ENRICHMENT' AS subject_area,
      'UA' AS scope,
      REPLACE(
        a.term_administered,
        'Q',
        'QA'
      ) AS module_num,
      ROUND(
        AVG(asr.percent_correct),
        0
      ) AS avg_pct_correct,
      MIN(
        a.performance_band_set_id
      ) AS performance_band_set_id
    FROM
      gabby.illuminate_dna_assessments.assessments_identifiers_static AS a
      INNER JOIN gabby.illuminate_dna_assessments.agg_student_responses AS asr ON a.assessment_id = asr.assessment_id
      INNER JOIN gabby.illuminate_public.students AS s ON asr.student_id = s.student_id
    WHERE
      a.scope = 'Unit Assessment'
      AND a.subject_area NOT IN (
        'Text Study',
        'Mathematics'
      )
      AND a.academic_year_clean = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
      AND a.deleted_at IS NULL
    GROUP BY
      s.local_student_id,
      a.academic_year_clean,
      a.subject_area,
      a.term_administered
  ) AS sub
  INNER JOIN gabby.illuminate_dna_assessments.performance_band_lookup_static AS pbl ON sub.performance_band_set_id = pbl.performance_band_set_id
  AND (
    sub.avg_pct_correct BETWEEN pbl.minimum_value AND pbl.maximum_value
  )
