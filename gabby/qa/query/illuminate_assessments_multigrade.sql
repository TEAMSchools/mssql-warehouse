WITH
  asmts AS (
    SELECT
      assessment_id,
      academic_year,
      title,
      module_type,
      module_number,
      scope,
      subject_area,
      is_normed_scope
    FROM
      illuminate_dna_assessments.assessments_identifiers_static
    WHERE
      deleted_at IS NULL
  )
SELECT
  assessment_id,
  academic_year,
  title,
  scope,
  subject_area,
  module_number,
  COUNT(grade_level_id) AS n_grade_tags
FROM
  (
    SELECT
      a.assessment_id,
      a.academic_year,
      a.title,
      a.scope,
      a.subject_area,
      a.module_number,
      agl.grade_level_id
    FROM
      asmts AS a
      INNER JOIN illuminate_dna_assessments.assessment_grade_levels AS agl ON (
        a.assessment_id = agl.assessment_id
      )
    WHERE
      a.is_normed_scope = 1
  ) AS sub
GROUP BY
  assessment_id,
  academic_year,
  title,
  scope,
  subject_area,
  module_number
ORDER BY
  n_grade_tags DESC
