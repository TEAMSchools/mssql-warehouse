USE gabby
GO

CREATE OR ALTER VIEW lit.illuminate_test_events AS

WITH clean_data AS (
  SELECT local_student_id
        ,date_administered
        ,about_the_text
        ,beyond_the_text
        ,within_the_text
        ,accuracy
        ,fluency
        ,reading_rate_wpm
        ,instructional_level_tested
        ,rate_proficiency
        ,key_lever
        ,fiction_nonfiction
        ,NULL AS test_administered_by
        ,academic_year        
        ,unique_id
        ,test_round
        ,status
        ,achieved_independent_level
  FROM gabby.lit.illuminate_test_events_current
  WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

  UNION ALL
  
  SELECT CONVERT(INT,student_number) AS student_number
        ,date_administered
        ,CONVERT(INT,about_the_text) AS about_the_text
        ,CONVERT(INT,beyond_the_text) AS beyond_the_text
        ,CONVERT(INT,within_the_text) AS within_the_text
        ,CONVERT(INT,accuracy) AS accuracy
        ,CONVERT(INT,fluency) AS fluency
        ,reading_rate_wpm
        ,CASE WHEN instructional_level_tested != '' THEN CONVERT(VARCHAR(1),instructional_level_tested) END AS instructional_level_tested
        ,CASE WHEN rate_proficiency != '' THEN CONVERT(VARCHAR(25),rate_proficiency) END AS rate_proficiency
        ,CASE WHEN key_lever != '' THEN CONVERT(VARCHAR(25),key_lever) END AS key_lever
        ,CASE WHEN fiction_nonfiction != '' THEN CONVERT(VARCHAR(5),fiction_nonfiction) END AS fiction_nonfiction
        ,NULL AS test_administered_by
        --,CASE WHEN test_administered_by != '' THEN CONVERT(VARCHAR(125),test_administered_by) END AS test_administered_by
        ,CONVERT(INT,academic_year) AS academic_year
        ,CONVERT(VARCHAR(125),unique_id) AS unique_id
        ,CASE WHEN test_round != '' THEN CONVERT(VARCHAR(25),test_round) END AS test_round
        ,CASE WHEN status != '' THEN CONVERT(VARCHAR(25),status) END AS status
        ,CASE WHEN achieved_independent_level != '' THEN CONVERT(VARCHAR(1),achieved_independent_level) END AS achieved_independent_level
  FROM gabby.lit.illuminate_test_events_archive
 )

SELECT cd.unique_id
      ,cd.local_student_id AS student_number
      ,cd.academic_year
      ,cd.test_round
      ,cd.date_administered
      ,cd.status
      ,cd.instructional_level_tested
      ,cd.achieved_independent_level
      ,cd.about_the_text
      ,cd.beyond_the_text
      ,cd.within_the_text      
      ,cd.accuracy
      ,cd.fluency
      ,cd.reading_rate_wpm
      ,cd.rate_proficiency
      ,cd.key_lever
      ,cd.fiction_nonfiction
      ,cd.test_administered_by AS test_administered_by
      ,CASE        
        WHEN cd.academic_year <= 2016 AND cd.test_round = 'BOY' THEN 1
        WHEN cd.academic_year <= 2016 AND cd.test_round = 'MOY' THEN 2
        WHEN cd.academic_year <= 2016 AND cd.test_round = 'EOY' THEN 3
        WHEN cd.academic_year <= 2016 AND cd.test_round = 'DR' THEN 1
        WHEN cd.academic_year <= 2016 AND cd.test_round = 'Q1' THEN 2
        WHEN cd.academic_year <= 2016 AND cd.test_round = 'Q2' THEN 3
        WHEN cd.academic_year <= 2016 AND cd.test_round = 'Q3' THEN 4
        WHEN cd.academic_year <= 2016 AND cd.test_round = 'Q4' THEN 5
        WHEN cd.academic_year >= 2017 AND cd.test_round = 'Q1' THEN 1
        WHEN cd.academic_year >= 2017 AND cd.test_round = 'Q2' THEN 2
        WHEN cd.academic_year >= 2017 AND cd.test_round = 'Q3' THEN 3
        WHEN cd.academic_year >= 2017 AND cd.test_round = 'Q4' THEN 4
       END AS round_num
      ,CASE 
        WHEN cd.about_the_text IS NULL AND cd.beyond_the_text IS NULL AND cd.within_the_text IS NULL THEN NULL
        ELSE ISNULL(cd.within_the_text,0) + ISNULL(cd.about_the_text,0) + ISNULL(cd.beyond_the_text,0) 
       END AS comp_overall
      
      ,achv.gleq
      ,CONVERT(INT,achv.lvl_num) AS gleq_lvl_num
      ,CONVERT(INT,achv.fp_lvl_num) AS indep_lvl_num

      ,CONVERT(INT,instr.fp_lvl_num) AS instr_lvl_num
FROM clean_data cd
LEFT JOIN gabby.lit.gleq achv
  ON cd.achieved_independent_level = achv.read_lvl_clean
LEFT JOIN gabby.lit.gleq instr
  ON cd.instructional_level_tested = instr.read_lvl_clean