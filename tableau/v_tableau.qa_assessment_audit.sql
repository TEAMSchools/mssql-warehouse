USE gabby
GO

CREATE OR ALTER VIEW tableau.qa_assessment_audit AS

WITH standards_grouped AS (
  SELECT fs.field_id
      
        ,gabby.dbo.GROUP_CONCAT_D(s.custom_code, '; ') AS standard_codes
  FROM gabby.illuminate_dna_assessments.field_standards fs
  JOIN gabby.illuminate_standards.standards s
    ON fs.standard_id = s.standard_id
  GROUP BY fs.field_id
 )

SELECT a.assessment_id
      ,a.title
      ,a.academic_year - 1 AS academic_year
      ,a.administered_at            
      ,CASE
        WHEN dsc.code_translation = 'Process Piece' THEN 'PP'
        WHEN dsc.code_translation NOT IN (SELECT scope FROM gabby.illuminate_dna_assessments.normed_scopes) THEN NULL
        WHEN dsc.code_translation = 'CMA - End-of-Module' AND a.academic_year <= 2016 THEN 'EOM'
        WHEN dsc.code_translation = 'CMA - End-of-Module' AND a.academic_year > 2016 THEN 'QA'
        WHEN dsc.code_translation IN ('Cold Read Quizzes', 'Cumulative Review Quizzes') THEN 'CRQ'
        WHEN dsc.code_translation = 'CGI Quiz' THEN 'CGI'
        WHEN dsc.code_translation = 'Math Facts and Counting Jar' THEN 'MFCJ'
        WHEN dsc.code_translation = 'Checkpoint' THEN 'CP'
        WHEN dsc.code_translation = 'CMA - Mid-Module' AND PATINDEX('%Checkpoint [0-9]%', a.title) = 0 THEN 'MM'
        WHEN dsc.code_translation = 'CMA - Mid-Module' AND PATINDEX('%Checkpoint [0-9]%', a.title) > 0 
               THEN 'CP' + SUBSTRING(a.title, PATINDEX('%Checkpoint [0-9]%', a.title) + 11, 1)
       END AS module_type
      ,CASE
        WHEN dsc.code_translation = 'Process Piece' AND PATINDEX('%QA[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%QA[0-9]%', a.title), 3)
        WHEN dsc.code_translation = 'Process Piece' AND PATINDEX('%[MU][0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%[MU][0-9]%', a.title), 2)
        WHEN dsc.code_translation NOT IN (SELECT scope FROM gabby.illuminate_dna_assessments.normed_scopes) THEN NULL
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

      ,dsc.code_translation AS scope
      
      ,dsu.code_translation AS subject_area

      ,CONCAT(u.first_name, ' ', u.last_name) AS created_by

      ,pbs.description AS performance_band_set_description

      ,gr.short_name AS assessment_grade_level

      ,f.field_id
      ,f.sheet_label AS question_number
      ,f.maximum AS question_points_possible
      ,f.extra_credit AS question_extra_credit
      ,f.is_rubric AS question_is_rubric
      
      ,CASE
        WHEN frg.reporting_group_id IN (26978, 5287) THEN 'OER'
        WHEN frg.reporting_group_id IN (274, 2766, 2776, 2796) THEN 'MC'
       END AS question_reporting_group

      ,sg.standard_codes AS question_standard_codes
FROM gabby.illuminate_dna_assessments.assessments a
LEFT OUTER JOIN gabby.illuminate_codes.dna_scopes dsc
  ON a.code_scope_id = dsc.code_id
LEFT OUTER JOIN gabby.illuminate_codes.dna_subject_areas dsu
  ON a.code_subject_area_id = dsu.code_id
LEFT OUTER JOIN gabby.illuminate_public.users u
  ON a.user_id = u.user_id
LEFT OUTER JOIN gabby.illuminate_dna_assessments.performance_band_sets pbs
  ON a.performance_band_set_id = pbs.performance_band_set_id
LEFT OUTER JOIN gabby.illuminate_dna_assessments.assessment_grade_levels agl
  ON a.assessment_id = agl.assessment_id
 AND agl.assessment_grade_level_id IN (SELECT assessment_grade_level_id FROM gabby.illuminate_dna_assessments.assessment_grade_levels_validation_static) 
LEFT OUTER JOIN gabby.illuminate_public.grade_levels gr
  ON agl.grade_level_id = gr.grade_level_id 
JOIN gabby.illuminate_dna_assessments.fields f
  ON a.assessment_id = f.assessment_id
 AND f.field_id IN (SELECT field_id FROM gabby.illuminate_dna_assessments.fields_validation_static)
 AND f.deleted_at IS NULL
LEFT OUTER JOIN gabby.illuminate_dna_assessments.fields_reporting_groups frg
  ON f.field_id = frg.field_id
 AND frg.reporting_group_id IN (SELECT reporting_group_id FROM gabby.illuminate_dna_assessments.reporting_groups WHERE label IN ('Multiple Choice','Open Ended Response','Open-Ended Response'))
LEFT OUTER JOIN standards_grouped sg
  ON f.field_id = sg.field_id
WHERE a.deleted_at IS NULL