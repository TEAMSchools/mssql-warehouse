USE gabby
GO

CREATE OR ALTER VIEW illuminate_dna_assessments.normed_scopes AS 

SELECT 'CMA - End-of-Module' AS scope UNION
SELECT 'CMA - Mid-Module' UNION
SELECT 'Checkpoint' UNION
SELECT 'CGI Quiz' UNION
SELECT 'Cold Read Quizzes' UNION
SELECT 'Cumulative Review Quizzes' UNION
SELECT 'Math Facts and Counting Jar'