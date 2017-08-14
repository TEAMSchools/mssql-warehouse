USE gabby
GO

ALTER VIEW act.test_prep_scores AS

WITH long_data AS (
  SELECT a.assessment_id
        ,a.title AS assessment_title        
        ,(a.academic_year - 1) AS academic_year
        ,a.administered_at

        ,dsu.code_translation AS subject_area        
        
        ,ovr.student_id AS illuminate_student_id
        ,ovr.performance_band_level AS overall_performance_band                      
        ,ovr.percent_correct AS overall_percent_correct
        ,CONVERT(INT,ROUND(((ovr.percent_correct / 100) * ovr.number_of_questions),0)) AS overall_number_correct

        ,s.local_student_id AS student_number        

        ,co.grade_level
        
        ,d.time_per_name
        ,d.alt_name AS administration_round
        
        ,ROW_NUMBER() OVER(
           PARTITION BY s.local_student_id, a.academic_year, a.code_subject_area_id, d.time_per_name
             ORDER BY CONVERT(INT,ROUND(((ovr.percent_correct / 100) * ovr.number_of_questions),0)) DESC) AS rn_highscore
  FROM gabby.illuminate_dna_assessments.assessments a
  JOIN gabby.illuminate_codes.dna_scopes dsc
    ON a.code_scope_id = dsc.code_id
   AND dsc.code_translation = 'ACT Prep'
  JOIN gabby.illuminate_codes.dna_subject_areas dsu
    ON a.code_subject_area_id = dsu.code_id
  JOIN gabby.illuminate_dna_assessments.agg_student_responses ovr
    ON a.assessment_id = ovr.assessment_id
  JOIN gabby.illuminate_public.students s
    ON ovr.student_id = s.student_id
  JOIN gabby.powerschool.cohort_identifiers_static co
    ON s.local_student_id = co.student_number
   AND a.academic_year = co.academic_year
   AND co.rn_year = 1
  LEFT OUTER JOIN gabby.reporting.reporting_terms d
    ON a.administered_at BETWEEN CONVERT(DATE,d.start_date) AND CONVERT(DATE,d.end_date)
   AND d.identifier = 'ACT'
 )

,overall_scores AS (
  SELECT d.student_number        
        ,d.illuminate_student_id
        ,d.academic_year                
        ,d.time_per_name
        ,d.subject_area
        ,d.overall_number_correct
        ,d.assessment_id        
        ,d.assessment_title        
        ,d.administration_round      
        ,d.administered_at                
        ,d.overall_percent_correct        
        ,d.overall_performance_band

        ,CONVERT(FLOAT,act.scale_score) AS scale_score
  FROM long_data d
  LEFT OUTER JOIN gabby.act.scale_score_key act
    ON d.academic_year = act.academic_year
   AND d.grade_level = act.grade_level
   AND d.time_per_name = act.administration_round
   AND d.subject_area = act.subject
   AND d.overall_number_correct = act.raw_score
  WHERE d.rn_highscore = 1

  UNION ALL

  SELECT student_number
        ,illuminate_student_id
        ,academic_year
        ,time_per_name
        ,'Composite' AS subject_area
        ,NULL AS overall_number_correct
        ,NULL AS assessment_id
        ,NULL AS assessment_title        
        ,administration_round
        ,MIN(administered_at) AS administered_at        
        ,NULL AS overall_percent_correct        
        ,NULL AS overall_performance_band            

        ,CASE WHEN COUNT(scale_score) = 4 THEN ROUND(AVG(scale_score),0) END AS scale_score
  FROM
      (
       SELECT d.student_number           
             ,d.illuminate_student_id
             ,d.academic_year
             ,d.assessment_id
             ,d.time_per_name
             ,d.administration_round                   
             ,d.administered_at
             ,d.subject_area   
             ,CONVERT(FLOAT,act.scale_score) AS scale_score           
       FROM long_data d
       LEFT OUTER JOIN gabby.act.scale_score_key act
         ON d.academic_year = act.academic_year
        AND d.grade_level = act.grade_level
        AND d.time_per_name = act.administration_round
        AND d.subject_area = act.subject
        AND d.overall_number_correct = act.raw_score     
       WHERE d.rn_highscore = 1
      ) sub
  GROUP BY student_number
          ,illuminate_student_id
          ,academic_year
          ,administration_round       
          ,time_per_name 
 )

SELECT sub.student_number
      ,sub.academic_year
      ,sub.assessment_id
      ,sub.assessment_title
      ,sub.time_per_name
      ,sub.administration_round      
      ,sub.administered_at
      ,sub.subject_area
      ,sub.overall_percent_correct
      ,sub.overall_number_correct
      ,sub.overall_performance_band
      ,sub.scale_score
      ,sub.prev_scale_score
      ,sub.pretest_scale_score
      ,sub.growth_from_pretest
      
      ,s.custom_code AS standard_code
      ,s.description AS standard_description
      ,CONVERT(FLOAT,std.percent_correct) AS standard_percent_correct      
      ,COALESCE(ps2.state_num, ps.state_num) AS standard_strand
      
      ,ROW_NUMBER() OVER(
         PARTITION BY sub.student_number, sub.academic_year, sub.administration_round, sub.subject_area
           ORDER BY sub.student_number) AS rn_dupe
      ,ROW_NUMBER() OVER(
         PARTITION BY sub.student_number, sub.academic_year, sub.subject_area
           ORDER BY sub.time_per_name DESC) AS rn_curr
FROM
    (
     SELECT student_number
           ,illuminate_student_id
           ,academic_year
           ,assessment_id
           ,assessment_title
           ,time_per_name
           ,administration_round
           ,administered_at
           ,subject_area
           ,overall_percent_correct
           ,overall_number_correct
           ,overall_performance_band
           ,scale_score
           ,LAG(scale_score) OVER(PARTITION BY student_number, academic_year, subject_area ORDER BY administered_at) AS prev_scale_score
           ,MAX(CASE WHEN administration_round = 'Pre-Test' THEN scale_score END) OVER(PARTITION BY student_number, academic_year, subject_area) AS pretest_scale_score
           ,CASE WHEN administration_round = 'Pre-Test' THEN NULL ELSE scale_score END 
              - MAX(CASE WHEN administration_round = 'Pre-Test' THEN scale_score END) OVER(PARTITION BY student_number, academic_year, subject_area) AS growth_from_pretest
     FROM overall_scores
    ) sub
LEFT OUTER JOIN gabby.illuminate_dna_assessments.agg_student_responses_standard std
  ON sub.assessment_id = std.assessment_id
 AND sub.illuminate_student_id = std.student_id
LEFT OUTER JOIN gabby.illuminate_standards.standards s
  ON std.standard_id = s.standard_id
LEFT OUTER JOIN gabby.illuminate_standards.standards ps
  ON s.parent_standard_id = ps.standard_id
LEFT OUTER JOIN gabby.illuminate_standards.standards ps2
  ON ps.parent_standard_id = ps2.standard_id