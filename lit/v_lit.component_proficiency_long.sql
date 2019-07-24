USE gabby
GO

CREATE OR ALTER VIEW lit.component_proficiency_long AS

WITH illuminate_fp AS (
  SELECT unique_id
        ,student_number
        ,testid
        ,status
        ,CONVERT(VARCHAR(25),field) AS field
        ,score           
        ,read_lvl
        ,lvl_num           
  FROM
      (
       SELECT rs.unique_id
             ,rs.student_number             
             ,rs.status      
             ,rs.about_the_text AS fp_comp_about   
             ,rs.beyond_the_text AS fp_comp_beyond
             ,rs.within_the_text AS fp_comp_within
             ,rs.accuracy AS fp_accuracy
             ,rs.fluency AS fp_fluency
             ,rs.reading_rate_wpm AS fp_wpmrate    
             ,rs.comp_overall AS fp_comp_prof                          
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

       UNION ALL

       SELECT rs.unique_id
             ,rs.student_identifier AS student_number             
             ,rs.status      
             ,rs.comprehension_about AS fp_comp_about   
             ,rs.comprehension_beyond AS fp_comp_beyond
             ,rs.comprehension_within AS fp_comp_within
             ,rs.accuracy_percent AS fp_accuracy
             ,rs.fluency AS fp_fluency
             ,rs.wpm_rate AS fp_wpmrate    
             ,rs.comprehension_total AS fp_comp_prof                          
             ,rs.lvl_num             
             ,rs.text_level AS read_lvl
             ,rs.testid
       FROM gabby.lit.fpodms_test_events rs       
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
  SELECT CONVERT(VARCHAR(25),rs.unique_id) AS unique_id
        ,CONVERT(INT,rs.student_number) AS student_number
        ,CONVERT(INT,rs.testid) AS testid
        ,CASE WHEN rs.status != '' THEN CONVERT(VARCHAR(25),rs.status) END AS status
        ,CONVERT(VARCHAR(25),rs.field) AS field
        ,CONVERT(FLOAT,rs.score) AS score
        ,CASE WHEN rs.read_lvl != '' THEN CONVERT(VARCHAR(5),rs.read_lvl) END AS read_lvl
        ,CONVERT(INT,rs.lvl_num) AS lvl_num
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

,prof_clean AS (
  SELECT CONVERT(INT,testid) AS testid
        ,CONVERT(INT,lvl_num) AS lvl_num
        ,CONVERT(VARCHAR(125),field_name) AS field_name
        ,CONVERT(VARCHAR(25),domain) AS domain
        ,CONVERT(VARCHAR(25),subdomain) AS subdomain
        ,CONVERT(VARCHAR(125),strand) AS strand
        ,CONVERT(INT,score) AS score
  FROM gabby.lit.component_proficiency_targets
)

SELECT sub.unique_id
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
      ,sub.field
      ,sub.score
      ,sub.benchmark
      ,sub.is_prof
      ,ABS(sub.is_prof - 1) AS is_dna
      ,sub.score - sub.benchmark AS margin
      ,CASE 
        WHEN sub.testid != 3273 
         AND sub.is_prof = 0 
             THEN 1
        WHEN sub.testid = 3273 
         AND sub.domain != 'Comprehension' 
         AND sub.is_prof = 0
             THEN 1
        WHEN sub.testid = 3273 
         AND sub.domain = 'Comprehension' 
         AND MIN(sub.is_prof) OVER(PARTITION BY sub.unique_id, sub.domain) = 0 
         AND sub.score_order = 1 
             THEN 1
        ELSE 0
       END AS dna_filter
      ,CASE
        WHEN sub.testid != 3273 
         AND sub.is_prof = 0 
             THEN sub.domain 
        WHEN sub.testid = 3273 
         AND sub.domain != 'Comprehension' 
         AND sub.is_prof = 0 
             THEN sub.domain
        WHEN sub.testid = 3273 
         AND sub.domain = 'Comprehension' 
         AND MIN(sub.is_prof) OVER(PARTITION BY sub.unique_id, sub.domain) = 0 
         AND sub.score_order = 1 
             THEN sub.strand
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
           ,prof.score AS benchmark
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
             WHEN rs.score >= prof.score THEN 1
             ELSE 0
            END AS is_prof

           ,ROW_NUMBER() OVER(
              PARTITION BY rs.unique_id, prof.domain
                ORDER BY rs.score ASC, prof.strand DESC) AS score_order
     FROM all_scores rs
     JOIN prof_clean prof
       ON rs.testid = prof.testid
      AND rs.field = prof.field_name
      AND rs.lvl_num = prof.lvl_num
    ) sub