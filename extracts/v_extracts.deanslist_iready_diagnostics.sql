USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_iready_diagnostics AS

SELECT dr.student_id AS student_number
      ,LEFT(dr.academic_year, 4) AS academic_year
      ,dr.percentile
      ,dr.annual_typical_growth_measure
      ,dr.annual_stretch_growth_measure
      ,CASE 
        WHEN dr._file LIKE '%math%' THEN 'Math'
        WHEN dr._file LIKE '%ela%' THEN 'Reading'
       END AS subject_name

      ,di.diagnostic_gain_note_negative_gains_zero_
FROM gabby.iready.diagnostic_results dr
JOIN gabby.iready.diagnostic_and_instruction di
  ON dr.student_id = di.student_id
 AND dr.academic_year = di.academic_year
 AND CASE 
      WHEN dr._file LIKE '%math%' THEN 'Math'
      WHEN dr._file LIKE '%ela%' THEN 'Reading'
     END = di.[subject]
WHERE dr.[start_date] >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)
