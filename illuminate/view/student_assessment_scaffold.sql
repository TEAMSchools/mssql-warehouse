CREATE OR ALTER VIEW
  illuminate_dna_assessments.student_assessment_scaffold AS
SELECT
  assessment_id,
  title,
  administered_at,
  performance_band_set_id,
  academic_year,
  module_type,
  module_number,
  scope,
  subject_area,
  is_normed_scope,
  grade_level_id,
  student_id,
  is_replacement
FROM
  gabby.illuminate_dna_assessments.student_assessment_scaffold_current_static
UNION ALL
SELECT
  assessment_id,
  title,
  administered_at,
  performance_band_set_id,
  academic_year,
  module_type,
  module_number,
  scope,
  subject_area,
  is_normed_scope,
  grade_level_id,
  student_id,
  is_replacement
FROM
  gabby.illuminate_dna_assessments.student_assessment_scaffold_archive
