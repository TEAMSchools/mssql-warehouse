USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_mod_standards AS

SELECT asr.local_student_id AS student_number
      ,asr.academic_year
      ,asr.term_administered AS term
      ,ROUND(percent_correct,0) AS percent_correct
      ,CASE
        WHEN asr.subject_area NOT IN ('Text Study','Mathematics') THEN 'Specials'
        ELSE asr.subject_area
       END AS subject_area
      ,CASE
        WHEN asr.subject_area NOT IN ('Text Study','Mathematics') 
               THEN CONCAT(asr.subject_area, ' - ', REPLACE(asr.standard_description,'"',''''))
        ELSE REPLACE(asr.standard_description,'"','''')
       END AS standard_description      
      ,CASE
        WHEN asr.performance_band_number = 5 THEN 'Above Target'
        WHEN asr.performance_band_number = 4 THEN 'Target'
        WHEN asr.performance_band_number = 3 THEN 'Near Target'
        WHEN asr.performance_band_number = 2 THEN 'Below Target'
        WHEN asr.performance_band_number = 1 THEN 'Far Below Target'
       END AS standard_proficiency
      ,asr.response_type
FROM gabby.illuminate_dna_assessments.agg_student_responses_all_current asr
WHERE asr.response_type IN ('S', 'G')
  AND asr.module_type IN ('QA', 'CRQ')
