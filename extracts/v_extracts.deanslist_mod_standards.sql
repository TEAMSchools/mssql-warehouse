USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_mod_standards AS

WITH std_avg AS (
  SELECT asr.local_student_id
        ,asr.academic_year
        ,asr.term_administered
        ,asr.response_type
        ,asr.subject_area
        ,asr.performance_band_set_id
        ,asr.standard_description
        ,ROUND(AVG(asr.percent_correct), 0) AS avg_percent_correct
  FROM gabby.illuminate_dna_assessments.agg_student_responses_all_current asr
  WHERE asr.response_type IN ('S', 'G')
    AND asr.is_normed_scope = 1
    AND asr.subject_area IN ('Text Study','Mathematics')
  GROUP BY asr.local_student_id
          ,asr.academic_year
          ,asr.term_administered
          ,asr.response_type
          ,asr.subject_area
          ,asr.standard_description
          ,asr.performance_band_set_id
 )

SELECT sa.local_student_id AS student_number
      ,sa.academic_year
      ,sa.term_administered AS term
      ,sa.response_type
      ,sa.avg_percent_correct AS percent_correct
      ,sa.subject_area
      ,REPLACE(sa.standard_description, '"', '''') AS standard_description

      ,CASE
        WHEN pbl.label_number = 5 THEN 'Advanced Mastery'
        WHEN pbl.label_number = 4 THEN 'Mastery'
        WHEN pbl.label_number = 3 THEN 'Approaching Mastery'
        WHEN pbl.label_number = 2 THEN 'Below Mastery'
        WHEN pbl.label_number = 1 THEN 'Far Below Mastery'
       END AS standard_proficiency
FROM std_avg sa
INNER JOIN gabby.illuminate_dna_assessments.performance_band_lookup_static pbl
  ON sa.performance_band_set_id = pbl.performance_band_set_id
 AND sa.avg_percent_correct BETWEEN pbl.minimum_value AND pbl.maximum_value
