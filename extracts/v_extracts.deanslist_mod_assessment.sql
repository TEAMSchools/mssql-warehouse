USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_mod_assessment AS

/* QA/CP */
SELECT local_student_id AS student_number	
      ,academic_year      
      ,subject_area	
      ,subject_area_label	      
      ,module_type AS scope	
      ,module_number AS module_num	
      ,rn_unit	      
      ,percent_correct	
      ,proficiency_label	      
FROM
    (
     SELECT asr.local_student_id
           ,asr.academic_year      
           ,asr.module_number
           ,asr.module_type
           ,asr.percent_correct
           ,asr.subject_area AS subject_area_label
           ,CASE
             WHEN asr.subject_area = 'Text Study' THEN 'ELA'
             WHEN asr.subject_area = 'Mathematics' THEN 'MATH'               
            END AS subject_area
           ,CASE
             WHEN asr.performance_band_number = 5 THEN 'Above Target'
             WHEN asr.performance_band_number = 4 THEN 'Target'
             WHEN asr.performance_band_number = 3 THEN 'Near Target'
             WHEN asr.performance_band_number = 2 THEN 'Below Target'
             WHEN asr.performance_band_number = 1 THEN 'Far Below Target'
            END AS proficiency_label
           ,RIGHT(asr.module_number, 1) AS rn_unit

           /* if a student takes a replacement assessment, it will be preferred */
           ,ROW_NUMBER() OVER(
              PARTITION BY asr.local_student_id, asr.subject_area, asr.module_number
                ORDER BY asr.is_replacement DESC, asr.percent_correct DESC) AS rn_subj_modnum
     FROM gabby.illuminate_dna_assessments.agg_student_responses_all asr
     WHERE asr.module_type IN ('QA','CP')
       AND asr.subject_area IN ('Text Study','Mathematics')
       AND asr.response_type = 'O'
       AND asr.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
       AND asr.percent_correct IS NOT NULL
    ) sub
WHERE rn_subj_modnum = 1

UNION ALL

/* CGI avg */
SELECT sub.local_student_id AS student_number
      ,sub.academic_year
      ,sub.subject_area
      ,sub.subject_area_label
      ,sub.module_type AS scope
      ,sub.module_num
      ,NULL AS rn_unit
      ,sub.avg_pct_correct 
      ,CASE
        WHEN pbl.label_number = 5 THEN 'Above Target'
        WHEN pbl.label_number = 4 THEN 'Target'
        WHEN pbl.label_number = 3 THEN 'Near Target'
        WHEN pbl.label_number = 2 THEN 'Below Target'
        WHEN pbl.label_number = 1 THEN 'Far Below Target'       
       END AS proficiency_label      
FROM
    (
     SELECT s.local_student_id
           ,a.academic_year_clean AS academic_year
           ,a.module_type
           ,a.subject_area AS subject_area_label
           ,REPLACE(a.term_administered, 'Q', 'QA') AS module_num
           ,'MATH' AS subject_area
           ,ROUND(AVG(asr.percent_correct),0) AS avg_pct_correct
           ,MIN(a.performance_band_set_id) AS performance_band_set_id
     FROM gabby.illuminate_dna_assessments.assessments_identifiers a
     JOIN gabby.illuminate_dna_assessments.agg_student_responses asr
       ON a.assessment_id = asr.assessment_id
     JOIN gabby.illuminate_public.students s
       ON asr.student_id = s.student_id
     WHERE a.module_type = 'CGI'
       AND a.subject_area = 'Mathematics'
       AND a.academic_year_clean = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
       AND a.deleted_at IS NULL
     GROUP BY s.local_student_id
             ,a.academic_year_clean
             ,a.subject_area
             ,a.term_administered
             ,a.module_type
    ) sub
JOIN gabby.illuminate_dna_assessments.performance_band_lookup_static pbl
  ON sub.performance_band_set_id = pbl.performance_band_set_id
 AND sub.avg_pct_correct BETWEEN pbl.minimum_value AND pbl.maximum_value

UNION ALL

/* Enrichment UA avgs */
SELECT sub.student_number
      ,sub.academic_year
      ,sub.subject_area
      ,sub.subject_area_label
      ,sub.scope
      ,sub.module_num
      ,NULL AS rn_unit
      ,sub.avg_pct_correct 
      ,CASE
        WHEN pbl.label_number = 5 THEN 'Above Target'
        WHEN pbl.label_number = 4 THEN 'Target'
        WHEN pbl.label_number = 3 THEN 'Near Target'
        WHEN pbl.label_number = 2 THEN 'Below Target'
        WHEN pbl.label_number = 1 THEN 'Far Below Target'       
       END AS proficiency_label      
FROM
    (
     SELECT s.local_student_id AS student_number
           ,a.academic_year_clean AS academic_year      
           ,a.subject_area AS subject_area_label
           ,'ENRICHMENT' AS subject_area           
           ,'UA' AS scope
           ,REPLACE(a.term_administered, 'Q', 'QA') AS module_num      
           ,ROUND(AVG(asr.percent_correct),0) AS avg_pct_correct                       
           ,MIN(a.performance_band_set_id) AS performance_band_set_id
     FROM gabby.illuminate_dna_assessments.assessments_identifiers a
     JOIN gabby.illuminate_dna_assessments.agg_student_responses asr
       ON a.assessment_id = asr.assessment_id
     JOIN gabby.illuminate_public.students s
       ON asr.student_id = s.student_id
     WHERE a.scope = 'Unit Assessment'
       AND a.subject_area NOT IN ('Text Study','Mathematics')  
       AND a.academic_year_clean = gabby.utilities.GLOBAL_ACADEMIC_YEAR()  
       AND a.deleted_at IS NULL
     GROUP BY s.local_student_id
             ,a.academic_year_clean              
             ,a.subject_area        
             ,a.term_administered
    ) sub
JOIN gabby.illuminate_dna_assessments.performance_band_lookup_static pbl
  ON sub.performance_band_set_id = pbl.performance_band_set_id
 AND sub.avg_pct_correct BETWEEN pbl.minimum_value AND pbl.maximum_value

UNION ALL

/* Sight Words */
SELECT s.local_student_id
      ,sub.academic_year
      ,'Sight Words' AS subject_area
      ,'Sight Words' AS subject_area_label
      ,'SW' AS scope
      ,sub.module_number
      ,NULL AS rn_unit    
      ,asr.percent_correct
      ,CASE
        WHEN asr.performance_band_level = 5 THEN 'Above Target'
        WHEN asr.performance_band_level = 4 THEN 'Target'
        WHEN asr.performance_band_level = 3 THEN 'Near Target'
        WHEN asr.performance_band_level = 2 THEN 'Below Target'
        WHEN asr.performance_band_level = 1 THEN 'Far Below Target'
       END AS proficiency_label
FROM
    (
     SELECT a.assessment_id
           ,a.academic_year_clean AS academic_year
           ,CONCAT('SW', RIGHT(a.title, 1)) AS module_number
           
           ,ROW_NUMBER() OVER(
             PARTITION BY a.academic_year, a.term_administered, a.tags
               ORDER BY a.administered_at DESC) AS rn
     FROM gabby.illuminate_dna_assessments.assessments_identifiers a
     WHERE a.scope = 'Sight Words Quiz'
       AND a.subject_area = 'Word Work'  
       AND a.academic_year_clean = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
       AND a.deleted_at IS NULL
    ) sub
JOIN gabby.illuminate_dna_assessments.agg_student_responses asr
  ON sub.assessment_id = asr.assessment_id
JOIN gabby.illuminate_public.students s
  ON asr.student_id = s.student_id
WHERE sub.rn = 1