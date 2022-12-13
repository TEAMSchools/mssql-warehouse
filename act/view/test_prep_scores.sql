USE gabby
GO

CREATE OR ALTER VIEW act.test_prep_scores AS 

WITH long_data AS (
  SELECT a.assessment_id
        ,CAST(a.title AS NVARCHAR(128)) AS assessment_title
        ,a.academic_year_clean AS academic_year
        ,a.administered_at
        ,CAST(a.subject_area AS NVARCHAR(128)) AS subject_area

        ,ovr.student_id AS illuminate_student_id
        ,ovr.performance_band_level AS overall_performance_band
        ,ovr.percent_correct AS overall_percent_correct
        ,ovr.number_of_questions
        ,ROUND(((ovr.percent_correct / 100) * ovr.number_of_questions), 0) AS overall_number_correct

        ,CAST(s.local_student_id AS INT) AS student_number

        ,CAST(d.time_per_name AS VARCHAR) AS time_per_name
        ,CAST(d.alt_name AS VARCHAR) AS administration_round

        ,co.grade_level
        ,co.schoolid
  FROM gabby.illuminate_dna_assessments.assessments_identifiers_static a
  INNER JOIN gabby.illuminate_dna_assessments.agg_student_responses ovr
    ON a.assessment_id = ovr.assessment_id
  INNER JOIN gabby.illuminate_public.students s
    ON ovr.student_id = s.student_id
  INNER JOIN gabby.reporting.reporting_terms d
    ON a.administered_at BETWEEN d.[start_date] AND d.end_date
   AND d.identifier = 'ACT'
   AND d._fivetran_deleted = 0
  INNER JOIN gabby.powerschool.cohort_identifiers_static co
    ON s.local_student_id = co.student_number
   AND a.academic_year_clean = co.academic_year
   AND co.rn_year = 1
  WHERE a.scope = 'ACT Prep'
)

,scaled AS (
  SELECT ld.student_number
        ,ld.illuminate_student_id
        ,ld.academic_year
        ,ld.assessment_id
        ,ld.assessment_title
        ,ld.administration_round
        ,ld.time_per_name
        ,ld.administered_at        
        ,ld.subject_area
        ,ld.number_of_questions
        ,ld.overall_number_correct        
        ,ld.overall_percent_correct
        ,ld.overall_performance_band        
        ,ld.grade_level
        ,ld.schoolid

        ,CAST(act.scale_score AS INT) AS scale_score

        ,ROW_NUMBER() OVER(
           PARTITION BY ld.student_number, ld.academic_year, ld.subject_area, ld.time_per_name
             ORDER BY ld.overall_number_correct DESC) AS rn_highscore
  FROM long_data ld
  LEFT JOIN gabby.act.scale_score_key act
    ON ld.academic_year = act.academic_year
   AND ld.grade_level = act.grade_level
   AND ld.time_per_name = act.administration_round
   AND ld.subject_area = act.[subject]
   AND ld.overall_number_correct = act.raw_score
   AND act._fivetran_deleted = 0
)

,overall_scores AS (
  SELECT student_number        
        ,illuminate_student_id
        ,academic_year                
        ,schoolid
        ,grade_level
        ,time_per_name
        ,subject_area        
        ,assessment_id        
        ,assessment_title        
        ,administration_round      
        ,administered_at                
        ,number_of_questions
        ,overall_number_correct
        ,overall_percent_correct        
        ,overall_performance_band        
        ,scale_score
  FROM scaled
  WHERE rn_highscore = 1

  UNION ALL

  SELECT student_number
        ,illuminate_student_id
        ,academic_year
        ,schoolid
        ,grade_level
        ,time_per_name
        ,'Composite' AS subject_area
        ,NULL AS assessment_id
        ,NULL AS assessment_title
        ,administration_round
        ,MIN(administered_at) AS administered_at
        ,SUM(number_of_questions) AS number_of_questions
        ,SUM(overall_number_correct) AS overall_number_correct
        ,ROUND((SUM(overall_number_correct) / SUM(number_of_questions)) * 100, 0) AS overall_percent_correct
        ,NULL AS overall_performance_band
        ,CASE WHEN COUNT(scale_score) = 4 THEN ROUND(AVG(scale_score), 0) END AS scale_score
  FROM scaled
  GROUP BY student_number
          ,illuminate_student_id
          ,academic_year
          ,schoolid
          ,grade_level
          ,administration_round
          ,time_per_name
)

SELECT sub.student_number
      ,sub.academic_year
      ,sub.schoolid
      ,sub.grade_level
      ,sub.assessment_id
      ,sub.assessment_title
      ,sub.time_per_name
      ,sub.administration_round      
      ,sub.administered_at
      ,sub.subject_area
      ,sub.number_of_questions
      ,sub.overall_number_correct
      ,sub.overall_percent_correct      
      ,sub.overall_performance_band
      ,sub.scale_score
      ,sub.prev_scale_score
      ,sub.pretest_scale_score
      ,sub.growth_from_pretest

      ,std.percent_correct AS standard_percent_correct
      ,std.mastered AS standard_mastered

      ,CAST(s.custom_code AS NVARCHAR(128)) AS standard_code
      ,CAST(s.[description] AS NVARCHAR(2048)) AS standard_description

      ,CAST(COALESCE(ps2.state_num, ps.state_num) AS NVARCHAR(128)) AS standard_strand

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
           ,schoolid
           ,grade_level
           ,assessment_id
           ,assessment_title
           ,time_per_name
           ,administration_round
           ,administered_at
           ,subject_area
           ,number_of_questions
           ,overall_number_correct
           ,overall_percent_correct
           ,overall_performance_band
           ,scale_score

           ,LAG(scale_score, 1) OVER(
              PARTITION BY student_number, academic_year, subject_area 
              ORDER BY administered_at
            ) AS prev_scale_score
           ,MAX(CASE WHEN administration_round = 'Pre-Test' THEN scale_score END) OVER(
              PARTITION BY student_number, academic_year, subject_area
            ) AS pretest_scale_score
           ,CASE WHEN administration_round = 'Pre-Test' THEN NULL ELSE scale_score END 
              - MAX(CASE WHEN administration_round = 'Pre-Test' THEN scale_score END) OVER(
                  PARTITION BY student_number, academic_year, subject_area
                )
              AS growth_from_pretest
     FROM overall_scores
    ) sub
LEFT JOIN gabby.illuminate_dna_assessments.agg_student_responses_standard std
  ON sub.assessment_id = std.assessment_id
 AND sub.illuminate_student_id = std.student_id
LEFT JOIN gabby.illuminate_standards.standards s
  ON std.standard_id = s.standard_id
LEFT JOIN gabby.illuminate_standards.standards ps
  ON s.parent_standard_id = ps.standard_id
LEFT JOIN gabby.illuminate_standards.standards ps2
  ON ps.parent_standard_id = ps2.standard_id
