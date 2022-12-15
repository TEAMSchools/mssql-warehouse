USE gabby GO
CREATE OR ALTER VIEW
  extracts.deanslist_iready_diagnostics AS
SELECT
  gm.student_number,
  gm.academic_year,
  gm.[subject],
  gm.recent_percentile,
  gm.progress_typical,
  gm.progress_stretch
FROM
  gabby.iready.growth_metrics AS gm
WHERE
  gm.academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1
