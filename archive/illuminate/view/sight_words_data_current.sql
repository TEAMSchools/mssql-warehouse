CREATE OR ALTER VIEW
  illuminate_dna_repositories.sight_words_data_current AS
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      360 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_360 UNPIVOT (
        [value] FOR field IN (
          field_now,
          field_want,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 360
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      361 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_361 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask,
          field_want_1,
          field_with_1
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 361
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      362 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_362 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask,
          field_where,
          field_want_1
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 362
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      363 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_363 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask,
          field_always,
          field_enough
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 363
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      364 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_364 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 364
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      365 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_365 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 365
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      366 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_366 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 366
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      367 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_367 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 367
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      368 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_368 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 368
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      369 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_369 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_what,
          field_tbd,
          field_tbd_1
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 369
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      370 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_370 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask,
          field_tbd,
          field_tbd_1
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 370
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      371 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_371 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask,
          field_tbd,
          field_tbd_1
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 371
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      372 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_372 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 372
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      373 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_373 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask,
          field_from,
          field_than
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 373
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      374 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_374 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask,
          field_tbd_1,
          field_tbd
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 374
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      375 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_375 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask,
          field_gone,
          field_enough
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 375
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      376 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_376 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask,
          field_tbd_1,
          field_just,
          field_tbd
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 376
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      377 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_377 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_come,
          field_ask,
          field_just
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 377
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      378 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_378 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 378
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      379 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_379 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 379
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      380 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_380 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 380
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      381 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_381 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 381
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      382 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_382 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 382
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      383 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_383 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 383
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      384 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_384 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 384
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      385 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_385 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 385
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      386 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_386 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 386
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      387 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_387 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 387
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      388 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_388 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 388
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      389 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_389 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 389
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      390 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_390 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 390
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      391 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_391 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 391
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      392 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_392 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 392
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      393 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_393 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 393
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      394 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_394 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 394
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      395 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_395 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 395
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      396 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_396 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 396
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      397 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_397 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 397
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      398 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_398 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 398
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      399 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_399 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 399
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      400 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_400 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 400
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      401 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_401 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 401
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      402 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_402 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 402
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      403 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_403 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 403
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      404 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_404 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 404
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      405 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_405 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 405
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      406 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_406 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 406
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      407 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_407 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 407
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      408 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_408 UNPIVOT (
        [value] FOR field IN (
          field_want,
          field_now,
          field_dont,
          field_with,
          field_come,
          field_ask
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 408
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      410 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_410 UNPIVOT (
        [value] FOR field IN (
          field_come,
          field_want,
          field_with,
          field_im,
          field_ask,
          field_tbd_1,
          field_dont,
          field_now,
          field_tbd
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 410
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
UNION ALL
SELECT
  sub.repository_id,
  sub.repository_row_id,
  sub.[value],
  CAST(f.[label] AS NVARCHAR(32)) AS [label],
  s.local_student_id,
  CAST(r.date_administered AS DATE) AS date_administered
FROM
  (
    SELECT
      411 AS repository_id,
      repository_row_id,
      student_id,
      CAST(field AS VARCHAR(125)) AS field,
      CAST([value] AS VARCHAR(25)) AS [value]
    FROM
      illuminate_dna_repositories.repository_411 UNPIVOT (
        [value] FOR field IN (
          field_with,
          field_door,
          field_children,
          field_dont,
          field_own,
          field_come,
          field_want,
          field_ask,
          field_done,
          field_now
        )
      ) AS u
    WHERE
      u.repository_row_id IN (
        SELECT
          repository_row_id
        FROM
          illuminate_dna_repositories.repository_row_ids
        WHERE
          repository_id = 411
      )
  ) AS sub
  INNER JOIN illuminate_dna_repositories.fields AS f ON sub.repository_id = f.repository_id
  AND sub.field = f.[name]
  AND f.deleted_at IS NULL
  INNER JOIN illuminate_public.students AS s ON sub.student_id = s.student_id
  INNER JOIN illuminate_dna_repositories.repositories AS r ON sub.repository_id = r.repository_id
