USE gabby GO
CREATE OR ALTER VIEW
  illuminate_dna_assessments.fields_validation AS
SELECT
  *
FROM
  OPENQUERY (
    ILLUMINATE,
    '
  SELECT field_id
  FROM dna_assessments.fields
'
  )
