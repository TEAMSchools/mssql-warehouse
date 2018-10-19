USE gabby
GO

CREATE OR ALTER VIEW lit.steptool_test_events AS

SELECT sub.unique_id
      ,sub.student_number
      ,sub.academic_year
      ,sub.test_date
      ,sub.read_lvl
      ,sub.lvl_num
      ,sub.status
      ,sub.ps_testid
      ,sub.color
      ,sub.notes
      ,sub.recorder
      ,sub.gleq
      ,sub.gleq_lvl_num

      ,co.studentid
      ,co.lastfirst      
      ,co.schoolid
      ,co.grade_level      

      ,CONVERT(VARCHAR(5),dt.alt_name) AS test_round
      ,CONVERT(INT,RIGHT(dt.time_per_name, 1)) AS round_num     
FROM
    (
     SELECT CONVERT(VARCHAR(25),CONCAT('UC', gabby.utilities.DATE_TO_SY(step.date), step.[_line])) AS unique_id
           ,CONVERT(INT,CONVERT(FLOAT,step.student_id)) AS student_number      
           ,gabby.utilities.DATE_TO_SY(CONVERT(DATE,step.date)) AS academic_year
           ,CONVERT(DATE,step.date) AS test_date
           ,CASE WHEN step.step = 0 THEN 'Pre' ELSE CONVERT(VARCHAR(5),step.step) END AS read_lvl
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
           ,CONVERT(VARCHAR(25),step.book) AS color                  
           ,CONVERT(VARCHAR(1000),step.notes) AS notes
           ,CONVERT(VARCHAR(125),step.recorder) AS recorder

           ,gleq.gleq
           ,CONVERT(INT,gleq.lvl_num) AS gleq_lvl_num
     FROM gabby.steptool.all_steps step
     JOIN gabby.lit.gleq
       ON step.step = gleq.lvl_num
      AND gleq.testid != 3273     

     UNION ALL

     /* ACHIEVED PRE DNA */
     SELECT CONVERT(VARCHAR(25),CONCAT('UC', gabby.utilities.DATE_TO_SY(step.date), step.[_line])) AS unique_id
           ,CONVERT(INT,CONVERT(FLOAT,step.student_id)) AS student_number      
           ,gabby.utilities.DATE_TO_SY(CONVERT(DATE,step.date)) AS academic_year
           ,CONVERT(DATE,step.date) AS test_date      
           ,'Pre DNA' AS read_lvl
           ,-1 AS lvl_num            
           ,'Achieved' AS status                 
           ,3280 AS ps_testid      
           ,CONVERT(VARCHAR(25),step.book) AS color                  
           ,CONVERT(VARCHAR(1000),step.notes) AS notes
           ,CONVERT(VARCHAR(125),step.recorder) AS recorder
           ,-1 AS gleq
           ,-1 AS gleq_lvl_num
     FROM gabby.steptool.all_steps step
     WHERE step.step = 0
       AND step.passed = 0
    ) sub
JOIN gabby.powerschool.cohort_identifiers_static co
  ON sub.student_number = co.student_number
 AND sub.academic_year = co.academic_year
 AND co.rn_year = 1
JOIN gabby.reporting.reporting_terms dt
  ON co.schoolid = dt.schoolid
 AND sub.test_date BETWEEN dt.start_date AND dt.end_date
 AND dt.identifier = 'LIT'
 AND dt._fivetran_deleted = 0