CREATE OR ALTER VIEW
  tableau.qa_assessment_audit AS
WITH
  standards_grouped AS (
    SELECT
      fs.field_id,
      dbo.GROUP_CONCAT_D (s.custom_code, '; ') AS standard_codes
    FROM
      illuminate_dna_assessments.field_standards AS fs
      INNER JOIN illuminate_standards.standards AS s ON (fs.standard_id = s.standard_id)
    GROUP BY
      fs.field_id
  )
SELECT
  a.assessment_id,
  a.title,
  a.academic_year_clean AS academic_year,
  a.administered_at,
  a.module_type,
  a.module_number,
  a.scope,
  a.subject_area,
  a.tags,
  a.is_normed_scope,
  a.creator_first_name + ' ' + a.creator_last_name AS created_by,
  pbs.[description] AS performance_band_set_description,
  gr.short_name AS assessment_grade_level,
  f.field_id,
  f.sheet_label AS question_number,
  f.maximum AS question_points_possible,
  f.extra_credit AS question_extra_credit,
  f.is_rubric AS question_is_rubric,
  CASE
    WHEN frg.reporting_group_id IN (26978, 5287) THEN 'OER'
    WHEN frg.reporting_group_id IN (274, 2766, 2776, 2796) THEN 'MC'
  END AS question_reporting_group,
  sg.standard_codes AS question_standard_codes
FROM
  illuminate_dna_assessments.assessments_identifiers_static AS a
  LEFT JOIN illuminate_dna_assessments.performance_band_sets AS pbs ON (
    a.performance_band_set_id = pbs.performance_band_set_id
  )
  LEFT JOIN illuminate_dna_assessments.assessment_grade_levels AS agl ON (
    a.assessment_id = agl.assessment_id
  )
  LEFT JOIN illuminate_public.grade_levels AS gr ON (
    agl.grade_level_id = gr.grade_level_id
  )
  INNER JOIN illuminate_dna_assessments.fields AS f ON (
    a.assessment_id = f.assessment_id
    AND f.deleted_at IS NULL
  )
  LEFT JOIN illuminate_dna_assessments.fields_reporting_groups AS frg ON (
    f.field_id = frg.field_id
    AND (
      frg.reporting_group_id IN (
        SELECT
          reporting_group_id
        FROM
          illuminate_dna_assessments.reporting_groups
        WHERE
          [label] IN (
            'Multiple Choice',
            'Open Ended Response',
            'Open-Ended Response'
          )
      )
      OR frg.reporting_group_id IS NULL
    )
  )
  LEFT JOIN standards_grouped AS sg ON (f.field_id = sg.field_id)
WHERE
  a.deleted_at IS NULL
  AND a.academic_year_clean IN (
    utilities.GLOBAL_ACADEMIC_YEAR (),
    utilities.GLOBAL_ACADEMIC_YEAR () - 1
  )
