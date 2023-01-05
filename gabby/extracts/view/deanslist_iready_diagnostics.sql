CREATE OR ALTER VIEW
  extracts.deanslist_iready_diagnostics AS
SELECT
  student_number,
  academic_year,
  [subject],
  recent_percentile,
  progress_typical,
  progress_stretch
FROM
  iready.growth_metrics
WHERE
  academic_year >= utilities.GLOBAL_ACADEMIC_YEAR () - 1
