USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_mod_assessment AS

SELECT asr.local_student_id AS student_number
      ,asr.academic_year      
      ,asr.module_number AS module_num      
      ,asr.module_type AS scope
      ,asr.percent_correct
      ,CASE
        WHEN asr.subject_area = 'Text Study' THEN 'ELA'
        WHEN asr.subject_area = 'Mathematics' THEN 'MATH'               
        ELSE asr.subject_area
       END AS subject_area                                    
      ,asr.subject_area AS subject_area_label
      ,CASE
        WHEN asr.performance_band_number = 5 THEN 'Above Target'
        WHEN asr.performance_band_number = 4 THEN 'Target'
        WHEN asr.performance_band_number = 3 THEN 'Near Target'
        WHEN asr.performance_band_number = 2 THEN 'Below Target'
        WHEN asr.performance_band_number = 1 THEN 'Far Below Target'
       END AS proficiency_label
      ,SUBSTRING(asr.module_number, PATINDEX('%[0-9]%', asr.module_number), 1) AS rn_unit
FROM gabby.illuminate_dna_assessments.agg_student_responses_all asr
WHERE asr.module_type = 'QA'
  AND asr.subject_area IN ('Text Study','Mathematics')
  AND asr.response_type = 'O'
  AND asr.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND asr.administered_at <= CONVERT(DATE,GETDATE())