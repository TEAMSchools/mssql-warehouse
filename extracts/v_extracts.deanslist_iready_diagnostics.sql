USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_iready_diagnostics AS

SELECT di.student_id AS student_number
      ,LEFT(di.academic_year, 4) AS academic_year
      ,di.diagnostic_percentile_most_recent_ AS percentile
      ,di.annual_typical_growth_measure
      ,di.annual_stretch_growth_measure
      ,di.[subject] AS subject_name
      ,di.diagnostic_gain_note_negative_gains_zero_
FROM gabby.iready.diagnostic_and_instruction di
WHERE di.diagnostic_completion_date_most_recent_ >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)
