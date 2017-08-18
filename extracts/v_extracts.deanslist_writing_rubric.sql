USE gabby
GO

ALTER VIEW extracts.deanslist_writing_rubric AS

SELECT student_number
      ,academic_year
      ,composition_type
      ,rubric_type
      ,rubric_strand
      ,[M1]
      ,[M2]
      ,[M3]
      ,[M4]
      ,[M5]
FROM
    (
     SELECT asr.local_student_id AS student_number                                                 
           ,asr.academic_year           
           ,asr.module_number AS module_num
           ,asr.standard_code
           ,REPLACE(asr.standard_description,'"','''') AS rubric_strand
           ,CASE
             WHEN asr.standard_code LIKE 'TES.W.KIPP.N%' THEN 'Narrative'
             WHEN asr.standard_code LIKE 'TES.W.KIPP.C%' THEN 'Expository'
             WHEN asr.standard_code LIKE 'TES.W.KIPP.L%' THEN 'Expository'
            END AS composition_type
           ,CASE
             WHEN asr.standard_code = 'TES.W.KIPP.C.G' THEN 'Language'
             WHEN asr.standard_code LIKE 'TES.W.KIPP.N%' THEN 'Narrative'
             WHEN asr.standard_code LIKE 'TES.W.KIPP.C%' THEN 'Content'
             WHEN asr.standard_code LIKE 'TES.W.KIPP.L%' THEN 'Language'
            END AS rubric_type

           ,std.subject_id

           ,CASE
             WHEN asrs.answered = 0 THEN NULL 
             ELSE asrs.points 
            END AS rubric_score                      
     FROM gabby.illuminate_dna_assessments.agg_student_responses_all asr
     JOIN gabby.illuminate_public.students s
       ON asr.local_student_id = s.local_student_id
     JOIN gabby.illuminate_standards.standards std
       ON asr.standard_code = std.custom_code         
     JOIN gabby.illuminate_dna_assessments.agg_student_responses_standard asrs
       ON asr.assessment_id = asrs.assessment_id
      AND s.student_id = asrs.student_id
      AND std.standard_id = asrs.standard_id
     WHERE asr.response_type = 'S'
       AND asr.scope = 'Process Piece'
       AND asr.subject_area = 'Writing'
       AND asr.academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1    
    ) sub
PIVOT(
  MAX(rubric_score)
  FOR module_num IN ([M1]
                    ,[M2]
                    ,[M3]
                    ,[M4]
                    ,[M5])
 ) p
WHERE subject_id IN (273, 269, 334)