USE gabby
GO

CREATE OR ALTER VIEW extracts.overgrad_standardized_test_scores AS

SELECT stl.contact_c AS [Student ID]
      ,CONVERT(VARCHAR, stl.date_c, 101) AS [Test Date]
      ,CONCAT(
         CASE
          WHEN stl.test_type = 'Advanced Placement' THEN 'AP'
          WHEN stl.test_type = 'SAT' AND stl.score_type LIKE '%pre_2016%' THEN 'Old SAT'
          WHEN stl.test_type = 'SAT' AND stl.score_type NOT LIKE '%essay%' THEN 'New SAT'
          ELSE stl.test_type 
         END
        ,' ' + CASE 
                WHEN stl.test_subject IN ('Composite', 'Total') THEN NULL
                WHEN stl.test_subject = 'EBRW' THEN 'Reading and Writing'
                WHEN stl.test_subject = 'Physics 1' THEN 'Physics 1: Algebra-Based'
                WHEN stl.test_subject = 'Studio Art: 2-D Design Portfolio' THEN 'Studio Art: 2-D Design'
                WHEN stl.test_subject = 'Studio Art: Drawing Portfolio' THEN 'Studio Art: Drawing'
                WHEN stl.test_subject = 'United States History' THEN 'US History'
                ELSE stl.test_subject
               END
       ) AS [Test]
      ,stl.score AS [Score]

      ,ei.hs_account_name AS [High School]

      ,stl.date_c AS test_date_filter
      ,stl.test_type AS test_type_filter
FROM gabby.alumni.standardized_test_long stl
JOIN gabby.alumni.enrollment_identifiers ei
  ON stl.contact_c = ei.student_c
