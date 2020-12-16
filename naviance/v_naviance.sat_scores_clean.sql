USE gabby
GO

CREATE OR ALTER VIEW naviance.sat_scores_clean AS

SELECT sub.nav_studentid
      ,sub.student_number
      ,sub.test_date
      ,sub.sat_scale
      ,sub.is_old_sat
      ,sub.verbal
      ,sub.math
      ,sub.writing
      ,sub.essay_subscore
      ,sub.mc_subscore
      ,sub.math_verbal_total
      ,sub.all_tests_total
      ,sub.test_date_flag
      ,sub.total_flag

      ,gabby.utilities.DATE_TO_SY(sub.test_date) AS academic_year

      ,ROW_NUMBER() OVER(
        PARTITION BY sub.student_number
            ORDER BY sub.all_tests_total DESC) AS rn_highest
      ,ROW_NUMBER() OVER(
         PARTITION BY sub.student_number, test_date
             ORDER BY sub.test_date) AS dupe_audit
      ,ROW_NUMBER() OVER(
         PARTITION BY student_number
             ORDER BY test_date ASC) AS n_attempt
FROM
    (
     SELECT sat.student_id AS nav_studentid
           ,sat.hs_student_id AS student_number
           ,sat.sat_scale
           ,sat.is_old_sat
           ,test_date
           ,CASE WHEN sat.test_date > CONVERT(DATE, GETDATE()) THEN 1 END AS test_date_flag
           ,CASE WHEN evidence_based_reading_writing BETWEEN 200 AND 800 THEN evidence_based_reading_writing END AS verbal
           ,CASE WHEN math BETWEEN 200 AND 800 THEN math END AS math
           ,CASE WHEN writing BETWEEN 200 AND 800 THEN writing END AS writing
           ,CASE WHEN essay_subscore = 0 THEN NULL ELSE essay_subscore END AS essay_subscore
           ,CASE WHEN mc_subscore = 0 THEN NULL ELSE mc_subscore END AS mc_subscore
           ,evidence_based_reading_writing + math AS math_verbal_total
           ,CASE WHEN total < 200 THEN NULL ELSE total END AS all_tests_total
           ,CASE
             WHEN (ISNULL(CASE WHEN evidence_based_reading_writing BETWEEN 200 AND 800 THEN evidence_based_reading_writing END, 0)
                    + ISNULL(CASE WHEN math BETWEEN 200 AND 800 THEN math END, 0)
                    + ISNULL(CASE WHEN writing BETWEEN 200 AND 800 THEN writing END, 0)) <> total
                  THEN 1
             WHEN total NOT BETWEEN 400 AND 2400 THEN 1
            END AS total_flag
     FROM (
           SELECT CONVERT(INT, [student_id]) AS student_id
                 ,CONVERT(INT, [hs_student_id]) AS hs_student_id
                 ,CONVERT(FLOAT, [evidence_based_reading_writing]) AS evidence_based_reading_writing
                 ,CONVERT(FLOAT, [math]) AS math
                 ,CONVERT(FLOAT, [total]) AS total
                 ,CONVERT(FLOAT, [reading_test]) AS reading_test
                 ,CONVERT(FLOAT, [writing_test]) AS writing_test
                 ,CONVERT(FLOAT, [math_test]) AS math_test
                 ,NULL AS writing
                 ,NULL AS essay_subscore
                 ,CONVERT(FLOAT, [math_test]) + CONVERT(FLOAT, [reading_test]) AS mc_subscore
                 ,DATEFROMPARTS(RIGHT(test_date, 4), LEFT(test_date, CHARINDEX('/', test_date) - 1), 1) AS test_date
                 ,1600 AS sat_scale
                 ,0 AS is_old_sat
           FROM gabby.naviance.sat_scores

           UNION ALL

           SELECT CONVERT(INT, [studentid]) AS student_id
                 ,CONVERT(INT, [hs_student_id]) AS hs_student_id
                 ,CONVERT(FLOAT, [verbal])
                 ,CONVERT(FLOAT, [math])
                 ,CONVERT(FLOAT, [total])
                 ,NULL AS [reading_test]
                 ,CONVERT(FLOAT, [essay_subscore]) AS writing_test
                 ,NULL AS [math_test]
                 ,CONVERT(FLOAT, [writing])
                 ,CONVERT(FLOAT, [essay_subscore])
                 ,CONVERT(FLOAT, [mc_subscore])
                 ,CASE
                   WHEN test_date = '0000-00-00' THEN NULL
                   WHEN RIGHT(test_date, 2) = '00' THEN DATEFROMPARTS(LEFT(test_date, 4), SUBSTRING(test_date, 6, 2), 01)
                   ELSE CONVERT(DATE, test_date)
                  END AS test_date
                 ,2400 AS sat_scale
                 ,1 AS is_old_sat
           FROM gabby.naviance.sat_scores_before_mar_2016
          ) sat
    ) sub
