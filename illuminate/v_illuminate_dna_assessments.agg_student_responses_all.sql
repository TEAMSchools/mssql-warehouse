USE gabby
GO

ALTER VIEW illuminate_dna_assessments.agg_student_responses_all AS

WITH response_rollup AS (
  SELECT student_id
        ,assessment_id  
        ,title
        ,academic_year            
        ,scope
        ,subject_area
        ,module_type
        ,module_number
        ,performance_band_set_id        
        ,response_type
        ,standard_code  
        ,standard_description
        ,reporting_group              
        ,MIN(administered_at) AS administered_at
        ,MIN(date_taken) AS date_taken
        ,ROUND((SUM(points) / SUM(points_possible)) * 100, 0) AS percent_correct
  FROM
      (
       SELECT a.student_id
             ,a.assessment_id
             ,a.title
             ,a.academic_year    
             ,a.administered_at
             ,a.scope
             ,a.subject_area
             ,a.module_type
             ,a.module_number
             ,a.performance_band_set_id
        
             ,'O' AS response_type             

             ,asr.date_taken
             ,asr.points
             ,asr.points_possible                     
             
             ,NULL AS standard_code  
             ,NULL AS standard_description
             ,NULL AS reporting_group      
       FROM gabby.illuminate_dna_assessments.student_assessment_scaffold a
       LEFT OUTER JOIN gabby.illuminate_dna_assessments.students_assessments sa
         ON a.student_id = sa.student_id
        AND a.assessment_id = sa.assessment_id
        AND sa.student_assessment_id NOT IN (SELECT student_assessment_id FROM gabby.illuminate_dna_assessments.students_assessments_archive)
       LEFT OUTER JOIN gabby.illuminate_dna_assessments.agg_student_responses asr
         ON sa.student_assessment_id = asr.student_assessment_id
        AND asr.points_possible > 0

       UNION ALL

       SELECT a.student_id
             ,a.assessment_id
             ,a.title
             ,a.academic_year    
             ,a.administered_at
             ,a.scope
             ,a.subject_area
             ,a.module_type
             ,a.module_number
             ,a.performance_band_set_id
        
             ,'S' AS response_type             

             ,sa.date_taken
             
             ,asrs.points
             ,asrs.points_possible        
             
             ,s.custom_code AS standard_code
             ,s.description AS standard_description
             ,NULL AS reporting_group
       FROM gabby.illuminate_dna_assessments.student_assessment_scaffold a
       JOIN gabby.illuminate_dna_assessments.students_assessments sa
         ON a.student_id = sa.student_id
        AND a.assessment_id = sa.assessment_id
        AND sa.student_assessment_id NOT IN (SELECT student_assessment_id FROM gabby.illuminate_dna_assessments.students_assessments_archive)
       JOIN gabby.illuminate_dna_assessments.agg_student_responses_standard asrs
         ON sa.student_assessment_id = asrs.student_assessment_id
        AND asrs.points_possible > 0
       JOIN gabby.illuminate_standards.standards s
         ON asrs.standard_id = s.standard_id

       UNION ALL

       SELECT a.student_id
             ,a.assessment_id
             ,a.title
             ,a.academic_year    
             ,a.administered_at
             ,a.scope
             ,a.subject_area
             ,a.module_type
             ,a.module_number
             ,a.performance_band_set_id
        
             ,'G' AS response_type
             
             ,sa.date_taken
                          
             ,asrg.points
             ,asrg.points_possible        
             
             ,NULL AS standard_code
             ,NULL AS standard_description
             ,CASE
               WHEN asrg.reporting_group_id = 5287 THEN 'Open-Ended Response'
               WHEN asrg.reporting_group_id = 274 THEN 'Multiple Choice'
              END AS reporting_group
             --,rg.label AS reporting_group
       FROM gabby.illuminate_dna_assessments.student_assessment_scaffold a
       JOIN gabby.illuminate_dna_assessments.students_assessments sa
         ON a.student_id = sa.student_id
        AND a.assessment_id = sa.assessment_id
        AND sa.student_assessment_id NOT IN (SELECT student_assessment_id FROM gabby.illuminate_dna_assessments.students_assessments_archive)
       JOIN gabby.illuminate_dna_assessments.agg_student_responses_group asrg
         ON sa.student_assessment_id = asrg.student_assessment_id
        AND asrg.reporting_group_id IN (5287, 274) /* 'Open-Ended Response', 'Multiple Choice' */
        AND asrg.points_possible > 0
       --JOIN gabby.illuminate_dna_assessments.reporting_groups rg
       --  ON asrg.reporting_group_id = rg.reporting_group_id
       -- AND rg.label IN ('Multiple Choice', 'Open-Ended Response')
      ) sub
  GROUP BY assessment_id
          ,title
          ,student_id
          ,academic_year    
          ,scope
          ,subject_area
          ,module_type
          ,module_number
          ,performance_band_set_id
          ,response_type
          ,standard_code
          ,standard_description
          ,reporting_group
 )

SELECT rr.assessment_id
      ,rr.academic_year    
      ,rr.administered_at
      ,rr.date_taken
      ,rr.title
      ,rr.scope
      ,rr.subject_area
      ,rr.module_type
      ,rr.module_number           
      ,rr.response_type
      ,rr.standard_code  
      ,rr.standard_description
      ,rr.reporting_group      
      ,rr.percent_correct
           
      ,s.local_student_id

      ,NULL AS term_administered
      ,NULL AS term_taken
      
      ,pbl.label_number AS performance_band_number
      ,pbl.is_mastery
FROM response_rollup rr
JOIN gabby.illuminate_public.students s
  ON rr.student_id = s.student_id
LEFT OUTER JOIN gabby.illuminate_dna_assessments.performance_band_lookup pbl
  ON rr.performance_band_set_id = pbl.performance_band_set_id
 AND rr.percent_correct BETWEEN pbl.minimum_value AND pbl.maximum_value