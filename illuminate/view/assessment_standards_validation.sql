CREATE OR ALTER VIEW
  illuminate_dna_assessments.assessment_standards_validation AS
SELECT
  assessment_id,
  standard_id
FROM
  OPENQUERY (
    ILLUMINATE,
    '
  SELECT assessment_id
        ,standard_id
  FROM dna_assessments.assessment_standards
'
  )
