USE gabby
GO

CREATE OR ALTER VIEW reporting.illuminate_report_card_comments AS

WITH comm_unpivot AS (
  SELECT repository_id
        ,CONVERT(INT,repository_row_id) AS repository_row_id
        ,CONVERT(INT,local_student_id) AS local_student_id
        ,academic_year
        ,field_term
        ,CONVERT(VARCHAR(125),comment_field) AS comment_field
        ,comment_code
  FROM
      (
       SELECT 46 AS repository_id
             ,gabby.utilities.GLOBAL_ACADEMIC_YEAR() AS academic_year

             ,r.repository_row_id
             ,'Q1' AS field_term
             ,r.field_math_comment_1
             ,r.field_math_comment_2
             ,r.field_writing_comment_1
             ,r.field_writing_comment_2
             ,r.field_reading_comment_1
             ,r.field_reading_comment_2
             ,r.field_character_comment_1
             ,r.field_character_comment_2
      
             ,s.local_student_id
       FROM gabby.illuminate_dna_repositories.repository_46 r
       JOIN gabby.illuminate_public.students s
         ON r.student_id = s.student_id
       WHERE CONCAT(46, '_', r.repository_row_id) IN (SELECT CONCAT(repository_id, '_', repository_row_id) FROM gabby.illuminate_dna_repositories.repository_row_ids)

       UNION ALL

       SELECT 207 AS repository_id
             ,gabby.utilities.GLOBAL_ACADEMIC_YEAR() AS academic_year

             ,r.repository_row_id
             ,'Q2' AS field_term
             ,r.field_math_comment_1
             ,r.field_math_comment_2
             ,r.field_writing_comment_1
             ,r.field_writing_comment_2
             ,r.field_reading_comment_1
             ,r.field_reading_comment_2
             ,r.field_character_comment_1
             ,r.field_character_comment_2
      
             ,s.local_student_id
       FROM gabby.illuminate_dna_repositories.repository_207 r
       JOIN gabby.illuminate_public.students s
         ON r.student_id = s.student_id
       WHERE CONCAT(207, '_', r.repository_row_id) IN (SELECT CONCAT(repository_id, '_', repository_row_id) FROM gabby.illuminate_dna_repositories.repository_row_ids)

       UNION ALL

       SELECT 208 AS repository_id
             ,gabby.utilities.GLOBAL_ACADEMIC_YEAR() AS academic_year

             ,r.repository_row_id
             ,'Q3' AS field_term
             ,r.field_math_comment_1
             ,r.field_math_comment_2
             ,r.field_writing_comment_1
             ,r.field_writing_comment_2
             ,r.field_reading_comment_1
             ,r.field_reading_comment_2
             ,r.field_character_comment_1
             ,r.field_character_comment_2
      
             ,s.local_student_id
       FROM gabby.illuminate_dna_repositories.repository_207 r
       JOIN gabby.illuminate_public.students s
         ON r.student_id = s.student_id
       WHERE CONCAT(208, '_', r.repository_row_id) IN (SELECT CONCAT(repository_id, '_', repository_row_id) FROM gabby.illuminate_dna_repositories.repository_row_ids)

       UNION ALL

       SELECT 209 AS repository_id
             ,gabby.utilities.GLOBAL_ACADEMIC_YEAR() AS academic_year

             ,r.repository_row_id
             ,'Q4' AS field_term
             ,r.field_math_comment_1
             ,r.field_math_comment_2
             ,r.field_writing_comment_1
             ,r.field_writing_comment_2
             ,r.field_reading_comment_1
             ,r.field_reading_comment_2
             ,r.field_character_comment_1
             ,r.field_character_comment_2
      
             ,s.local_student_id
       FROM gabby.illuminate_dna_repositories.repository_207 r
       JOIN gabby.illuminate_public.students s
         ON r.student_id = s.student_id
       WHERE CONCAT(209, '_', r.repository_row_id) IN (SELECT CONCAT(repository_id, '_', repository_row_id) FROM gabby.illuminate_dna_repositories.repository_row_ids)

       UNION ALL

       SELECT 46 AS repository_id
             ,2016 AS academic_year

             ,ROW_NUMBER() OVER(ORDER BY s.local_student_id) AS repository_row_id
             ,CONVERT(VARCHAR(5),r.term) AS term
             ,r.math_comment_1
             ,r.math_comment_2
             ,r.writing_comment_1
             ,r.writing_comment_2
             ,r.reading_comment_1
             ,r.reading_comment_2
             ,r.character_comment_1
             ,r.character_comment_2
      
             ,s.local_student_id
       FROM gabby.reporting.illuminate_report_card_comments_archive r
       JOIN gabby.illuminate_public.students s
         ON r.student_id = s.student_id       
      ) sub
  UNPIVOT(
    comment_code
    FOR comment_field IN (field_math_comment_1
                         ,field_math_comment_2
                         ,field_writing_comment_1
                         ,field_writing_comment_2
                         ,field_reading_comment_1
                         ,field_reading_comment_2
                         ,field_character_comment_1
                         ,field_character_comment_2)
   ) u
 )

SELECT cu.repository_id
      ,cu.repository_row_id
      ,cu.local_student_id AS student_number
      ,cu.academic_year
      ,cu.field_term AS term_name
      ,cu.comment_field
      ,cu.comment_code      
      
      ,CONVERT(VARCHAR(125),SUBSTRING(f.label, 1, CASE WHEN CHARINDEX(' ', f.label) - 1 < 0 THEN 0 ELSE CHARINDEX(' ', f.label) - 1 END)) AS comment_subject
      ,CONVERT(INT,RIGHT(f.label, 1)) AS comment_number

      ,CONVERT(VARCHAR(125),cb.subcategory) AS subcategory
      ,CONVERT(VARCHAR(250),cb.comment) AS comment
FROM comm_unpivot cu
JOIN gabby.illuminate_dna_repositories.fields f
  ON cu.repository_id = f.repository_id
 AND cu.comment_field = f.name
JOIN gabby.reporting.report_card_comment_bank cb
  ON cu.comment_code = cb.code