USE gabby
GO

CREATE OR ALTER VIEW naviance.sat_2_scores_clean AS 

SELECT studentid AS naviance_studentid
      ,hs_student_id AS student_number
      ,test_code
      ,test_name
      ,test_date
      ,score
      ,gabby.utilities.DATE_TO_SY(test_date) AS academic_year
FROM
    (
     SELECT CONVERT(INT,studentid) AS studentid
           ,CONVERT(INT,hs_student_id) AS hs_student_id
           ,CONVERT(VARCHAR(5),test_code) AS test_code
           ,CONVERT(VARCHAR(25),test_name) AS test_name
           ,CONVERT(INT,score) AS score
           ,CASE
             WHEN test_date = '0000-00-00' THEN NULL
             WHEN RIGHT(test_date,2) = '00' THEN DATEFROMPARTS(LEFT(test_date,4), SUBSTRING(test_date, 6, 2), 01)
             ELSE CONVERT(DATE,test_date)
            END AS test_date
     FROM gabby.naviance.sat_2_scores
    ) sub