USE gabby
GO

CREATE OR ALTER VIEW tableau.qa_report_card_comment_audit AS

WITH repo_fields AS (
  SELECT r.repository_id                
        ,r.title

        ,f.label AS field_label
        ,f.name AS field_name
  FROM gabby.illuminate_dna_repositories.repositories r
  JOIN gabby.illuminate_dna_repositories.fields f
    ON r.repository_id = f.repository_id
   AND f.deleted_at IS NULL
   AND f.name != 'field_term'
  WHERE r.repository_id = 46    
 )


,repo_data_unpivot AS (
  SELECT repository_id
        ,repository_row_id
        ,local_student_id
        ,term_name
        ,comment_field
        ,comment_code
  FROM
      (
       SELECT 46 AS repository_id
             ,r.repository_row_id             
             ,r.field_term AS term_name
             ,CONVERT(NVARCHAR,r.field_ela) AS field_ela
             ,CONVERT(NVARCHAR,r.field_math) AS field_math
             ,CONVERT(NVARCHAR,r.field_music) AS field_music
             ,CONVERT(NVARCHAR,r.field_social_skills) AS field_social_skills
             ,CONVERT(NVARCHAR,r.field_science) AS field_science
             ,CONVERT(NVARCHAR,r.field_spanish) AS field_spanish
             ,CONVERT(NVARCHAR,r.field_visual_arts) AS field_visual_arts
             ,CONVERT(NVARCHAR,r.field_humanities_sssl_social_studies) AS field_humanities_sssl_social_studies
             ,CONVERT(NVARCHAR,r.field_writing) AS field_writing
             ,CONVERT(NVARCHAR,r.field_dance) AS field_dance
             ,CONVERT(NVARCHAR,r.field_subject) AS field_subject
             ,CONVERT(NVARCHAR,r.field_comment) AS field_comment
             ,CONVERT(NVARCHAR,r.field_math_comment_1) AS field_math_comment_1
             ,CONVERT(NVARCHAR,r.field_math_comment_2) AS field_math_comment_2
             ,CONVERT(NVARCHAR,r.field_writing_comment_1) AS field_writing_comment_1
             ,CONVERT(NVARCHAR,r.field_writing_comment_2) AS field_writing_comment_2
             ,CONVERT(NVARCHAR,r.field_reading_comment_1) AS field_reading_comment_1
             ,CONVERT(NVARCHAR,r.field_reading_comment_2) AS field_reading_comment_2
             ,CONVERT(NVARCHAR,r.field_character_comment_1) AS field_character_comment_1
             ,CONVERT(NVARCHAR,r.field_character_comment_2) AS field_character_comment_2
             ,CONVERT(NVARCHAR,r.field_specials_comment_1) AS field_specials_comment_1
             ,CONVERT(NVARCHAR,r.field_specials_comment_2) AS field_specials_comment_2

             ,s.local_student_id
       FROM gabby.illuminate_dna_repositories.repository_46 r
       JOIN gabby.illuminate_public.students s
         ON r.student_id = s.student_id
       WHERE CONCAT(46, '_', r.repository_row_id) IN (SELECT CONCAT(repository_id, '_', repository_row_id) FROM gabby.illuminate_dna_repositories.repository_row_ids)
      ) sub
  UNPIVOT(
    comment_code
    FOR comment_field IN (field_ela
                         ,field_math
                         ,field_music
                         ,field_social_skills
                         ,field_science
                         ,field_spanish
                         ,field_visual_arts
                         ,field_humanities_sssl_social_studies
                         ,field_writing
                         ,field_dance
                         ,field_subject
                         ,field_comment
                         ,field_math_comment_1
                         ,field_math_comment_2
                         ,field_writing_comment_1
                         ,field_writing_comment_2
                         ,field_reading_comment_1
                         ,field_reading_comment_2
                         ,field_character_comment_1
                         ,field_character_comment_2
                         ,field_specials_comment_1
                         ,field_specials_comment_2)
   ) u
 )

SELECT co.student_number
      ,co.lastfirst
      ,co.reporting_schoolid AS schoolid
      ,co.grade_level
      ,co.team
      ,co.enroll_status
      ,co.school_level
      
      ,rt.alt_name AS term_name

      ,rf.repository_id
      ,rf.field_name
      ,rf.field_label      

      ,rdu.comment_code

      ,cb.subject      
      ,cb.subcategory      
      ,cb.comment
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.reporting.reporting_terms rt
  ON co.schoolid = rt.schoolid
 AND co.academic_year = rt.academic_year
 AND rt.identifier = 'RT'
 AND rt.alt_name != 'Summer School'
CROSS JOIN repo_fields rf
LEFT OUTER JOIN repo_data_unpivot rdu
  ON co.student_number = rdu.local_student_id
 AND rt.alt_name = rdu.term_name
 AND rf.field_name = rdu.comment_field
LEFT OUTER JOIN gabby.reporting.report_card_comment_bank cb
  ON rdu.comment_code = cb.code
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1
  AND co.grade_level <= 4
  AND co.enroll_status = 0

--UNION ALL

--SELECT co.student_number
--      ,co.lastfirst
--      ,co.reporting_schoolid AS schoolid
--      ,co.grade_level
--      ,co.team
--      ,co.enroll_status
--      ,co.school_level

--      ,scaff.term_name

--      ,NULL AS repository_id
--      ,NULL AS field_name
      
--      ,cou.credittype AS field_label
      
--      ,1 AS comment_code

--      ,cou.credittype AS subject
--      ,cou.course_name AS subcategory
--      ,comm.comment_value      
--FROM gabby.powerschool.cohort_identifiers_static co
--JOIN gabby.powerschool.course_section_scaffold_static scaff
--  ON co.studentid = scaff.studentid
-- AND (co.academic_year - 1990) = scaff.yearid
-- AND scaff.excludefromgpa = 0
--JOIN gabby.powerschool.courses cou
--  ON scaff.course_number = cou.course_number 
--LEFT OUTER JOIN gabby.powerschool.pgfinalgrades comm
--  ON co.studentid = comm.studentid
-- AND scaff.term_name = comm.finalgradename
-- AND scaff.sectionid = comm.sectionid
--WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
--  AND co.rn_year = 1
--  AND co.grade_level >= 5
--  AND co.enroll_status = 0