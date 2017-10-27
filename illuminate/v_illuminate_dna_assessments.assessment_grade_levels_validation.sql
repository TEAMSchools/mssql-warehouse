USE gabby
GO

CREATE OR ALTER VIEW illuminate_dna_assessments.assessment_grade_levels_validation AS 

SELECT *
FROM OPENQUERY(ILLUMINATE,'
  SELECT assessment_grade_level_id
  FROM dna_assessments.assessment_grade_levels
')