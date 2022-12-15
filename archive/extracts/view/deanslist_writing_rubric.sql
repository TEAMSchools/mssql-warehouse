USE gabby GO
CREATE OR ALTER VIEW
  extracts.deanslist_writing_rubric AS
SELECT
  student_number,
  academic_year,
  rubric_strand,
  [Q1],
  [Q2],
  [Q3],
  [Q4],
  [PP1],
  [PP2],
  [PP3],
  [PP4],
  [PP5],
  [PP6],
  [PP7],
  [PP8],
  [PP9],
  [PP10],
  [PP11],
  [PP12]
FROM
  (
    SELECT
      a.academic_year_clean AS academic_year,
      SUBSTRING(a.module_number, 2, 4) AS module_num,
      std.[description] AS rubric_strand,
      pbl.[label] AS performance_band_label,
      s.local_student_id AS student_number
    FROM
      gabby.illuminate_dna_assessments.assessments_identifiers_static AS a
      INNER JOIN gabby.illuminate_dna_assessments.assessment_standards AS ast ON a.assessment_id = ast.assessment_id
      INNER JOIN gabby.illuminate_standards.standards AS std ON ast.standard_id = std.standard_id
      INNER JOIN gabby.illuminate_standards.subjects AS ss ON std.subject_id = ss.subject_id
      AND ss.title = 'KIPP NJ K-4 Narrative Rubric'
      INNER JOIN gabby.illuminate_dna_assessments.agg_student_responses_standard AS asrs ON ast.assessment_id = asrs.assessment_id
      AND ast.standard_id = asrs.standard_id
      INNER JOIN gabby.illuminate_dna_assessments.performance_band_lookup_static AS pbl ON a.performance_band_set_id = pbl.performance_band_set_id
      AND asrs.percent_correct (
        BETWEEN pbl.minimum_value AND pbl.maximum_value
      )
      INNER JOIN gabby.illuminate_public.students AS s ON asrs.student_id = s.student_id
    WHERE
      a.academic_year_clean = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
      AND a.scope = 'Process Piece'
      AND a.subject_area = 'Writing'
    UNION ALL
    SELECT
      sub.academic_year,
      sub.module_num,
      sub.rubric_strand,
      pbl.[label] AS performance_band_label,
      sub.student_number
    FROM
      (
        SELECT
          a.academic_year_clean AS academic_year,
          MIN(a.performance_band_set_id) AS min_performance_band_set_id,
          rt.alt_name AS module_num,
          std.[description] AS rubric_strand,
          ROUND(AVG(asrs.percent_correct), 0) AS avg_percent_correct,
          s.local_student_id AS student_number
        FROM
          gabby.illuminate_dna_assessments.assessments_identifiers_static AS a
          INNER JOIN gabby.reporting.reporting_terms AS rt ON a.administered_at (BETWEEN rt.[start_date] AND rt.end_date)
          AND rt.identifier = 'RT'
          AND rt.schoolid = 0
          AND rt._fivetran_deleted = 0
          INNER JOIN gabby.illuminate_dna_assessments.assessment_standards AS ast ON a.assessment_id = ast.assessment_id
          INNER JOIN gabby.illuminate_standards.standards AS std ON ast.standard_id = std.standard_id
          INNER JOIN gabby.illuminate_standards.subjects AS ss ON std.subject_id = ss.subject_id
          AND ss.title = 'KIPP NJ K-4 Narrative Rubric'
          INNER JOIN gabby.illuminate_dna_assessments.agg_student_responses_standard AS asrs ON ast.assessment_id = asrs.assessment_id
          AND ast.standard_id = asrs.standard_id
          INNER JOIN gabby.illuminate_public.students AS s ON asrs.student_id = s.student_id
        WHERE
          a.academic_year_clean = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
          AND a.scope = 'Process Piece'
          AND a.subject_area = 'Writing'
        GROUP BY
          a.academic_year_clean,
          rt.alt_name,
          std.[description],
          s.local_student_id
      ) sub
      INNER JOIN gabby.illuminate_dna_assessments.performance_band_lookup_static AS pbl ON sub.min_performance_band_set_id = pbl.performance_band_set_id
      AND sub.avg_percent_correct (
        BETWEEN pbl.minimum_value AND pbl.maximum_value
      )
  ) sub PIVOT (
    MAX(performance_band_label) FOR module_num IN (
      [Q1],
      [Q2],
      [Q3],
      [Q4],
      [PP1],
      [PP2],
      [PP3],
      [PP4],
      [PP5],
      [PP6],
      [PP7],
      [PP8],
      [PP9],
      [PP10],
      [PP11],
      [PP12]
    )
  ) p
