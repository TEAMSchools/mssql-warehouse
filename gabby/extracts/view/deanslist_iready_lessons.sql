CREATE OR ALTER VIEW
  extracts.deanslist_iready_lessons AS
SELECT
  pl.student_id,
  pl.[subject],
  t.term_name,
  t.term_id,
  CAST(
    SUM(
      CASE
        WHEN pl.passed_or_not_passed = 'Passed' THEN 1
        ELSE 0
      END
    ) AS FLOAT
  ) AS lessons_passed,
  CAST(
    COUNT(DISTINCT pl.lesson_id) AS FLOAT
  ) AS total_lessons,
  ROUND(
    CAST(
      SUM(
        CASE
          WHEN pl.passed_or_not_passed = 'Passed' THEN 1
          ELSE 0
        END
      ) AS FLOAT
    ) / CAST(COUNT(pl.lesson_id) AS FLOAT),
    2
  ) * 100 AS pct_passed
FROM
  iready.personalized_instruction_by_lesson AS pl
  INNER JOIN people.school_crosswalk AS sc ON (pl.school = sc.site_name)
  INNER JOIN deanslist.terms_clean_static AS t ON (
    sc.dl_school_id = t.school_id
    AND (
      CAST(pl.completion_date AS DATE) BETWEEN t.[start_date] AND t.end_date
    )
    AND t.term_type = 'Biweeks'
  )
WHERE
  pl.completion_date >= DATEFROMPARTS(
    utilities.GLOBAL_ACADEMIC_YEAR (),
    7,
    1
  )
GROUP BY
  pl.student_id,
  pl.[subject],
  t.term_name,
  t.term_id
