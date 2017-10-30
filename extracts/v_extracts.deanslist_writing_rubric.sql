USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_writing_rubric AS

SELECT student_number
      ,academic_year
      ,composition_type
      ,rubric_type
      ,rubric_strand
      ,[QA1]
      ,[QA2]
      ,[QA3]
      ,[QA4]
      ,[QA5]
FROM
    (     
     SELECT (a.academic_year - 1) AS academic_year
           ,CASE
             WHEN PATINDEX('%[MU][0-9]/[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%[MU][0-9]/[0-9]%', a.title), 4)
             WHEN PATINDEX('%QA[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%QA[0-9]%', a.title), 3)
             WHEN PATINDEX('%[MU][0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%[MU][0-9]%', a.title), 2)
            END AS module_num
  
           ,std.custom_code AS standard_code           
           ,REPLACE(std.description,'"','''') AS rubric_strand           
           ,CASE
             WHEN std.custom_code LIKE 'TES.W.KIPP.N%' THEN 'Narrative'
             WHEN std.custom_code LIKE 'TES.W.KIPP.C%' THEN 'Expository'
             WHEN std.custom_code LIKE 'TES.W.KIPP.L%' THEN 'Expository'
            END AS composition_type
           ,CASE
             WHEN std.custom_code = 'TES.W.KIPP.C.G' THEN 'Language'
             WHEN std.custom_code LIKE 'TES.W.KIPP.N%' THEN 'Narrative'
             WHEN std.custom_code LIKE 'TES.W.KIPP.C%' THEN 'Content'
             WHEN std.custom_code LIKE 'TES.W.KIPP.L%' THEN 'Language'
            END AS rubric_type                      
           
           ,CASE
             WHEN asrs.answered = 0 THEN NULL 
             ELSE asrs.points 
            END AS rubric_score                      

          ,s.local_student_id AS student_number
     FROM gabby.illuminate_dna_assessments.assessments a
     JOIN gabby.illuminate_codes.dna_scopes dsc
       ON a.code_scope_id = dsc.code_id
      AND dsc.code_translation = 'Process Piece'
     JOIN gabby.illuminate_codes.dna_subject_areas dsu
       ON a.code_subject_area_id = dsu.code_id
      AND dsu.code_translation = 'Writing'
     JOIN gabby.illuminate_dna_assessments.assessment_standards ast
       ON a.assessment_id = ast.assessment_id      
     JOIN gabby.illuminate_standards.standards std
       ON ast.standard_id = std.standard_id
      AND std.subject_id IN (273, 269, 334)
     JOIN gabby.illuminate_dna_assessments.agg_student_responses_standard asrs
       ON ast.assessment_id = asrs.assessment_id
      AND ast.standard_id = asrs.standard_id
      AND asrs.student_assessment_id NOT IN (SELECT student_assessment_id FROM gabby.illuminate_dna_assessments.students_assessments_archive)
     JOIN gabby.illuminate_public.students s
       ON asrs.student_id = s.student_id
     WHERE (a.academic_year - 1) = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
    ) sub
PIVOT(
  MAX(rubric_score)
  FOR module_num IN ([QA1]
                    ,[QA2]
                    ,[QA3]
                    ,[QA4]
                    ,[QA5])
 ) p