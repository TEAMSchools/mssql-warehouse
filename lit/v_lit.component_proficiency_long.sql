USE gabby
GO

CREATE OR ALTER VIEW lit.component_proficiency_long AS

WITH illuminate_fp AS (
  SELECT unique_id
        ,student_number
        ,testid
        ,status
        ,field
        ,score           
        ,read_lvl
        ,lvl_num           
  FROM
      (
       SELECT rs.unique_id
             ,rs.student_number             
             ,rs.status      
             ,CONVERT(FLOAT,rs.about_the_text) AS fp_comp_about   
             ,CONVERT(FLOAT,rs.beyond_the_text) AS fp_comp_beyond
             ,CONVERT(FLOAT,rs.within_the_text) AS fp_comp_within
             ,CONVERT(FLOAT,rs.accuracy) AS fp_accuracy
             ,CONVERT(FLOAT,rs.fluency) AS fp_fluency
             ,CONVERT(FLOAT,rs.reading_rate_wpm) AS fp_wpmrate    
             ,CONVERT(FLOAT,rs.comp_overall) AS fp_comp_prof                          
             ,CASE 
               WHEN rs.status = 'Did Not Achieve' THEN rs.instr_lvl_num
               ELSE rs.indep_lvl_num
              END AS lvl_num             
             ,CASE 
               WHEN rs.status = 'Did Not Achieve' THEN rs.instructional_level_tested
               ELSE rs.achieved_independent_level 
              END AS read_lvl
             ,3273 AS testid
       FROM gabby.lit.illuminate_test_events rs       
      ) sub
  UNPIVOT(
    score
    FOR field IN (fp_wpmrate
                 ,fp_fluency
                 ,fp_accuracy
                 ,fp_comp_within
                 ,fp_comp_beyond
                 ,fp_comp_about
                 ,fp_comp_prof)
   ) u
 )

,all_scores AS (
  SELECT rs.unique_id
        ,rs.student_number
        ,rs.testid
        ,CASE WHEN rs.status != '' THEN rs.status END AS status
        ,rs.field
        ,rs.score           
        ,CASE WHEN rs.read_lvl != '' THEN rs.read_lvl END AS read_lvl
        ,rs.lvl_num           
  FROM gabby.lit.powerschool_component_scores_archive rs    

  UNION ALL

  SELECT rs.unique_id
        ,rs.student_id AS student_number      
        ,rs.testid
        ,rs.status
        ,rs.field
        ,rs.score
        ,rs.read_lvl
        ,rs.lvl_num           
  FROM gabby.steptool.component_scores_static rs

  UNION ALL

  SELECT rs.unique_id
        ,rs.student_number           
        ,rs.testid
        ,rs.status
        ,rs.field
        ,rs.score           
        ,rs.read_lvl
        ,rs.lvl_num           
  FROM illuminate_fp rs     
 )

SELECT CONVERT(NVARCHAR(256),sub.unique_id) AS unique_id
      ,sub.testid
      ,sub.student_number
      ,sub.read_lvl
      ,sub.lvl_num
      ,sub.status
      ,sub.domain
      ,sub.subdomain
      ,sub.strand
      ,sub.label
      ,sub.specific_label
      ,CONVERT(NVARCHAR(256),sub.field) AS field
      ,sub.score
      ,sub.benchmark
      ,sub.is_prof
      ,sub.is_dna
      ,CASE
        WHEN sub.label LIKE '%errors%' THEN sub.benchmark - sub.score
        ELSE sub.score - sub.benchmark 
       END AS margin      
      ,CASE 
        WHEN sub.testid != 3273 AND sub.is_prof = 0 THEN 1
        WHEN sub.testid = 3273 AND sub.domain != 'Comprehension' AND sub.is_prof = 0 THEN 1
        WHEN sub.testid = 3273 AND sub.domain = 'Comprehension' AND MIN(sub.is_prof) OVER(PARTITION BY sub.unique_id, sub.domain) = 0 AND sub.score_order = 1 THEN 1
        ELSE 0        
       END AS dna_filter
      ,CASE 
        WHEN sub.testid != 3273 AND sub.is_prof = 0 THEN sub.domain 
        WHEN sub.testid = 3273 AND sub.domain != 'Comprehension' AND sub.is_prof = 0 THEN sub.domain
        WHEN sub.testid = 3273 AND sub.domain = 'Comprehension' AND MIN(sub.is_prof) OVER(PARTITION BY sub.unique_id, sub.domain) = 0 AND sub.score_order = 1 THEN sub.strand
        ELSE NULL 
       END AS dna_reason
FROM 
    (
     SELECT rs.unique_id           
           ,rs.testid
           ,rs.student_number
           ,rs.read_lvl
           ,rs.lvl_num
           ,rs.status                                 
           ,rs.field
           ,rs.score
           
           ,prof.domain
           ,prof.subdomain
           ,prof.strand           
           ,CONVERT(FLOAT,prof.score) AS benchmark
           ,CASE
             WHEN prof.strand LIKE '%overall%' THEN ISNULL(prof.domain + ': ', '') + prof.strand
             ELSE ISNULL(prof.subdomain + ': ', '') + prof.strand 
            END AS label
           ,CASE
             WHEN prof.strand LIKE '%overall%' AND ISNULL(prof.subdomain,'') != '' 
                    THEN ISNULL(prof.domain + ' (', '') + ISNULL(prof.subdomain + '): ', '') + prof.strand
             WHEN prof.strand LIKE '%overall%' AND ISNULL(prof.subdomain,'') = ''
                    THEN ISNULL(prof.domain + ': ', '') + prof.strand
             ELSE ISNULL(prof.subdomain + ': ', '') + prof.strand 
            END AS specific_label
           ,CASE 
             WHEN prof.score IS NULL THEN NULL
             WHEN prof.field_name NOT IN ('ra_errors','accuracy_1a','accuracy_2b','reading_accuracy_2_','reading_accuracy_2_2_') 
              AND rs.score >= CONVERT(FLOAT,prof.score) 
                    THEN 1
             WHEN prof.field_name IN ('ra_errors','accuracy_1a','accuracy_2b','reading_accuracy_2_','reading_accuracy_2_2_') 
               AND rs.score <= CONVERT(FLOAT,prof.score) 
                    THEN 1
             ELSE 0
            END AS is_prof
           ,CASE 
             WHEN prof.score IS NULL THEN NULL
             WHEN prof.field_name NOT IN ('ra_errors','accuracy_1a','accuracy_2b','reading_accuracy_2_','reading_accuracy_2_2_') 
              AND rs.score < CONVERT(FLOAT,prof.score) 
                    THEN 1
             WHEN prof.field_name IN ('ra_errors','accuracy_1a','accuracy_2b','reading_accuracy_2_','reading_accuracy_2_2_') 
              AND rs.score > CONVERT(FLOAT,prof.score) 
                    THEN 1
             ELSE 0
            END AS is_dna
           ,ROW_NUMBER() OVER(
              PARTITION BY rs.unique_id, prof.domain
                ORDER BY rs.score ASC, prof.strand DESC) AS score_order
     FROM all_scores rs
     JOIN gabby.lit.component_proficiency_targets prof
       ON rs.testid = prof.testid
      AND rs.field = prof.field_name
      AND CASE 
           WHEN rs.testid = 3273 THEN rs.lvl_num 
           ELSE prof.lvl_num 
          END = prof.lvl_num
    ) sub