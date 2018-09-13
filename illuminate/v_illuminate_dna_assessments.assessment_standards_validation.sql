USE gabby
GO

CREATE OR ALTER VIEW illuminate_dna_assessments.assessment_standards_validation AS 

SELECT CONVERT(VARCHAR(250),CONCAT(assessment_id, '_',standard_id)) AS row_hash
FROM OPENQUERY(ILLUMINATE, '
  SELECT assessment_id
        ,standard_id
  FROM dna_assessments.assessment_standards
')