USE gabby
GO

CREATE OR ALTER VIEW naviance.act_scores_clean AS

SELECT naviance_studentid	
      ,student_number	
      ,test_type	
      ,academic_year
      ,test_date	
      ,composite	
      ,english	
      ,math	
      ,reading	
      ,science	
      ,writing	
      ,ela	
      ,writing_sub	
      ,comb_eng_write	
      ,stem
      
      ,ROW_NUMBER() OVER(
          PARTITION BY student_number
              ORDER BY composite DESC) AS rn_highest
      ,ROW_NUMBER() OVER(
          PARTITION BY student_number
              ORDER BY test_date ASC) AS n_attempt
      ,ROW_NUMBER() OVER(
          PARTITION BY student_number, academic_year
              ORDER BY test_date ASC) AS n_attempt_year
FROM
    (
     SELECT sub1.naviance_studentid
           ,sub1.student_number
           ,sub1.test_type
           ,sub1.composite
           ,sub1.english
           ,sub1.math
           ,sub1.reading
           ,sub1.science
           ,sub1.writing
           ,sub1.writing_sub
           ,sub1.comb_eng_write
           ,sub1.ela
           ,sub1.stem
           
           ,gabby.utilities.DATE_TO_SY(test_date) AS academic_year
           ,CASE WHEN sub1.test_date <= CONVERT(DATE,GETDATE()) THEN sub1.test_date ELSE NULL END AS test_date
           ,CASE WHEN sub1.composite != ROUND((ISNULL(sub1.english,0) + ISNULL(sub1.math,0) + ISNULL(sub1.reading,0) + ISNULL(sub1.science,0)) / 4, 0) THEN 1 END AS composite_flag
           
           ,ROW_NUMBER() OVER(
              PARTITION BY sub1.student_number, test_date
                  ORDER BY composite DESC) AS dupe_audit
     FROM
         (
          SELECT studentid AS naviance_studentid
                ,hs_student_id AS student_number                
                ,REPLACE(test_type,' (Legacy)','') AS test_type
                
                ,CASE
                  WHEN test_date = '0000-00-00' THEN NULL
                  WHEN RIGHT(test_date,2) = '00' THEN DATEFROMPARTS(LEFT(test_date,4), SUBSTRING(test_date, 6, 2), 01)
                  ELSE CONVERT(DATE,test_date)
                 END AS test_date
                
                ,CASE WHEN composite BETWEEN 1 AND 36 THEN composite END AS composite                
                ,CASE WHEN english BETWEEN 1 AND 36 THEN english END AS english
                ,CASE WHEN math BETWEEN 1 AND 36 THEN math END AS math
                ,CASE WHEN reading BETWEEN 1 AND 36 THEN reading END AS reading
                ,CASE WHEN science BETWEEN 1 AND 36 THEN science END AS science
                ,CASE WHEN writing BETWEEN 1 AND 36 THEN writing END AS writing                
                ,CASE WHEN ela = 0 THEN NULL ELSE ela END AS ela                
                ,CASE WHEN writing_sub BETWEEN 2 AND 12 THEN writing_sub END AS writing_sub                                                
                ,CASE WHEN comb_eng_write = 0 THEN NULL ELSE comb_eng_write END AS comb_eng_write                
                ,CASE WHEN stem = 0 THEN NULL ELSE stem END AS stem
          FROM gabby.naviance.act_scores act           
          WHERE act.test_type LIKE 'ACT%'          
         ) sub1    
   ) sub2