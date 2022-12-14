USE gabby GO
CREATE OR ALTER VIEW
  tableau.qa_cma_entry_audit AS
SELECT
  s.local_student_id AS student_number,
  saa.assessment_id,
  saa.title,
  saa.administered_at,
  saa.subject_area,
  saa.scope,
  saa.module_type,
  saa.module_number,
  saa.is_replacement,
  rt.alt_name AS term,
  o.percent_correct,
  co.lastfirst,
  co.region,
  co.reporting_schoolid,
  co.grade_level,
  co.team,
  co.enroll_status
FROM
  gabby.illuminate_dna_assessments.student_assessment_scaffold_current_static saa
  JOIN gabby.illuminate_public.students s ON saa.student_id = s.student_id
  LEFT JOIN gabby.illuminate_dna_assessments.agg_student_responses o ON saa.student_id = o.student_id
  AND saa.assessment_id = o.assessment_id
  LEFT JOIN gabby.reporting.reporting_terms rt ON saa.administered_at BETWEEN rt.[start_date] AND rt.end_date
  AND rt.identifier = 'RT'
  AND rt.schoolid = 0
  AND rt._fivetran_deleted = 0
  JOIN gabby.powerschool.cohort_identifiers_static co ON s.local_student_id = co.student_number
  AND saa.academic_year = co.academic_year
  AND co.rn_year = 1
  AND co.enroll_status = 0
WHERE
  saa.is_normed_scope = 1
  AND saa.is_replacement = 0
