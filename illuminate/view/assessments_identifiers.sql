USE gabby GO
CREATE OR ALTER VIEW
  illuminate_dna_assessments.assessments_identifiers AS
WITH
  tnl_uids AS (
    SELECT
      u.[user_id]
    FROM
      gabby.people.work_assignment_history_static sr
      JOIN gabby.illuminate_public.users u ON CAST(sr.employee_number AS VARCHAR(25)) = u.state_id
    WHERE
      sr.home_department_description = 'Teaching and Learning'
    UNION
    SELECT
      u.[user_id]
    FROM
      gabby.illuminate_public.users u
    WHERE
      u.username IN ('login', 'kippfoundation', 'JEsteban')
  )
SELECT
  sub.assessment_id,
  sub.title,
  sub.[description],
  sub.[user_id],
  sub.created_at,
  sub.updated_at,
  sub.deleted_at,
  sub.administered_at,
  sub.code_scope_id,
  sub.code_subject_area_id,
  sub.reports_db_virtual_table_id,
  sub.academic_year,
  sub.local_assessment_id,
  sub.intel_assess_guid,
  sub.[guid],
  sub.tags,
  sub.edusoft_guid,
  sub.performance_band_set_id,
  sub.als_guid,
  sub.curriculum_associate_guid,
  sub.allow_duplicates,
  sub.itembank_assessment_id,
  sub.locked,
  sub.show_in_parent_portal,
  sub.administration_window_start_date,
  sub.administration_window_end_date,
  sub.is_hybrid_x,
  sub.academic_year_clean,
  sub.creator_local_user_id,
  sub.creator_username,
  sub.creator_email1,
  sub.creator_first_name,
  sub.creator_last_name,
  sub.performance_band_set_description,
  sub.scope,
  sub.subject_area,
  sub.normed_scope,
  sub.is_normed_scope,
  sub.module_type,
  SUBSTRING(
    sub.title,
    PATINDEX(sub.module_number_pattern, sub.title),
    sub.module_number_length
  ) AS module_number,
  sub.term_administered
FROM
  (
    SELECT
      a.assessment_id,
      a.title,
      a.[description],
      a.[user_id],
      a.created_at,
      a.updated_at,
      a.deleted_at,
      a.administered_at,
      a.code_scope_id,
      a.code_subject_area_id,
      a.reports_db_virtual_table_id,
      a.academic_year,
      a.local_assessment_id,
      a.intel_assess_guid,
      a.[guid],
      a.tags,
      a.edusoft_guid,
      a.performance_band_set_id,
      a.als_guid,
      a.curriculum_associate_guid,
      a.allow_duplicates,
      a.itembank_assessment_id,
      a.locked,
      a.show_in_parent_portal,
      a.administration_window_start_date,
      a.administration_window_end_date,
      a.is_hybrid_x,
      a.academic_year - 1 AS academic_year_clean,
      u.local_user_id AS creator_local_user_id,
      u.username AS creator_username,
      u.email1 AS creator_email1,
      u.first_name AS creator_first_name,
      u.last_name AS creator_last_name,
      pbs.[description] AS performance_band_set_description,
      ds.code_translation AS scope,
      dsa.code_translation AS subject_area,
      n.scope AS normed_scope,
      n.module_type,
      CASE
        WHEN n.scope IS NOT NULL THEN 1
        ELSE 0
      END AS is_normed_scope,
      CASE
        WHEN PATINDEX(
          '%' + n.module_number_pattern_1 + '[0-9][0-9]/[0-9][0-9]%',
          a.title
        ) > 0 THEN '%' + n.module_number_pattern_1 + '[0-9][0-9]/[0-9][0-9]%'
        WHEN PATINDEX(
          '%' + n.module_number_pattern_1 + '[0-9]/[0-9][0-9]%',
          a.title
        ) > 0 THEN '%' + n.module_number_pattern_1 + '[0-9]/[0-9][0-9]%'
        WHEN PATINDEX(
          '%' + n.module_number_pattern_1 + '[0-9]/[0-9]%',
          a.title
        ) > 0 THEN '%' + n.module_number_pattern_1 + '[0-9]/[0-9]%'
        WHEN PATINDEX(
          '%' + n.module_number_pattern_1 + '[0-9][0-9]%',
          a.title
        ) > 0 THEN '%' + n.module_number_pattern_1 + '[0-9][0-9]%'
        WHEN PATINDEX(
          '%' + n.module_number_pattern_1 + '[0-9]%',
          a.title
        ) > 0 THEN '%' + n.module_number_pattern_1 + '[0-9]%'
        WHEN PATINDEX(
          '%' + n.module_number_pattern_2 + '[0-9][0-9]/[0-9][0-9]%',
          a.title
        ) > 0 THEN '%' + n.module_number_pattern_2 + '[0-9][0-9]/[0-9][0-9]%'
        WHEN PATINDEX(
          '%' + n.module_number_pattern_2 + '[0-9]/[0-9][0-9]%',
          a.title
        ) > 0 THEN '%' + n.module_number_pattern_2 + '[0-9]/[0-9][0-9]%'
        WHEN PATINDEX(
          '%' + n.module_number_pattern_2 + '[0-9]/[0-9]%',
          a.title
        ) > 0 THEN '%' + n.module_number_pattern_2 + '[0-9]/[0-9]%'
        WHEN PATINDEX(
          '%' + n.module_number_pattern_2 + '[0-9][0-9]%',
          a.title
        ) > 0 THEN '%' + n.module_number_pattern_2 + '[0-9][0-9]%'
        WHEN PATINDEX(
          '%' + n.module_number_pattern_2 + '[0-9]%',
          a.title
        ) > 0 THEN '%' + n.module_number_pattern_2 + '[0-9]%'
      END AS module_number_pattern,
      CASE
        WHEN PATINDEX(
          '%' + n.module_number_pattern_1 + '[0-9][0-9]/[0-9][0-9]%',
          a.title
        ) > 0 THEN LEN(n.module_number_pattern_1) + 5
        WHEN PATINDEX(
          '%' + n.module_number_pattern_1 + '[0-9]/[0-9][0-9]%',
          a.title
        ) > 0 THEN LEN(n.module_number_pattern_1) + 4
        WHEN PATINDEX(
          '%' + n.module_number_pattern_1 + '[0-9]/[0-9]%',
          a.title
        ) > 0 THEN LEN(n.module_number_pattern_1) + 3
        WHEN PATINDEX(
          '%' + n.module_number_pattern_1 + '[0-9][0-9]%',
          a.title
        ) > 0 THEN LEN(n.module_number_pattern_1) + 2
        WHEN PATINDEX(
          '%' + n.module_number_pattern_1 + '[0-9]%',
          a.title
        ) > 0 THEN LEN(n.module_number_pattern_1) + 1
        WHEN PATINDEX(
          '%' + n.module_number_pattern_2 + '[0-9][0-9]/[0-9][0-9]%',
          a.title
        ) > 0 THEN LEN(n.module_number_pattern_2) + 5
        WHEN PATINDEX(
          '%' + n.module_number_pattern_2 + '[0-9]/[0-9][0-9]%',
          a.title
        ) > 0 THEN LEN(n.module_number_pattern_2) + 4
        WHEN PATINDEX(
          '%' + n.module_number_pattern_2 + '[0-9]/[0-9]%',
          a.title
        ) > 0 THEN LEN(n.module_number_pattern_2) + 3
        WHEN PATINDEX(
          '%' + n.module_number_pattern_2 + '[0-9][0-9]%',
          a.title
        ) > 0 THEN LEN(n.module_number_pattern_2) + 2
        WHEN PATINDEX(
          '%' + n.module_number_pattern_2 + '[0-9]%',
          a.title
        ) > 0 THEN LEN(n.module_number_pattern_2) + 1
      END AS module_number_length,
      CAST(rt.alt_name AS VARCHAR(5)) AS term_administered
    FROM
      gabby.illuminate_dna_assessments.assessments a
      JOIN gabby.illuminate_public.users u ON a.[user_id] = u.[user_id]
      JOIN gabby.illuminate_dna_assessments.performance_band_sets pbs ON a.performance_band_set_id = pbs.performance_band_set_id
      LEFT JOIN gabby.illuminate_codes.dna_scopes ds ON a.code_scope_id = ds.code_id
      LEFT JOIN gabby.illuminate_codes.dna_subject_areas dsa ON a.code_subject_area_id = dsa.code_id
      LEFT JOIN gabby.assessments.normed_scopes n ON a.academic_year = (n.academic_year + 1)
      AND ds.code_translation = n.scope
      AND n._fivetran_deleted = 0
      LEFT JOIN gabby.reporting.reporting_terms rt ON a.administered_at BETWEEN rt.[start_date] AND rt.end_date
      AND rt.identifier = 'RT'
      AND rt.schoolid = 0
      AND rt._fivetran_deleted = 0
  ) sub
