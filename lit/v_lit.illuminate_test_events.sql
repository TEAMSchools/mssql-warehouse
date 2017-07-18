USE gabby
GO

ALTER VIEW lit.illuminate_test_events AS

WITH clean_data AS (
  SELECT local_student_id AS student_number        
        
        ,CONVERT(DATE,[Date Administered]) AS date_administered        

        ,CONVERT(FLOAT,[About the Text]) AS about_the_text
        ,CONVERT(FLOAT,[Beyond the Text]) AS beyond_the_text
        ,CONVERT(FLOAT,[Within the Text]) AS within_the_text
        ,CONVERT(FLOAT,[Accuracy]) AS accuracy
        ,CONVERT(FLOAT,[Fluency]) AS fluency
        ,CONVERT(FLOAT,[Reading Rate (wpm)]) AS reading_rate_wpm
        
        ,LTRIM(RTRIM([Instructional Level Tested])) AS instructional_level_tested
        ,LTRIM(RTRIM([Rate Proficiency])) AS rate_proficiency
        ,LTRIM(RTRIM([Key Lever])) AS key_lever
        ,LTRIM(RTRIM([Fiction/ Nonfiction])) AS  fiction_nonfiction
        ,LTRIM(RTRIM([Test Administered By])) AS test_administered_by

        ,LEFT(LTRIM(RTRIM(STR([Academic Year]))), 4) AS academic_year        

        ,CONCAT('IL', repository_id, repository_row_id) AS unique_id        

        ,CASE 
          WHEN [Test Round] = 'Diagnostic' THEN 'DR' 
          ELSE [Test Round] 
         END AS test_round
        ,CASE 
          WHEN LEFT(LTRIM(RTRIM(STR([Academic Year]))), 4) <= 2015 THEN 'Mixed' 
          WHEN LTRIM(RTRIM([Status])) LIKE '%Did Not Achieve%' THEN 'Did Not Achieve'
          WHEN LTRIM(RTRIM([Status])) LIKE '%Achieved%' THEN 'Achieved'
          ELSE LTRIM(RTRIM([Status]))
         END AS status        
        ,CASE 
          WHEN LEFT(LTRIM(RTRIM(STR([Academic Year]))), 4) >= 2016 
           AND LTRIM(RTRIM([Status])) LIKE '%Achieved%' 
                 THEN LTRIM(RTRIM([Instructional Level Tested]))
          ELSE LTRIM(RTRIM([Achieved Independent Level]))
         END AS achieved_independent_level
  FROM
      (
       SELECT s.local_student_id
             ,126 AS repository_id
             ,r.repository_row_id
      
             ,r.field_academic_year AS [Academic Year]
             ,r.field_test_round AS [Test Round]
             ,r.field_date_administered AS [Date Administered]
             ,r.field_text_familiarity AS [Instructional Level Tested]
             ,r.field_level_tested AS [Achieved Independent Level]
             ,r.field_pass_fall AS [Status]

             ,r.field_key_lever AS [Key Lever]
             ,r.field_fiction_nonfiction AS [Fiction/ Nonfiction]
             ,r.field_test_administered_by AS [Test Administered By]      

             ,r.field_about_the_text AS [About the Text]
             ,r.field_beyond_the_text AS [Beyond the Text]
             ,r.field_within_the_text AS [Within the Text]
             ,r.field_accuracy_1 AS [Accuracy]                  
             ,r.field_fluency_1 AS [Fluency]      
             ,r.field_reading_rate_wpm AS [Reading Rate (wpm)]
             ,r.field_rate_proficiency AS [Rate Proficiency]      
       FROM gabby.illuminate_dna_repositories.repository_126 r
       JOIN gabby.illuminate_public.students s
         ON r.student_id = s.student_id

       UNION ALL

       SELECT s.local_student_id
             ,169 AS repository_id
             ,r.repository_row_id

             ,r.field_academic_year AS [Academic Year]
             ,r.field_test_round AS [Test Round]
             ,r.field_date_administered AS [Date Administered]      
             ,r.field_text_familiarity AS [Level Tested]      
             ,NULL
             ,r.field_level_tested AS [Status]

             ,r.field_test_administered_by AS [Test Administered By]
             ,r.field_fiction_nonfiction AS [Fiction/ Nonfiction]
             ,r.field_key_lever AS [Key Lever]     

             ,r.field_about_the_text AS [About the Text]
             ,r.field_beyond_the_text AS [Beyond the Text]
             ,r.field_within_the_text AS [Within the Text]
             ,r.field_accuracy_1 AS [Accuracy]
             ,r.field_fluency_1 AS [Fluency]
             ,r.field_reading_rate_wpm AS [Reading Rate (wpm)]
             ,r.field_rate_proficiency AS [Rate Proficiency]
       FROM gabby.illuminate_dna_repositories.repository_169 r
       JOIN gabby.illuminate_public.students s
         ON r.student_id = s.student_id

       UNION ALL

       SELECT s.local_student_id
             ,170 AS repository_id
             ,r.repository_row_id

             ,r.field_academic_year AS [Academic Year]
             ,r.field_test_round AS [Test Round]
             ,r.field_date_administered AS [Date Administered]      
             ,r.field_text_familiarity AS [Level Tested]      
             ,NULL
             ,r.field_level_tested AS [Status]

             ,r.field_test_administered_by AS [Test Administered By]
             ,r.field_fiction_nonfiction AS [Fiction/ Nonfiction]
             ,r.field_key_lever AS [Key Lever]     

             ,r.field_about_the_text AS [About the Text]
             ,r.field_beyond_the_text AS [Beyond the Text]
             ,r.field_within_the_text AS [Within the Text]
             ,r.field_accuracy_1 AS [Accuracy]
             ,r.field_fluency_1 AS [Fluency]
             ,r.field_reading_rate_wpm AS [Reading Rate (wpm)]
             ,r.field_rate_proficiency AS [Rate Proficiency]
       FROM gabby.illuminate_dna_repositories.repository_170 r
       JOIN gabby.illuminate_public.students s
         ON r.student_id = s.student_id
      ) sub
  WHERE CONCAT(repository_id, '_', repository_row_id) IN (SELECT CONCAT(repository_id, '_', repository_row_id) FROM gabby.illuminate_dna_repositories.repository_row_ids)
 )

SELECT cd.unique_id
      ,cd.student_number
      ,cd.academic_year
      ,cd.test_round
      ,cd.date_administered
      ,cd.status
      ,cd.instructional_level_tested
      ,cd.achieved_independent_level
      ,cd.about_the_text
      ,cd.beyond_the_text
      ,cd.within_the_text
      ,CASE 
        WHEN cd.about_the_text IS NULL AND cd.beyond_the_text IS NULL AND cd.within_the_text IS NULL THEN NULL
        ELSE ISNULL(cd.within_the_text,0) + ISNULL(cd.about_the_text,0) + ISNULL(cd.beyond_the_text,0) 
       END AS comp_overall
      ,cd.accuracy
      ,cd.fluency
      ,cd.reading_rate_wpm
      ,cd.rate_proficiency
      ,cd.key_lever
      ,cd.fiction_nonfiction
      ,cd.test_administered_by
      ,CASE
        WHEN test_round = 'BOY' THEN 1
        WHEN test_round = 'MOY' THEN 2
        WHEN test_round = 'EOY' THEN 3
        WHEN test_round = 'DR' THEN 1
        WHEN test_round = 'Q1' THEN 2
        WHEN test_round = 'Q2' THEN 3
        WHEN test_round = 'Q3' THEN 4
        WHEN test_round = 'Q4' THEN 5
       END AS round_num
      
      ,achv.GLEQ
      ,achv.fp_lvl_num AS indep_lvl_num
      ,instr.fp_lvl_num AS instr_lvl_num
FROM clean_data cd
LEFT OUTER JOIN gabby.lit.gleq achv
  ON cd.achieved_independent_level = achv.read_lvl
LEFT OUTER JOIN gabby.lit.gleq instr
  ON cd.instructional_level_tested = instr.read_lvl