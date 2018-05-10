USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_writing_rubric AS

SELECT student_number
      ,academic_year
      ,NULL AS composition_type
      ,NULL AS rubric_type
      ,rubric_strand
      ,[QA1]
      ,[QA2]
      ,[QA3]
      ,[QA4]
FROM
    (     
     SELECT a.academic_year_clean AS academic_year
           ,CASE
             WHEN PATINDEX('%[MU][0-9]/[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%[MU][0-9]/[0-9]%', a.title), 4)
             WHEN PATINDEX('%QA[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%QA[0-9]%', a.title), 3)
             WHEN PATINDEX('%[MU][0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%[MU][0-9]%', a.title), 2)
            END AS module_num  
           
           ,CASE
             WHEN std.custom_code IN ('TES.W.KIPP.C.TP','TES.W.KIPP.C','TES.W.KIPP.C.I','TES.W.KIPP.N.FTT','TES.W.KIPP.C.F') THEN 'Focus on Task and Text'
             WHEN std.custom_code IN ('TES.W.KIPP.C.O','TES.W.KIPP.N.O','TES.W.KIPP.C.O_1') THEN 'Organization'
             WHEN std.custom_code IN ('TES.W.KIPP.C.AJ','TES.W.KIPP.C.S','TES.W.KIPP.N.DS','TES.W.KIPP.C.D') THEN 'Development and Support'
             WHEN std.custom_code IN ('TES.W.KIPP.C.L','TES.W.KIPP.N.L','TES.W.KIPP.L.SF') THEN 'Language'
             WHEN std.custom_code IN ('TES.W.KIPP.C.C','TES.W.KIPP.N.C','TES.W.KIPP.C.G','TES.W.KIPP.C.S_1') THEN 'Conventions'             
            END AS rubric_strand
                                  
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
     JOIN gabby.illuminate_public.students s
       ON asrs.student_id = s.student_id
     WHERE a.academic_year_clean = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
    ) sub
PIVOT(
  AVG(rubric_score)
  FOR module_num IN ([QA1]
                    ,[QA2]
                    ,[QA3]
                    ,[QA4])
 ) p