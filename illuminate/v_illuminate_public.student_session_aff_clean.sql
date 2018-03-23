USE gabby
GO

CREATE OR ALTER VIEW illuminate_public.student_session_aff_clean AS

SELECT student_id
      ,grade_level_id
      ,academic_year
      ,entry_date
      ,CONVERT(INT,ROW_NUMBER() OVER(
                     PARTITION BY student_id, grade_level_id, academic_year
                       ORDER BY entry_date DESC)) AS rn
FROM
    (
     SELECT student_id
           ,grade_level_id      
           ,entry_date
           ,(gabby.utilities.DATE_TO_SY(entry_date) + 1) AS academic_year            
     FROM gabby.illuminate_public.student_session_aff ssa 
    ) sub