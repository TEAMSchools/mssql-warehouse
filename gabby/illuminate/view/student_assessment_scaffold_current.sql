CREATE OR ALTER VIEW
  illuminate_dna_assessments.student_assessment_scaffold_current AS
WITH
  asmts AS (
    SELECT
      assessment_id,
      title,
      administered_at,
      performance_band_set_id,
      academic_year,
      academic_year_clean,
      module_type,
      module_number,
      scope,
      (
        subject_area
        COLLATE SQL_Latin1_General_CP1_CI_AS
      ) AS subject_area,
      is_normed_scope
    FROM
      illuminate_dna_assessments.assessments_identifiers_static
    WHERE
      deleted_at IS NULL
      AND academic_year_clean = utilities.GLOBAL_ACADEMIC_YEAR ()
  )
SELECT
  sub.assessment_id,
  sub.title,
  sub.administered_at,
  sub.performance_band_set_id,
  sub.academic_year,
  CASE
    WHEN (
      sub.scope IN (
        'Cumulative Review Quizzes',
        'Cold Read Quizzes'
      )
      AND sub.grade_level_id IN (1, 2)
    ) THEN 'CP'
    ELSE sub.module_type
  END AS module_type,
  CASE
    WHEN (
      sub.scope IN (
        'Cumulative Review Quizzes',
        'Cold Read Quizzes'
      )
      AND sub.grade_level_id IN (1, 2)
    ) THEN REPLACE(sub.module_number, 'CRQ', 'CP')
    ELSE sub.module_number
  END AS module_number,
  CASE
    WHEN (
      sub.scope IN (
        'Cumulative Review Quizzes',
        'Cold Read Quizzes'
      )
      AND sub.grade_level_id IN (1, 2)
    ) THEN 'Checkpoint'
    ELSE sub.scope
  END AS scope,
  sub.subject_area,
  sub.is_normed_scope,
  sub.grade_level_id,
  sub.student_id,
  sub.is_replacement
FROM
  (
    /* standard curriculum -- K-8 */
    SELECT
      a.assessment_id,
      a.title,
      a.administered_at,
      a.performance_band_set_id,
      a.academic_year_clean AS academic_year,
      a.module_type,
      a.module_number,
      a.scope,
      a.subject_area,
      a.is_normed_scope,
      agl.grade_level_id,
      ssa.student_id,
      0 AS is_replacement
    FROM
      asmts AS a
      INNER JOIN illuminate_dna_assessments.assessment_grade_levels AS agl ON (
        a.assessment_id = agl.assessment_id
      )
      INNER JOIN illuminate_public.student_session_aff_clean_static AS ssa ON (
        a.academic_year = ssa.academic_year
        AND agl.grade_level_id = ssa.grade_level_id
        AND ssa.rn = 1
      )
      /* trunk-ignore(sqlfluff/L016) */
      INNER JOIN illuminate_dna_assessments.course_enrollment_scaffold_current_static AS ce ON ( -- noqa: L016
        ssa.student_id = ce.student_id
        AND a.subject_area = ce.subject_area
        AND (
          a.administered_at BETWEEN ce.entry_date AND ce.leave_date
        )
        AND ce.is_advanced_math_student = 0
      )
    WHERE
      a.subject_area IN (
        'Text Study',
        'Mathematics',
        'Social Studies',
        'Science'
      )
      AND a.is_normed_scope = 1
    UNION ALL
    /* standard curriculum -- HS */
    SELECT
      a.assessment_id,
      a.title,
      a.administered_at,
      a.performance_band_set_id,
      a.academic_year_clean AS academic_year,
      a.module_type,
      a.module_number,
      a.scope,
      a.subject_area,
      a.is_normed_scope,
      agl.grade_level_id,
      ce.student_id,
      0 AS is_replacement
    FROM
      asmts AS a
      INNER JOIN illuminate_dna_assessments.assessment_grade_levels AS agl ON (
        a.assessment_id = agl.assessment_id
      )
      /* trunk-ignore(sqlfluff/L016) */
      INNER JOIN illuminate_dna_assessments.course_enrollment_scaffold_current_static AS ce ON ( -- noqa: L016
        agl.grade_level_id = ce.grade_level_id
        AND a.subject_area = ce.subject_area
        AND (
          a.administered_at BETWEEN ce.entry_date AND ce.leave_date
        )
      )
    WHERE
      a.is_normed_scope = 1
      AND a.subject_area NOT IN (
        'Text Study',
        'Mathematics',
        'Social Studies',
        'Science'
      )
    UNION ALL
    /* replacement curriculum */
    SELECT DISTINCT
      a.assessment_id,
      a.title,
      a.administered_at,
      a.performance_band_set_id,
      a.academic_year_clean AS academic_year,
      a.module_type,
      a.module_number,
      a.scope,
      a.subject_area,
      a.is_normed_scope,
      NULL AS grade_level_id,
      sa.student_id,
      1 AS is_replacement
    FROM
      asmts AS a
      INNER JOIN illuminate_dna_assessments.assessment_grade_levels AS agl ON (
        a.assessment_id = agl.assessment_id
      )
      INNER JOIN illuminate_dna_assessments.students_assessments AS sa ON (
        a.assessment_id = sa.assessment_id
      )
      INNER JOIN illuminate_public.student_session_aff_clean_static AS ssa ON (
        sa.student_id = ssa.student_id
        AND a.academic_year = ssa.academic_year
        AND ssa.rn = 1
        AND agl.grade_level_id != ssa.grade_level_id
      )
    WHERE
      a.is_normed_scope = 1
      AND a.subject_area IN (
        'Text Study',
        'Mathematics',
        'Social Studies',
        'Science'
      )
    UNION ALL
    /* all other assessments */
    SELECT DISTINCT
      a.assessment_id,
      a.title,
      a.administered_at,
      a.performance_band_set_id,
      a.academic_year_clean AS academic_year,
      a.module_type,
      a.module_number,
      a.scope,
      a.subject_area,
      a.is_normed_scope,
      NULL AS grade_level_id,
      sa.student_id,
      0 AS is_replacement
    FROM
      asmts AS a
      INNER JOIN illuminate_dna_assessments.students_assessments AS sa ON (
        a.assessment_id = sa.assessment_id
      )
    WHERE
      a.is_normed_scope = 0
  ) AS sub
