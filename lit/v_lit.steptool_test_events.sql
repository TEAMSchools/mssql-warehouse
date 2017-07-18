USE gabby
GO

ALTER VIEW lit.steptool_test_events AS

SELECT CONCAT('UC', gabby.utilities.DATE_TO_SY(step.date), step.[_line]) AS unique_id      
      ,CONVERT(INT,CONVERT(FLOAT,step.student_id)) AS student_number      
      ,gabby.utilities.DATE_TO_SY(step.date) AS academic_year      
      ,CONVERT(DATE,step.date) AS test_date
      ,CASE WHEN step.step = 0 THEN 'Pre' ELSE CONVERT(VARCHAR,step.step) END AS read_lvl
      ,step.step AS lvl_num            
      ,CASE 
        WHEN step.passed = 1 THEN 'Achieved'
        WHEN step.passed = 0 THEN 'Did Not Achieve'
       END AS status                 
      ,CASE               
        WHEN CONVERT(INT,step.step) = 0 THEN 3280
        WHEN CONVERT(INT,step.step) = 1 THEN 3281
        WHEN CONVERT(INT,step.step) = 2 THEN 3282
        WHEN CONVERT(INT,step.step) = 3 THEN 3380
        WHEN CONVERT(INT,step.step) = 4 THEN 3397
        WHEN CONVERT(INT,step.step) = 5 THEN 3411
        WHEN CONVERT(INT,step.step) = 6 THEN 3425
        WHEN CONVERT(INT,step.step) = 7 THEN 3441
        WHEN CONVERT(INT,step.step) = 8 THEN 3458
        WHEN CONVERT(INT,step.step) = 9 THEN 3474
        WHEN CONVERT(INT,step.step) = 10 THEN 3493
        WHEN CONVERT(INT,step.step) = 11 THEN 3511
        WHEN CONVERT(INT,step.step) = 12 THEN 3527
       END AS ps_testid
      ,step.book AS color                  
      ,step.notes
      ,step.Recorder AS recorder

      ,gleq.gleq      
      
      ,co.studentid
      ,co.lastfirst      
      ,co.schoolid
      ,co.grade_level      

      ,dt.time_per_name AS test_round
      ,CASE
        /* ES */
        WHEN dt.time_per_name = 'DR' THEN 1
        WHEN dt.time_per_name = 'Q1' THEN 2
        WHEN dt.time_per_name = 'Q2' THEN 3
        WHEN dt.time_per_name = 'Q3' THEN 4
        WHEN dt.time_per_name = 'Q4' THEN 5
        /* MS */
        WHEN dt.time_per_name = 'BOY' THEN 1
        WHEN dt.time_per_name = 'MOY' THEN 2
        WHEN dt.time_per_name = 'EOY' THEN 3
       END AS round_num     
FROM gabby.steptool.all_steps step
JOIN gabby.lit.gleq
  ON step.step = gleq.lvl_num
 AND gleq.testid != 3273
JOIN gabby.powerschool.cohort_identifiers_static co
  ON CONVERT(INT,CONVERT(FLOAT,step.student_id)) = co.student_number
 AND gabby.utilities.DATE_TO_SY(CONVERT(DATE,step.date)) = co.academic_year
 AND co.rn_year = 1
JOIN gabby.reporting.reporting_terms dt
  ON co.schoolid = dt.schoolid
 AND CONVERT(DATE,step.date) BETWEEN dt.start_date AND dt.end_date
 AND dt.identifier = 'LIT'

UNION ALL

/* ACHIEVED PRE DNA */
SELECT CONCAT('UC', gabby.utilities.DATE_TO_SY(step.date), step.[_line]) AS unique_id      
      ,CONVERT(INT,CONVERT(FLOAT,step.student_id)) AS student_number      
      ,gabby.utilities.DATE_TO_SY(step.date) AS academic_year      
      ,CONVERT(DATE,step.date) AS test_date
      
      ,'Pre DNA' AS read_lvl
      ,-1 AS lvl_num            
      ,'Achieved' AS status                 
      ,3280 AS ps_testid      
      
      ,step.book AS color                  
      ,step.notes
      ,step.Recorder AS recorder

      ,-1 AS gleq
      
      ,co.studentid
      ,co.lastfirst      
      ,co.schoolid
      ,co.grade_level      

      ,dt.time_per_name AS test_round
      ,CASE
        /* ES */
        WHEN dt.time_per_name = 'DR' THEN 1
        WHEN dt.time_per_name = 'Q1' THEN 2
        WHEN dt.time_per_name = 'Q2' THEN 3
        WHEN dt.time_per_name = 'Q3' THEN 4
        WHEN dt.time_per_name = 'Q4' THEN 5
        /* MS */
        WHEN dt.time_per_name = 'BOY' THEN 1
        WHEN dt.time_per_name = 'MOY' THEN 2
        WHEN dt.time_per_name = 'EOY' THEN 3
       END AS round_num     
FROM gabby.steptool.all_steps step
JOIN gabby.powerschool.cohort_identifiers_static co
  ON CONVERT(INT,CONVERT(FLOAT,step.student_id)) = co.student_number
 AND gabby.utilities.DATE_TO_SY(CONVERT(DATE,step.date)) = co.academic_year
 AND co.rn_year = 1
JOIN gabby.reporting.reporting_terms dt
  ON co.schoolid = dt.schoolid
 AND CONVERT(DATE,step.date) BETWEEN dt.start_date AND dt.end_date
 AND dt.identifier = 'LIT'
WHERE step.step = 0
  AND step.passed = 0