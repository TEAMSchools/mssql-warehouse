USE gabby
GO

CREATE OR ALTER VIEW extracts.cpn_lit_benchmarks AS

SELECT student_number
      ,academic_year
      ,reporting_term
      ,lit_term_start_date
      ,lit_term_end_date
      ,unique_id
      ,is_fp
      ,test_date      
      ,read_lvl
      ,lvl_num
      ,gleq      
      ,goal_lvl
      ,goal_num
      ,met_goal            
      ,color
      ,genre
      ,fp_keylever            
FROM gabby.tableau.lit_tracker
WHERE rn_test = 1
  AND region = 'KCNA'
  AND unique_id IS NOT NULL