USE gabby
GO

CREATE OR ALTER VIEW illuminate_dna_assessments.agg_student_responses_all_current AS

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
        ,'Overall' AS standard_code
        ,'Overall' AS standard_description
        ,NULL AS domain_description
  FROM gabby.illuminate_dna_assessments.student_assessment_scaffold_static a
  LEFT JOIN gabby.illuminate_dna_assessments.students_assessments sa
    ON a.student_id = sa.student_id
   AND a.assessment_id = sa.assessment_id        
  LEFT JOIN gabby.illuminate_dna_assessments.agg_student_responses asr
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
        ,astd.performance_band_set_id
        ,a.is_replacement
        
        ,'S' AS response_type             

        ,sa.date_taken
             
        ,asrs.points
        ,asrs.points_possible        
        ,asrs.percent_correct             
        ,asrs.standard_id

        ,CONVERT(VARCHAR(125),std.custom_code) AS standard_code
        ,CONVERT(VARCHAR(2000),std.description) AS standard_description

        ,dom.domain_description
  FROM gabby.illuminate_dna_assessments.student_assessment_scaffold_static a
  JOIN gabby.illuminate_dna_assessments.students_assessments sa
    ON a.student_id = sa.student_id
   AND a.assessment_id = sa.assessment_id        
  JOIN gabby.illuminate_dna_assessments.agg_student_responses_standard asrs
    ON sa.student_assessment_id = asrs.student_assessment_id
   AND asrs.points_possible > 0  
  JOIN gabby.illuminate_dna_assessments.assessment_standards astd
    ON asrs.assessment_id = astd.assessment_id
   AND asrs.standard_id = astd.standard_id
  LEFT JOIN gabby.illuminate_standards.standards std
    ON asrs.standard_id = std.standard_id   
  LEFT JOIN gabby.illuminate_standards.standards_domain_static dom
    ON asrs.standard_id = dom.standard_id
   AND dom.domain_level = 1
   AND dom.domain_label NOT IN ('', 'Standard')
  
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
        ,arg.performance_band_set_id
        ,a.is_replacement
        
        ,'G' AS response_type
             
        ,sa.date_taken
                          
        ,asrg.points
        ,asrg.points_possible        
        ,asrg.percent_correct             
        ,asrg.reporting_group_id AS standard_id

        ,NULL AS standard_code
        ,rg.label AS standard_description
        ,NULL AS domain_description
  FROM gabby.illuminate_dna_assessments.student_assessment_scaffold_static a
  JOIN gabby.illuminate_dna_assessments.students_assessments sa
    ON a.student_id = sa.student_id
   AND a.assessment_id = sa.assessment_id        
  JOIN gabby.illuminate_dna_assessments.agg_student_responses_group asrg
    ON sa.student_assessment_id = asrg.student_assessment_id      
   AND asrg.points_possible > 0       
  JOIN gabby.illuminate_dna_assessments.assessments_reporting_groups arg
    ON asrg.assessment_id = arg.assessment_id
   AND asrg.reporting_group_id = arg.reporting_group_id
  JOIN gabby.illuminate_dna_assessments.reporting_groups rg
    ON asrg.reporting_group_id = rg.reporting_group_id
 )

,response_rollup AS (
  SELECT student_id
        ,academic_year            
        ,scope
        ,subject_area
        ,module_type
        ,module_number        
        ,is_replacement
        ,response_type
        ,standard_id
        ,standard_code
        ,standard_description
        ,domain_description
        
        ,MIN(title) AS title
        ,MIN(assessment_id) AS assessment_id
        ,MIN(administered_at) AS administered_at
        ,MIN(performance_band_set_id) AS performance_band_set_id
        ,MIN(date_taken) AS date_taken
        ,SUM(points) AS points
        ,ROUND((SUM(points) / SUM(points_possible)) * 100, 1) AS percent_correct
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
          ,standard_code
          ,standard_description
          ,domain_description
  
  UNION ALL

  SELECT student_id
        ,academic_year            
        ,scope
        ,subject_area
        ,module_type
        ,module_number
        ,is_replacement
        ,response_type
        ,standard_id
        ,standard_code
        ,standard_description
        ,domain_description
        
        ,title        
        ,assessment_id  
        ,administered_at
        ,performance_band_set_id        
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
      ,CONVERT(VARCHAR(250),rr.title) AS title
      ,CONVERT(VARCHAR(125),rr.scope) AS scope
      ,CONVERT(VARCHAR(125),rr.subject_area) AS subject_area
      ,CONVERT(VARCHAR(25),rr.module_type) AS module_type
      ,CONVERT(VARCHAR(5),rr.module_number) AS module_number    
      ,rr.response_type
      ,rr.standard_id      
      ,rr.points
      ,rr.percent_correct
      ,rr.is_replacement
      ,rr.standard_code
      ,rr.standard_description      
      ,rr.domain_description

      ,CONVERT(INT,s.local_student_id) AS local_student_id

      ,CONVERT(VARCHAR(5),rta.alt_name) AS term_administered
      ,CONVERT(VARCHAR(5),rtt.alt_name) AS term_taken
      
      ,pbl.label_number AS performance_band_number
      ,pbl.is_mastery
FROM response_rollup rr
JOIN gabby.illuminate_public.students s
  ON rr.student_id = s.student_id
LEFT JOIN gabby.illuminate_dna_assessments.performance_band_lookup_static pbl
  ON rr.performance_band_set_id = pbl.performance_band_set_id
 AND rr.percent_correct BETWEEN pbl.minimum_value AND pbl.maximum_value
JOIN gabby.powerschool.cohort_identifiers_static co 
  ON s.local_student_id = co.student_number
 AND rr.academic_year = co.academic_year
 AND co.rn_year = 1
LEFT JOIN gabby.reporting.reporting_terms rta
  ON rr.administered_at BETWEEN rta.start_date AND rta.end_date
 AND co.schoolid = rta.schoolid
 AND rta.identifier = 'RT' 
LEFT JOIN gabby.reporting.reporting_terms rtt
  ON rr.date_taken BETWEEN rtt.start_date AND rtt.end_date
 AND co.schoolid = rtt.schoolid
 AND rtt.identifier = 'RT'