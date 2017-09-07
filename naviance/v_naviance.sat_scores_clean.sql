USE gabby
GO

ALTER VIEW naviance.sat_scores_clean AS

WITH unioned_tables AS (
  SELECT [student_id]
        ,[hs_student_id]                  
        ,[evidence_based_reading_writing]
        ,[math]              
        ,[total]      
        ,[reading_test]
        ,[writing_test]      
        ,[math_test]
        ,NULL AS writing
        ,NULL AS [essay_subscore]
        ,CONVERT(FLOAT,[math_test]) + CONVERT(FLOAT,[reading_test]) AS [mc_subscore]
        ,DATEFROMPARTS(RIGHT(test_date, 4), LEFT(test_date, CHARINDEX('/',test_date) - 1), 1) AS test_date
  FROM gabby.naviance.sat_scores

  UNION ALL

  SELECT [studentid]
        ,[hs_student_id]            
        ,[verbal]
        ,[math]                    
        ,[total]
        ,NULL AS [reading_test]
        ,[essay_subscore] AS [writing_test]      
        ,NULL AS [math_test]
        ,[writing]
        ,[essay_subscore]
        ,[mc_subscore]
        ,CASE
          WHEN test_date = '0000-00-00' THEN NULL
          WHEN RIGHT(test_date,2) = '00' THEN DATEFROMPARTS(LEFT(test_date,4), SUBSTRING(test_date, 6, 2), 01)
          ELSE CONVERT(DATE,test_date)
         END AS test_date
  FROM gabby.naviance.sat_scores_before_mar_2016
 )

SELECT sub1.nav_studentid
      ,sub1.student_number           
      ,sub1.verbal
      ,sub1.math
      ,sub1.writing
      ,sub1.essay_subscore
      ,sub1.mc_subscore
      ,sub1.math_verbal_total
      ,sub1.all_tests_total
      ,sub1.test_date
      ,sub1.test_date_flag
      ,sub1.total_flag
      ,gabby.utilities.DATE_TO_SY(sub1.test_date) AS academic_year
      ,ROW_NUMBER() OVER(
         PARTITION BY sub1.student_number, test_date
             ORDER BY sub1.test_date) AS dupe_audit
      ,ROW_NUMBER() OVER(
         PARTITION BY student_number
             ORDER BY test_date ASC) AS n_attempt
FROM
    (
     SELECT sat.student_id AS nav_studentid
           ,sat.hs_student_id AS student_number                
           ,CONVERT(DATE,test_date) AS test_date
           ,CASE WHEN sat.test_date > CONVERT(DATE,GETDATE()) THEN 1 END AS test_date_flag
           ,CONVERT(FLOAT,CASE WHEN evidence_based_reading_writing BETWEEN 200 AND 800 THEN evidence_based_reading_writing END) AS verbal
           ,CONVERT(FLOAT,CASE WHEN math BETWEEN 200 AND 800 THEN math END) AS math
           ,CONVERT(FLOAT,CASE WHEN writing BETWEEN 200 AND 800 THEN writing END) AS writing
           ,CASE WHEN essay_subscore = 0 THEN NULL ELSE essay_subscore END AS essay_subscore 
           ,CASE WHEN mc_subscore = 0 THEN NULL ELSE mc_subscore END AS mc_subscore
           ,CONVERT(FLOAT,evidence_based_reading_writing) + CONVERT(FLOAT,math) AS math_verbal_total                
           ,CONVERT(FLOAT,CASE WHEN total < 200 THEN NULL ELSE total END) AS all_tests_total
           ,CASE
             WHEN (ISNULL(CASE WHEN CONVERT(FLOAT,evidence_based_reading_writing) BETWEEN 200 AND 800 THEN CONVERT(FLOAT,evidence_based_reading_writing) END, 0)
                    + ISNULL(CASE WHEN CONVERT(FLOAT,math) BETWEEN 200 AND 800 THEN CONVERT(FLOAT,math) END, 0)
                    + ISNULL(CASE WHEN CONVERT(FLOAT,writing) BETWEEN 200 AND 800 THEN CONVERT(FLOAT,writing) END, 0))
                      != total 
                  THEN 1 
             WHEN total NOT BETWEEN 400 AND 2400 THEN 1
            END AS total_flag                
     FROM unioned_tables sat    
    ) sub1