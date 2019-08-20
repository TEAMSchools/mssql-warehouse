USE gabby
GO

CREATE OR ALTER VIEW illuminate_dna_repositories.sight_words_data AS

SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
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
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 222
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
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
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 223
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
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
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 224
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 225 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_225
       UNPIVOT (
                value
                FOR field IN (field_can, field_see, field_go)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 225
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 226 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_226
       UNPIVOT (
                value
                FOR field IN (field_at, field_and, field_we)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 226
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 227 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_227
       UNPIVOT (
                value
                FOR field IN (field_so, field_no, field_yes)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 227
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 228 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_228
       UNPIVOT (
                value
                FOR field IN (field_here, field_said, field_but, field_our, field_what, field_away, field_big)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 228
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 229 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_229
       UNPIVOT (
                value
                FOR field IN (field_little, field_have, field_came, field_some, field_into, field_who, field_when)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 229
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 230 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_230
       UNPIVOT (
                value
                FOR field IN (field_because, field_there, field_want, field_that, field_dont, field_from, field_than)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 230
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 231 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_231
       UNPIVOT (
                value
                FOR field IN (field_about, field_back, field_after, field_im, field_been, field_your, field_them)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 231
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 232 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_232
       UNPIVOT (
                value
                FOR field IN (field_any, field_just, field_make, field_two, field_four, field_mother, field_where)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 232
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 233 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_233
       UNPIVOT (
                value
                FOR field IN (field_very, field_could, field_were, field_over, field_ride, field_one, field_with)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 233
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 234 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_234
       UNPIVOT (
                value
                FOR field IN (field_five, field_their, field_going, field_three, field_our, field_name, field_school)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 234
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 235 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_235
       UNPIVOT (
                value
                FOR field IN (field_it, field_he, field_she, field_an, field_up)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 235
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 236 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_236
       UNPIVOT (
                value
                FOR field IN (field_in, field_do, field_am, field_on, field_are)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 236
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 237 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_237
       UNPIVOT (
                value
                FOR field IN (field_look, field_play, field_was, field_come, field_all)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 237
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 238 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_238
       UNPIVOT (
                value
                FOR field IN (field_be, field_boy, field_girl, field_of, field_this)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 238
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 239 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_239
       UNPIVOT (
                value
                FOR field IN (field_has, field_out, field_went, field_run, field_as)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 239
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 240 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_240
       UNPIVOT (
                value
                FOR field IN (field_not, field_then, field_with, field_her, field_his)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 240
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 241 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_241
       UNPIVOT (
                value
                FOR field IN (field_saw, field_say, field_little, field_they, field_too)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 241
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 242 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_242
       UNPIVOT (
                value
                FOR field IN (field_us, field_will, field_by, field_eat, field_for)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 242
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 243 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_243
       UNPIVOT (
                value
                FOR field IN (field_get, field_now, field_or, field_ran, field_ball)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 243
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 244 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_244
       UNPIVOT (
                value
                FOR field IN (field_sit, field_day, field_got, field_had, field_jump)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 244
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 245 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_245
       UNPIVOT (
                value
                FOR field IN (field_man, field_did, field_him, field_how, field_if)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 245
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 246 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_246
       UNPIVOT (
                value
                FOR field IN (field_mom, field_put, field_read, field_sat, field_here)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 246
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 247 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_247
       UNPIVOT (
                value
                FOR field IN (field_said, field_but, field_our, field_what, field_away)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 247
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 248 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_248
       UNPIVOT (
                value
                FOR field IN (field_big, field_have, field_came, field_some, field_into)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 248
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 249 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_249
       UNPIVOT (
                value
                FOR field IN (field_who, field_when, field_because, field_there, field_them)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 249
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 250 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_250
       UNPIVOT (
                value
                FOR field IN (field_want, field_that, field_dont, field_from, field_than)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 250
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 251 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_251
       UNPIVOT (
                value
                FOR field IN (field_about, field_back, field_after, field_im, field_been)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 251
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 252 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_252
       UNPIVOT (
                value
                FOR field IN (field_your, field_any, field_just, field_make, field_two)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 252
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 253 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_253
       UNPIVOT (
                value
                FOR field IN (field_four, field_mother, field_where, field_very, field_could)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 253
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 254 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_254
       UNPIVOT (
                value
                FOR field IN (field_were, field_over, field_ride, field_one, field_five)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 254
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 255 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_255
       UNPIVOT (
                value
                FOR field IN (field_their, field_three, field_name, field_school, field_ate)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 255
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 256 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_256
       UNPIVOT (
                value
                FOR field IN (field_good, field_find, field_new, field_help, field_under, field_soon)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 256
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 257 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_257
       UNPIVOT (
                value
                FOR field IN (field_walk, field_every, field_these, field_going, field_before, field_able)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 257
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 258 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_258
       UNPIVOT (
                value
                FOR field IN (field_give, field_today, field_week, field_something, field_year, field_cant)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 258
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 259 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_259
       UNPIVOT (
                value
                FOR field IN (field_tell, field_across, field_world, field_take, field_does, field_hide)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 259
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 260 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_260
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_become)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 260
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 261 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_261
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_become)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 261
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 262 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_262
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_become)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 262
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 263 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_263
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_become)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 263
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 264 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_264
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_become)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 264
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 265 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_265
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_become)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 265
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 266 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_266
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_become)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 266
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 267 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_267
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_become)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 267
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 268 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_268
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_become)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 268
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 269 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_269
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_become)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 269
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 270 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_270
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_become)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 270
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 271 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_271
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_become)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 271
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 272 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_272
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_become)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 272
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 273 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_273
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_become)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 273
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 274 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_274
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_become)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 274
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 275 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_275
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_become)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 275
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 276 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_276
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_become)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 276
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 277 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_277
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_become)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 277
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 278 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_278
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 278
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 279 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_279
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_food)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 279
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 280 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_280
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_food)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 280
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 281 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_281
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_food)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 281
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 282 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_282
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_food)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 282
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 283 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_283
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_food)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 283
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 284 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_284
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_food)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 284
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 285 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_285
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_food)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 285
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 286 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_286
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_food)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 286
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 287 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_287
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_food)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 287
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 288 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_288
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_food)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 288
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 289 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_289
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_food)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 289
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 290 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_290
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_food)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 290
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 291 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_291
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_food)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 291
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 292 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_292
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_food)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 292
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id
UNION ALL
SELECT sub.repository_id
      ,sub.repository_row_id
      ,sub.value
      ,f.label
      ,s.local_student_id
FROM (
      SELECT 293 AS repository_id
            ,repository_row_id
            ,student_id
            ,CONVERT(VARCHAR(125), field) AS field
            ,CONVERT(VARCHAR(25), value) AS value
      FROM illuminate_dna_repositories.repository_293
       UNPIVOT (
                value
                FOR field IN (field_almost, field_anything, field_home, field_down, field_night, field_food)
               ) u
      WHERE u.repository_row_id IN (
                                    SELECT repository_row_id
                                    FROM illuminate_dna_repositories.repository_row_ids
                                    WHERE repository_id = 293
                                   )
     ) sub
JOIN illuminate_dna_repositories.fields f
  ON sub.repository_id = f.repository_id
 AND sub.field = f.name
 AND f.deleted_at IS NULL
JOIN illuminate_public.students s
  ON sub.student_id = s.student_id;