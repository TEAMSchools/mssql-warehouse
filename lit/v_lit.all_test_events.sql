USE gabby
GO

ALTER VIEW lit.all_test_events AS

SELECT CONVERT(NVARCHAR(64),rs.unique_id) AS unique_id
      ,rs.testid
      ,rs.is_fp
      ,rs.academic_year
      ,rs.test_round
      ,rs.round_num
      ,rs.test_date      
      ,rs.student_number      
      ,rs.status
      ,rs.read_lvl
      ,rs.lvl_num
      ,rs.dna_lvl
      ,rs.dna_lvl_num
      ,rs.instruct_lvl
      ,rs.instruct_lvl_num
      ,rs.indep_lvl
      ,rs.indep_lvl_num
      ,rs.GLEQ
      ,rs.color
      ,rs.genre
      ,rs.fp_wpmrate
      ,rs.fp_keylever
      ,rs.coaching_code
      ,rs.test_administered_by

      ,ROW_NUMBER() OVER(
         PARTITION BY rs.student_number, rs.status, rs.academic_year, rs.test_round
           ORDER BY rs.lvl_num DESC) AS curr_round
      ,ROW_NUMBER() OVER(
         PARTITION BY rs.student_number, rs.academic_year
           ORDER BY rs.round_num DESC, rs.test_date DESC, rs.lvl_num DESC) AS recent_yr 
FROM (
      SELECT ps.unique_id
            ,ps.student_number        
            ,ps.academic_year
            ,ps.test_round
            ,ps.round_num
            ,ps.test_date
            ,ps.testid
            ,ps.is_fp                
            ,ps.status
            ,ps.read_lvl
            ,ps.lvl_num
            ,ps.GLEQ
            ,ps.color
            ,ps.genre        
            ,ps.dna_lvl
            ,ps.dna_lvl_num
            ,ps.instruct_lvl
            ,ps.instruct_lvl_num
            ,ps.indep_lvl
            ,ps.indep_lvl_num                      
            ,ps.fp_wpmrate
            ,ps.fp_keylever
            ,ps.coaching_code
            ,NULL AS test_administered_by        
      FROM gabby.lit.powerschool_test_events_archive ps  

      UNION ALL

      SELECT unique_id
            ,student_number
            ,academic_year
            ,test_round
            ,round_num
            ,test_date        
            ,ps_testid AS testid
            ,0 AS is_fp        
            ,status
            ,read_lvl
            ,lvl_num
            ,GLEQ
            ,color
            ,NULL AS genre
            ,NULL AS dna_lvl
            ,NULL AS dna_lvl_num
            ,NULL AS instruct_lvl
            ,NULL AS instruct_lvl_num
            ,NULL AS indep_lvl
            ,NULL AS indep_lvl_num              
            ,NULL AS fp_wpmrate
            ,NULL AS fp_keylever
            ,NULL AS coaching_code
            ,recorder AS test_administered_by
      FROM gabby.lit.steptool_test_events uc

      UNION ALL

      SELECT unique_id
            ,student_number        
            ,academic_year
            ,test_round
            ,round_num
            ,date_administered AS test_date
            ,3273 AS testid
            ,1 AS is_fp                
            ,status
            ,CASE 
              WHEN status IN ('Mixed','Achieved') THEN achieved_independent_level 
              WHEN status = 'Did Not Achieve' THEN instructional_level_tested
             END AS read_lvl
            ,CASE
              WHEN status IN ('Mixed','Achieved') THEN indep_lvl_num
              WHEN status = 'Did Not Achieve' THEN instr_lvl_num
             END AS lvl_num
            ,GLEQ
            ,NULL AS color
            ,fiction_nonfiction AS genre        
        
            ,instructional_level_tested AS dna_lvl
            ,instr_lvl_num AS dna_lvl_num
            ,instructional_level_tested AS instruct_lvl
            ,instr_lvl_num AS instruct_lvl_num
            ,achieved_independent_level AS indep_lvl
            ,indep_lvl_num 
        
            ,reading_rate_wpm AS fp_wpmrate
            ,key_lever AS fp_keylever
            ,NULL AS coaching_code
            ,test_administered_by
      FROM gabby.lit.illuminate_test_events ill
     ) rs