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
     SELECT studentid
           ,hs_student_id
           ,test_code
           ,test_name
           ,score
           ,CASE
             WHEN test_date = '0000-00-00' THEN NULL
             WHEN RIGHT(test_date,2) = '00' THEN DATEFROMPARTS(LEFT(test_date,4), SUBSTRING(test_date, 6, 2), 01)
             ELSE CONVERT(DATE,test_date)
            END AS test_date
     FROM gabby.naviance.sat_2_scores
    ) sub