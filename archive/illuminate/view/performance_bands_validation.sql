CREATE OR ALTER VIEW
  illuminate_dna_assessments.performance_bands_validation AS
SELECT
  *
FROM
  OPENQUERY (
    ILLUMINATE,
    '
  SELECT performance_band_id
  FROM dna_assessments.performance_bands
'
  )
