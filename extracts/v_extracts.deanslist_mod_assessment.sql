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
     SELECT asr.local_student_id
           ,asr.academic_year                 
           ,asr.module_type
           ,asr.subject_area AS subject_area_label
           ,REPLACE(asr.term_administered, 'Q', 'QA') AS module_num      
           ,'MATH' AS subject_area
           ,ROUND(AVG(asr.percent_correct),0) AS avg_pct_correct                     
     FROM gabby.illuminate_dna_assessments.agg_student_responses_all asr
     WHERE asr.module_type = 'CGI'
       AND asr.subject_area = 'Mathematics'
       AND asr.response_type = 'O'
       AND asr.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
       AND asr.percent_correct IS NOT NULL
     GROUP BY asr.local_student_id
             ,asr.academic_year              
             ,asr.subject_area        
             ,asr.term_administered
             ,asr.module_type
    ) sub
JOIN gabby.illuminate_dna_assessments.performance_band_lookup_static pbl
  ON sub.avg_pct_correct BETWEEN pbl.minimum_value AND pbl.maximum_value
 AND pbl.description = 'KIPP NJ Proficiency Band - 1718'

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
     SELECT asr.local_student_id AS student_number
           ,asr.academic_year      
           ,asr.subject_area AS subject_area_label
           ,'ENRICHMENT' AS subject_area           
           ,'UA' AS scope
           ,REPLACE(asr.term_administered, 'Q', 'QA') AS module_num      
           ,ROUND(AVG(asr.percent_correct),0) AS avg_pct_correct                       
     FROM gabby.illuminate_dna_assessments.agg_student_responses_all asr
     WHERE asr.scope = 'Unit Assessment'
       AND asr.subject_area NOT IN ('Text Study','Mathematics')
       AND asr.response_type = 'O'
       AND asr.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
       AND asr.percent_correct IS NOT NULL
     GROUP BY asr.local_student_id
             ,asr.academic_year              
             ,asr.subject_area        
             ,asr.term_administered
    ) sub
JOIN gabby.illuminate_dna_assessments.performance_band_lookup_static pbl
  ON sub.avg_pct_correct BETWEEN pbl.minimum_value AND pbl.maximum_value
 AND pbl.description = 'KIPP NJ Proficiency Band - 1718'

UNION ALL

/* Sight Words */
SELECT asr.local_student_id
      ,asr.academic_year     
      ,'Sight Words' AS subject_area
      ,'Sight Words' AS subject_area_label
      ,'SW' AS scope       
      ,asr.module_number
      ,NULL AS rn_unit
      ,asr.percent_correct
      ,CASE
        WHEN asr.performance_band_number = 5 THEN 'Above Target'
        WHEN asr.performance_band_number = 4 THEN 'Target'
        WHEN asr.performance_band_number = 3 THEN 'Near Target'
        WHEN asr.performance_band_number = 2 THEN 'Below Target'
        WHEN asr.performance_band_number = 1 THEN 'Far Below Target'
       END AS proficiency_label
FROM gabby.illuminate_dna_assessments.agg_student_responses_all asr
WHERE asr.scope = 'Sight Words Quiz'
  AND asr.subject_area IN ('Word Work')
  AND asr.response_type = 'O'
  AND asr.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND asr.percent_correct IS NOT NULL