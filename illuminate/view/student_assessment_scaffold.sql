CREATE OR ALTER VIEW
  illuminate_dna_assessments.student_assessment_scaffold AS
SELECT
  cur.assessment_id,
  cur.title,
  cur.administered_at,
  cur.performance_band_set_id,
  cur.academic_year,
  cur.module_type,
  cur.module_number,
  cur.scope,
  cur.subject_area,
  cur.is_normed_scope,
  cur.grade_level_id,
  cur.student_id,
  cur.is_replacement
FROM
  gabby.illuminate_dna_assessments.student_assessment_scaffold_current_static AS cur
UNION ALL
SELECT
  arc.assessment_id,
  arc.title,
  arc.administered_at,
  arc.performance_band_set_id,
  arc.academic_year,
  arc.module_type,
  arc.module_number,
  arc.scope,
  arc.subject_area,
  arc.is_normed_scope,
  arc.grade_level_id,
  arc.student_id,
  arc.is_replacement
FROM
  gabby.illuminate_dna_assessments.student_assessment_scaffold_archive AS arc
