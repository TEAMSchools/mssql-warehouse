USE gabby
GO

CREATE OR ALTER VIEW illuminate_dna_repositories.sight_words_quiz_unpivot AS

SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.student_id
      ,sub.field
      ,sub.value
FROM
    (
     SELECT 222 AS repository_id
           ,repository_row_id
           ,student_id
           ,CONVERT(VARCHAR(125), field) AS field
           ,CONVERT(VARCHAR(25), value) AS value
     FROM illuminate_dna_repositories.repository_222
      UNPIVOT (
               value
               FOR field IN (field_i, field_a, field_the)
              ) u
     UNION ALL
     SELECT 223 AS repository_id
           ,repository_row_id
           ,student_id
           ,CONVERT(VARCHAR(125), field) AS field
           ,CONVERT(VARCHAR(25), value) AS value
     FROM illuminate_dna_repositories.repository_223
      UNPIVOT (
               value
               FOR field IN (field_my, field_is, field_like)
              ) u
     UNION ALL
     SELECT 224 AS repository_id
           ,repository_row_id
           ,student_id
           ,CONVERT(VARCHAR(125), field) AS field
           ,CONVERT(VARCHAR(25), value) AS value
     FROM illuminate_dna_repositories.repository_224
      UNPIVOT (
               value
               FOR field IN (field_my, field_is, field_like)
              ) u
    ) sub
WHERE CONCAT(sub.repository_id, '_', sub.repository_row_id) IN (SELECT row_hash FROM gabby.illuminate_dna_repositories.repository_row_ids)