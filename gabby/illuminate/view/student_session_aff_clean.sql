CREATE OR ALTER VIEW
  illuminate_public.student_session_aff_clean AS
SELECT
  student_id,
  grade_level_id,
  academic_year,
  entry_date,
  ROW_NUMBER() OVER (
    PARTITION BY
      student_id,
      academic_year
    ORDER BY
      entry_date DESC
  ) AS rn
FROM
  (
    SELECT
      student_id,
      grade_level_id,
      academic_year,
      entry_date,
      ROW_NUMBER() OVER (
        PARTITION BY
          student_id,
          grade_level_id,
          academic_year
        ORDER BY
          entry_date DESC,
          leave_date DESC
      ) AS rn
    FROM
      (
        SELECT
          student_id,
          grade_level_id,
          entry_date,
          leave_date,
          utilities.DATE_TO_SY (entry_date) + 1 AS academic_year
        FROM
          illuminate.stg_student_session_aff
      ) AS sub
  ) AS sub
WHERE
  rn = 1
