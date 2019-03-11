USE gabby
GO

CREATE OR ALTER VIEW illuminate_dna_assessments.assessments_identifiers AS

WITH tnl_uids AS (
  SELECT DISTINCT u.user_id
  FROM gabby.dayforce.employee_work_assignment sr
  JOIN gabby.illuminate_public.users u
    ON CONVERT(VARCHAR(25),sr.employee_reference_code) = u.state_id
  WHERE sr.department_name = 'Teaching and Learning'

  UNION

  SELECT u.user_id
  FROM gabby.illuminate_public.users u
  WHERE u.username IN ('login', 'kippfoundation', 'JEsteban')
 )

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
      ,u.first_name AS creator_first_name
      ,u.last_name AS creator_last_name

      ,pbs.description AS performance_band_set_description

      ,ds.code_translation AS scope

      ,dsa.code_translation AS subject_area

      ,ns.scope AS normed_scope
      ,CASE WHEN ns.scope IS NOT NULL THEN 1 ELSE 0 END AS is_normed_scope

      ,CASE
        WHEN a.user_id NOT IN (SELECT user_id FROM tnl_uids) THEN NULL
        WHEN ds.code_translation = 'Sight Words Quiz' THEN 'SWQ'
        WHEN ds.code_translation = 'Process Piece' THEN 'PP'
        WHEN ns.scope IS NULL THEN NULL        
        WHEN ds.code_translation = 'CMA - End-of-Module' AND a.academic_year <= 2016 THEN 'EOM'
        WHEN ds.code_translation = 'CMA - End-of-Module' AND a.academic_year > 2016 THEN 'QA'
        WHEN ds.code_translation IN ('Cold Read Quizzes', 'Cumulative Review Quizzes') THEN 'CRQ'
        WHEN ds.code_translation = 'CGI Quiz' THEN 'CGI'
        WHEN ds.code_translation = 'Math Facts and Counting Jar' THEN 'MFCJ'
        WHEN ds.code_translation = 'Checkpoint' THEN 'CP'
        WHEN ds.code_translation = 'CMA - Mid-Module' AND PATINDEX('%Checkpoint [0-9]%', a.title) = 0 THEN 'MM'
        WHEN ds.code_translation = 'CMA - Mid-Module' AND PATINDEX('%Checkpoint [0-9]%', a.title) > 0 THEN 'CP' + SUBSTRING(a.title, PATINDEX('%Checkpoint [0-9]%', a.title) + 11, 1)
       END AS module_type
      ,CASE
        WHEN a.user_id NOT IN (SELECT user_id FROM tnl_uids) THEN NULL
        WHEN PATINDEX('%SWQ[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%SWQ[0-9]%', a.title), 4)        
        WHEN ds.code_translation = 'Process Piece' AND CHARINDEX(DATENAME(MONTH, a.administered_at), a.title) > 0 
             THEN CONCAT('PP', CASE 
                                WHEN DATEPART(MONTH, a.administered_at) >= 9 THEN (DATEPART(MONTH, a.administered_at) - 9) + 1
                                WHEN DATEPART(MONTH, a.administered_at) < 9 THEN ((12 - 9) + DATEPART(MONTH, a.administered_at)) + 1
                               END)
        WHEN ds.code_translation = 'Process Piece' AND PATINDEX('%QA[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%QA[0-9]%', a.title), 3)
        WHEN ds.code_translation = 'Process Piece' AND PATINDEX('%[MU][0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%[MU][0-9]%', a.title), 2)        
        WHEN ns.scope IS NULL THEN NULL
        WHEN PATINDEX('%[MU][0-9]/[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%[MU][0-9]/[0-9]%', a.title), 4)
        WHEN PATINDEX('%[MU][0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%[MU][0-9]%', a.title), 2)
        WHEN PATINDEX('%QA[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%QA[0-9]%', a.title), 3)
        WHEN PATINDEX('%CP[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%CP[0-9]%', a.title), 3)
        WHEN PATINDEX('%MQ[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%MQ[0-9]%', a.title), 3)
        WHEN PATINDEX('%CGI[0-9][0-9]%', a.title) > 0 THEN LTRIM(RTRIM(SUBSTRING(a.title, PATINDEX('%CGI[0-9]%', a.title), 5)))
        WHEN PATINDEX('%CGI[0-9]%', a.title) > 0 THEN LTRIM(RTRIM(SUBSTRING(a.title, PATINDEX('%CGI[0-9]%', a.title), 4)))
        WHEN PATINDEX('%CRQ[0-9][0-9]%', a.title) > 0 THEN LTRIM(RTRIM(SUBSTRING(a.title, PATINDEX('%CRQ[0-9]%', a.title), 5)))
        WHEN PATINDEX('%CRQ[0-9]%', a.title) > 0 THEN LTRIM(RTRIM(SUBSTRING(a.title, PATINDEX('%CRQ[0-9]%', a.title), 4)))
        WHEN PATINDEX('%MF[0-9][0-9]%', a.title) > 0 THEN LTRIM(RTRIM(SUBSTRING(a.title, PATINDEX('%MF[0-9]%', a.title), 4)))
        WHEN PATINDEX('%MF[0-9]%', a.title) > 0 THEN LTRIM(RTRIM(SUBSTRING(a.title, PATINDEX('%MF[0-9]%', a.title), 3)))
        WHEN PATINDEX('%CJ[0-9][0-9]%', a.title) > 0 THEN LTRIM(RTRIM(SUBSTRING(a.title, PATINDEX('%CJ[0-9]%', a.title), 4)))
        WHEN PATINDEX('%CJ[0-9]%', a.title) > 0 THEN LTRIM(RTRIM(SUBSTRING(a.title, PATINDEX('%CJ[0-9]%', a.title), 3)))        
       END AS module_number

      ,CONVERT(VARCHAR(5),rt.alt_name) AS term_administered
FROM gabby.illuminate_dna_assessments.assessments a
JOIN gabby.illuminate_public.users u
  ON a.user_id = u.user_id
JOIN gabby.illuminate_dna_assessments.performance_band_sets pbs WITH(FORCESEEK)
  ON a.performance_band_set_id = pbs.performance_band_set_id
LEFT JOIN gabby.illuminate_codes.dna_scopes ds WITH(FORCESEEK)
  ON a.code_scope_id = ds.code_id
LEFT JOIN gabby.illuminate_codes.dna_subject_areas dsa WITH(FORCESEEK)
  ON a.code_subject_area_id = dsa.code_id
LEFT JOIN gabby.illuminate_dna_assessments.normed_scopes ns WITH(FORCESEEK)
  ON ds.code_translation = ns.scope
LEFT JOIN gabby.reporting.reporting_terms rt WITH(FORCESEEK)
  ON a.administered_at BETWEEN rt.start_date AND rt.end_date
 AND rt.identifier = 'RT'
 AND rt.schoolid = 0
 AND rt._fivetran_deleted = 0