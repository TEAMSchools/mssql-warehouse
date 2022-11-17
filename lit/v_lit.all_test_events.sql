USE gabby
GO

CREATE OR ALTER VIEW lit.all_test_events AS

SELECT rs.unique_id AS unique_id
      ,rs.testid
      ,rs.is_fp
      ,rs.academic_year
      ,rs.test_round
      ,rs.round_num
      ,rs.test_date
      ,rs.student_number
      ,rs.[status]
      ,rs.read_lvl
      ,rs.lvl_num
      ,rs.dna_lvl
      ,rs.dna_lvl_num
      ,rs.instruct_lvl
      ,rs.instruct_lvl_num
      ,rs.indep_lvl
      ,rs.indep_lvl_num
      ,rs.GLEQ
      ,rs.gleq_lvl_num
      ,rs.color
      ,rs.genre
      ,rs.fp_wpmrate
      ,rs.fp_keylever
      ,rs.coaching_code
      ,rs.test_administered_by
      ,rs.schoolid

      ,ROW_NUMBER() OVER(
         PARTITION BY rs.student_number, rs.[status], rs.academic_year, rs.test_round
           ORDER BY rs.lvl_num DESC) AS curr_round
      ,ROW_NUMBER() OVER(
         PARTITION BY rs.student_number, rs.academic_year
           ORDER BY rs.round_num DESC, rs.test_date DESC, rs.lvl_num DESC) AS recent_yr 
FROM (
      SELECT CAST(ps.unique_id AS VARCHAR(25)) AS unique_id
            ,CAST(ps.student_number AS INT) AS student_number
            ,CAST(ps.academic_year AS INT) AS academic_year
            ,CAST(ps.test_round AS VARCHAR(5)) AS test_round
            ,CAST(ps.round_num AS INT) AS round_num
            ,ps.test_date
            ,CONVERT(INT ,ps.testid) AS testid
            ,CAST(ps.is_fp AS INT) AS is_fp
            ,CAST(ps.[status] AS VARCHAR(25)) AS [status]
            ,CAST(ps.read_lvl AS VARCHAR(25)) AS read_lvl
            ,CAST(ps.lvl_num AS INT) AS lvl_num
            ,CAST(ps.gleq AS INT) AS gleq
            ,CAST(ps.color AS VARCHAR(25)) AS color
            ,CONVERT(VARCHAR(25) ,ps.genre) AS genre
            ,CAST(ps.dna_lvl AS VARCHAR(5)) AS dna_lvl
            ,CAST(ps.dna_lvl_num AS INT) AS dna_lvl_num
            ,CAST(ps.instruct_lvl AS VARCHAR(5)) AS instruct_lvl
            ,CAST(ps.instruct_lvl_num AS INT) AS instruct_lvl_num
            ,CAST(ps.indep_lvl AS VARCHAR(25)) AS indep_lvl
            ,CAST(ps.indep_lvl_num AS INT) AS indep_lvl_num
            ,NULL AS gleq_lvl_num
            ,CAST(ps.fp_wpmrate AS INT) AS fp_wpmrate
            ,CAST(ps.fp_keylever AS VARCHAR(25)) AS fp_keylever
            ,CAST(ps.coaching_code AS VARCHAR(5)) AS coaching_code
            ,NULL AS test_administered_by        
            ,NULL AS schoolid
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
            ,[status]
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
            ,gleq_lvl_num
            ,NULL AS fp_wpmrate
            ,NULL AS fp_keylever
            ,NULL AS coaching_code
            ,recorder AS test_administered_by
            ,uc.schoolid
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
            ,[status]
            ,CASE 
              WHEN [status] IN ('Mixed', 'Achieved') THEN achieved_independent_level 
              WHEN [status] = 'Did Not Achieve' THEN instructional_level_tested
             END AS read_lvl
            ,CASE
              WHEN [status] IN ('Mixed', 'Achieved') THEN indep_lvl_num
              WHEN [status] = 'Did Not Achieve' THEN instr_lvl_num
             END AS lvl_num
            ,gleq
            ,NULL AS color
            ,fiction_nonfiction AS genre        
            ,instructional_level_tested AS dna_lvl
            ,instr_lvl_num AS dna_lvl_num
            ,instructional_level_tested AS instruct_lvl
            ,instr_lvl_num AS instruct_lvl_num
            ,achieved_independent_level AS indep_lvl
            ,indep_lvl_num 
            ,gleq_lvl_num
        
            ,reading_rate_wpm AS fp_wpmrate
            ,key_lever AS fp_keylever
            ,NULL AS coaching_code
            ,NULL AS test_administered_by
            ,NULL AS schoolid
      FROM gabby.lit.illuminate_test_events ill

      UNION ALL

      SELECT unique_id
            ,student_identifier AS student_number        
            ,academic_year
            ,test_round
            ,round_num
            ,assessment_date AS test_date
            ,testid
            ,is_fp                
            ,[status]
            ,text_level AS read_lvl
            ,lvl_num
            ,gleq
            ,NULL AS color
            ,genre        
            ,dna_lvl
            ,dna_lvl_num
            ,instruct_lvl
            ,instruct_lvl_num
            ,indep_lvl
            ,indep_lvl_num 
            ,gleq_lvl_num        
            ,wpm_rate AS fp_wpmrate
            ,NULL AS fp_keylever
            ,NULL AS coaching_code
            ,test_administered_by
            ,schoolid
      FROM gabby.lit.fpodms_test_events fpodms
     ) rs