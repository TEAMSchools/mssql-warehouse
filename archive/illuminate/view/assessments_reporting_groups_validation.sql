CREATE OR ALTER VIEW
  illuminate_dna_assessments.assessments_reporting_groups_validation AS
SELECT
  *
FROM
  OPENQUERY (
    ILLUMINATE,
    '
  SELECT assessment_reporting_group_id
  FROM dna_assessments.assessments_reporting_groups
'
  )
