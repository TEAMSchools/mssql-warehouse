USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_mod_standards AS

WITH std_avg AS (
  SELECT sub.local_student_id
        ,sub.academic_year
        ,sub.term_administered
        ,sub.response_type
        ,sub.subject_area
        ,sub.standard_description
        ,sub.performance_band_set_id
        ,ROUND(AVG(percent_correct), 0) AS avg_percent_correct
  FROM
      (
       SELECT asr.local_student_id
             ,asr.academic_year
             ,asr.term_administered
             ,asr.response_type
             ,asr.percent_correct
             ,asr.subject_area
             ,asr.performance_band_set_id
             ,REPLACE(asr.standard_description, '"', '''') AS standard_description
       FROM gabby.illuminate_dna_assessments.agg_student_responses_all_current asr
       WHERE asr.response_type IN ('S', 'G')
         AND asr.is_normed_scope = 1
         AND asr.subject_area IN ('Text Study','Mathematics')
      ) sub
  GROUP BY sub.local_student_id
          ,sub.academic_year
          ,sub.term_administered
          ,sub.response_type
          ,sub.subject_area
          ,sub.standard_description
          ,sub.performance_band_set_id
 )

SELECT sa.local_student_id AS student_number
      ,sa.academic_year
      ,sa.term_administered AS term
      ,sa.response_type
      ,sa.avg_percent_correct AS percent_correct
      ,sa.subject_area
      ,sa.standard_description
      ,CASE
        WHEN pbl.label_number = 5 THEN 'Above Target'
        WHEN pbl.label_number = 4 THEN 'Target'
        WHEN pbl.label_number = 3 THEN 'Near Target'
        WHEN pbl.label_number = 2 THEN 'Below Target'
        WHEN pbl.label_number = 1 THEN 'Far Below Target'
       END AS standard_proficiency
FROM std_avg sa
JOIN gabby.illuminate_dna_assessments.performance_band_lookup_static pbl
  ON sa.performance_band_set_id = pbl.performance_band_set_id
 AND sa.avg_percent_correct BETWEEN pbl.minimum_value AND pbl.maximum_value
