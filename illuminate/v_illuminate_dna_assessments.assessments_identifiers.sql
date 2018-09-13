USE gabby
GO

CREATE OR ALTER VIEW illuminate_dna_assessments.assessments_identifiers AS

SELECT a.assessment_id
      ,a.title
      ,a.description
      ,a.user_id
      ,a.created_at
      ,a.updated_at
      ,a.deleted_at
      ,a.administered_at
      ,a.code_scope_id
      ,a.code_subject_area_id
      ,a.reports_db_virtual_table_id
      ,a.academic_year
      ,a.local_assessment_id
      ,a.intel_assess_guid
      ,a.guid
      ,a.tags
      ,a.edusoft_guid
      ,a.performance_band_set_id
      ,a.als_guid
      ,a.curriculum_associate_guid
      ,a.allow_duplicates
      ,a.itembank_assessment_id
      ,a.locked
      ,a.show_in_parent_portal
      ,a.administration_window_start_date
      ,a.administration_window_end_date
      ,a.is_hybrid_x
      ,a.academic_year_clean

      ,u.local_user_id AS creator_local_user_id
      ,u.username AS creator_username
      ,u.email1 AS creator_email1      

      ,ds.code_translation AS scope
      ,dsa.code_translation AS subject_area
      ,pbs.description AS performance_band_set_description
FROM gabby.illuminate_dna_assessments.assessments a
LEFT JOIN gabby.illuminate_public.users u
  ON a.user_id = u.user_id
LEFT JOIN gabby.illuminate_codes.dna_scopes ds
  ON a.code_scope_id = ds.code_id
LEFT JOIN gabby.illuminate_codes.dna_subject_areas dsa
  ON a.code_subject_area_id = dsa.code_id
LEFT JOIN gabby.illuminate_dna_assessments.performance_band_sets pbs
  ON a.performance_band_set_id = pbs.performance_band_set_id
