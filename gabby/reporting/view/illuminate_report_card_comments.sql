CREATE OR ALTER VIEW
  reporting.illuminate_report_card_comments AS
WITH
  repos_union AS (
    SELECT
      sub.repository_id,
      CAST(sub.repository_row_id AS INT) AS repository_row_id,
      sub.field_term,
      sub.field_math_comment_1,
      sub.field_math_comment_2,
      sub.field_writing_comment_1,
      sub.field_writing_comment_2,
      sub.field_reading_comment_1,
      sub.field_reading_comment_2,
      sub.field_character_comment_1,
      sub.field_character_comment_2,
      CAST(s.local_student_id AS INT) AS local_student_id,
      utilities.GLOBAL_ACADEMIC_YEAR () AS academic_year
    FROM
      (
        SELECT
          216 AS repository_id,
          'Q1' AS field_term,
          repository_row_id,
          student_id,
          field_math_comment_1,
          field_math_comment_2,
          field_writing_comment_1,
          field_writing_comment_2,
          field_reading_comment_1,
          field_reading_comment_2,
          field_character_comment_1_1 AS field_character_comment_1,
          field_character_comment_2_1 AS field_character_comment_2
        FROM
          illuminate_dna_repositories.repository_216
        UNION ALL
        SELECT
          207 AS repository_id,
          'Q2' AS field_term,
          repository_row_id,
          student_id,
          field_math_comment_1,
          field_math_comment_2,
          field_writing_comment_1,
          field_writing_comment_2,
          field_reading_comment_1,
          field_reading_comment_2,
          field_character_comment_1,
          field_character_comment_2
        FROM
          illuminate_dna_repositories.repository_207
        UNION ALL
        SELECT
          208 AS repository_id,
          'Q3' AS field_term,
          repository_row_id,
          student_id,
          field_math_comment_1,
          field_math_comment_2,
          field_writing_comment_1,
          field_writing_comment_2,
          field_reading_comment_1,
          field_reading_comment_2,
          field_character_comment_1,
          field_character_comment_2
        FROM
          illuminate_dna_repositories.repository_208
        UNION ALL
        SELECT
          209 AS repository_id,
          'Q4' AS field_term,
          repository_row_id,
          student_id,
          field_math_comment_1,
          field_math_comment_2,
          field_writing_comment_1,
          field_writing_comment_2,
          field_reading_comment_1,
          field_reading_comment_2,
          field_character_comment_1,
          field_character_comment_2
        FROM
          illuminate_dna_repositories.repository_209
      ) AS sub
      INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
    WHERE
      CONCAT(
        sub.repository_id,
        '_',
        sub.repository_row_id
      ) IN (
        SELECT
          row_hash
        FROM
          illuminate_dna_repositories.repository_row_ids
      )
  ),
  comm_unpivot AS (
    SELECT
      repository_id,
      repository_row_id,
      local_student_id,
      academic_year,
      field_term,
      CAST(comment_field AS VARCHAR(125)) AS comment_field,
      comment_code,
      CAST(RIGHT(comment_field, 1) AS INT) AS comment_number
    FROM
      repos_union UNPIVOT (
        comment_code FOR comment_field IN (
          field_math_comment_1,
          field_math_comment_2,
          field_writing_comment_1,
          field_writing_comment_2,
          field_reading_comment_1,
          field_reading_comment_2,
          field_character_comment_1,
          field_character_comment_2
        )
      ) AS u
  )
SELECT
  cu.repository_id,
  cu.repository_row_id,
  cu.local_student_id AS student_number,
  cu.academic_year,
  cu.field_term AS term_name,
  cu.comment_field,
  cu.comment_code,
  cu.comment_number,
  CAST(cb.subject AS VARCHAR(25)) AS comment_subject,
  CAST(cb.subcategory AS VARCHAR(125)) AS subcategory,
  CAST(cb.comment AS VARCHAR(250)) AS comment
FROM
  comm_unpivot AS cu
  INNER JOIN reporting.report_card_comment_bank AS cb ON (
    cu.comment_code = cb.code
    AND cb._fivetran_deleted = 0
  )
