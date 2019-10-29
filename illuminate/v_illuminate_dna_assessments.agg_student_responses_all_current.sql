USE gabby
GO

CREATE OR ALTER VIEW illuminate_dna_assessments.agg_student_responses_all_current AS

WITH response_rollup AS (
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
        ,1 AS is_normed_scope
  FROM gabby.illuminate_dna_assessments.assessment_responses_rollup_current_static
  
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
        ,0 AS is_normed_scope
  FROM gabby.illuminate_dna_assessments.assessment_responses_long
  WHERE is_normed_scope = 0
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
      ,rr.performance_band_set_id
      ,rr.is_normed_scope

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
 AND rta._fivetran_deleted = 0
LEFT JOIN gabby.reporting.reporting_terms rtt
  ON rr.date_taken BETWEEN rtt.start_date AND rtt.end_date
 AND co.schoolid = rtt.schoolid
 AND rtt.identifier = 'RT'
 AND rtt._fivetran_deleted = 0