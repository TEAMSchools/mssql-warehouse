USE gabby
GO

CREATE OR ALTER VIEW illuminate_dna_assessments.agg_student_responses_all AS

WITH responses_long AS (                  
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
        ,a.is_replacement
        
        ,'O' AS response_type             

        ,asr.date_taken
        ,asr.points
        ,asr.points_possible                     
        ,asr.percent_correct             
        ,NULL AS standard_id
  FROM gabby.illuminate_dna_assessments.student_assessment_scaffold_static a
  LEFT OUTER JOIN gabby.illuminate_dna_assessments.students_assessments sa
    ON a.student_id = sa.student_id
   AND a.assessment_id = sa.assessment_id        
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
        ,a.is_replacement
        
        ,'S' AS response_type             

        ,sa.date_taken
             
        ,asrs.points
        ,asrs.points_possible        
        ,asrs.percent_correct             
        ,asrs.standard_id
  FROM gabby.illuminate_dna_assessments.student_assessment_scaffold_static a
  JOIN gabby.illuminate_dna_assessments.students_assessments sa
    ON a.student_id = sa.student_id
   AND a.assessment_id = sa.assessment_id        
  JOIN gabby.illuminate_dna_assessments.agg_student_responses_standard asrs
    ON sa.student_assessment_id = asrs.student_assessment_id
   AND asrs.points_possible > 0  

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
        ,a.is_replacement
        
        ,'G' AS response_type
             
        ,sa.date_taken
                          
        ,asrg.points
        ,asrg.points_possible        
        ,asrg.percent_correct             
        ,asrg.reporting_group_id AS standard_id
  FROM gabby.illuminate_dna_assessments.student_assessment_scaffold_static a
  JOIN gabby.illuminate_dna_assessments.students_assessments sa
    ON a.student_id = sa.student_id
   AND a.assessment_id = sa.assessment_id        
  JOIN gabby.illuminate_dna_assessments.agg_student_responses_group asrg
    ON sa.student_assessment_id = asrg.student_assessment_id
   --AND asrg.reporting_group_id IN (5287, 274) /* 'Open-Ended Response', 'Multiple Choice' */
   AND asrg.reporting_group_id IN (21769, 26978) /* Item Type: Multiple Choice / Selected Response (one correct), Open Ended Response */   
   AND asrg.points_possible > 0       
 )

,response_rollup AS (
  SELECT student_id
        ,MIN(assessment_id) AS assessment_id
        ,CONCAT(subject_area, ' - ', module_number, ' - ', module_type, ' - ', academic_year, '-', (academic_year + 1)) AS title
        ,academic_year            
        ,scope
        ,subject_area
        ,module_type
        ,module_number
        ,MIN(administered_at) AS administered_at
        ,MIN(performance_band_set_id) AS performance_band_set_id
        ,is_replacement
        ,response_type
        ,standard_id
        ,MIN(date_taken) AS date_taken
        ,SUM(points) AS points
        ,ROUND((SUM(points) / SUM(points_possible)) * 100, 0) AS percent_correct
  FROM responses_long
  WHERE scope IN (SELECT scope FROM gabby.illuminate_dna_assessments.normed_scopes)
  GROUP BY student_id             
          ,academic_year                   
          ,scope
          ,subject_area
          ,module_type
          ,module_number             
          ,is_replacement
          ,response_type
          ,standard_id
  
  UNION ALL

  SELECT student_id
        ,assessment_id  
        ,title
        ,academic_year            
        ,scope
        ,subject_area
        ,module_type
        ,module_number
        ,administered_at
        ,performance_band_set_id        
        ,is_replacement
        ,response_type
        ,standard_id
        ,date_taken
        ,points
        ,percent_correct
  FROM responses_long
  WHERE scope NOT IN (SELECT scope FROM gabby.illuminate_dna_assessments.normed_scopes)
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
      ,rr.standard_id      
      ,rr.points
      ,rr.percent_correct
      ,rr.is_replacement

      ,s.local_student_id
           
      ,CASE
        WHEN rr.response_type = 'O' THEN 'Overall'
        WHEN rr.response_type = 'G' AND rr.standard_id = 5287 THEN 'OER'
        WHEN rr.response_type = 'G' AND rr.standard_id = 274 THEN 'MC'
        ELSE std.custom_code 
       END AS standard_code
      ,CASE
        WHEN rr.response_type = 'O' THEN 'Overall'
        WHEN rr.response_type = 'G' AND rr.standard_id = 5287 THEN 'Open-Ended Response'
        WHEN rr.response_type = 'G' AND rr.standard_id = 274 THEN 'Multiple Choice'
        ELSE std.description
       END AS standard_description
      
      ,dom.domain_description

      ,rta.alt_name AS term_administered
      ,rtt.alt_name AS term_taken
      
      ,pbl.label_number AS performance_band_number
      ,pbl.is_mastery
FROM response_rollup rr
JOIN gabby.illuminate_public.students s
  ON rr.student_id = s.student_id
LEFT OUTER JOIN gabby.illuminate_standards.standards std
  ON rr.standard_id = std.standard_id
 AND rr.response_type = 'S'
LEFT OUTER JOIN gabby.illuminate_standards.standards_domain_static dom
  ON rr.standard_id = dom.standard_id
 AND rr.response_type = 'S'
 AND dom.domain_label NOT IN ('','Standard')
LEFT OUTER JOIN gabby.illuminate_dna_assessments.performance_band_lookup_static pbl
  ON rr.performance_band_set_id = pbl.performance_band_set_id
 AND rr.percent_correct BETWEEN pbl.minimum_value AND pbl.maximum_value
JOIN gabby.powerschool.cohort_identifiers_static co 
  ON s.local_student_id = co.student_number
 AND rr.academic_year = co.academic_year
 AND co.rn_year = 1
LEFT OUTER JOIN gabby.reporting.reporting_terms rta
  ON rr.administered_at BETWEEN CONVERT(DATE,rta.start_date) AND CONVERT(DATE,rta.end_date)
 AND co.schoolid = rta.schoolid
 AND rta.identifier = 'RT' 
LEFT OUTER JOIN gabby.reporting.reporting_terms rtt
  ON rr.date_taken BETWEEN CONVERT(DATE,rtt.start_date) AND CONVERT(DATE,rtt.end_date)
 AND co.schoolid = rtt.schoolid
 AND rtt.identifier = 'RT'
WHERE rr.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

UNION ALL

SELECT assessment_id
      ,academic_year    
      ,administered_at
      ,date_taken
      ,title
      ,scope
      ,subject_area
      ,module_type
      ,module_number           
      ,response_type
      ,standard_id      
      ,points
      ,percent_correct
      ,is_replacement           
      ,local_student_id
      ,standard_code  
      ,standard_description
      ,domain_description
      ,term_administered
      ,term_taken      
      ,performance_band_number
      ,is_mastery
FROM gabby.illuminate_dna_assessments.agg_student_responses_all_archive