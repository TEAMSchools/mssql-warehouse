USE gabby
GO

ALTER VIEW reporting.illuminate_report_card_comments AS

WITH comm_unpivot AS (
  SELECT repository_id
        ,repository_row_id      
        ,local_student_id
        ,academic_year
        ,field_term
        ,repository_field
        ,comment_code
  FROM
      (
       SELECT 46 AS repository_id
             ,2016 AS academic_year

             ,r.repository_row_id
             ,r.field_term
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
      ) sub
  UNPIVOT(
    comment_code
    FOR repository_field IN (field_math_comment_1
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
      ,cu.comment_code      
      
      ,SUBSTRING(f.label, 1, CASE WHEN CHARINDEX(' ', f.label) - 1 < 0 THEN 0 ELSE CHARINDEX(' ', f.label) - 1 END) AS comment_subject
      ,RIGHT(f.label, 1) AS comment_number

      ,cb.subcategory
      ,cb.comment
FROM comm_unpivot cu
JOIN gabby.illuminate_dna_repositories.fields f
  ON cu.repository_id = f.repository_id
 AND cu.repository_field = f.name
JOIN gabby.reporting.report_card_comment_bank cb
  ON cu.comment_code = cb.code