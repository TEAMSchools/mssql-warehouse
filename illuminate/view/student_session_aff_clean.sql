USE gabby GO
CREATE OR ALTER VIEW
  illuminate_public.student_session_aff_clean AS
SELECT
  student_id,
  grade_level_id,
  academic_year,
  entry_date,
  ROW_NUMBER() OVER (
    PARTITION BY
      sub.student_id,
      sub.academic_year
    ORDER BY
      sub.entry_date DESC
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
          (gabby.utilities.DATE_TO_SY (entry_date) + 1) AS academic_year
        FROM
          gabby.illuminate_public.student_session_aff AS ssa
      ) sub
  ) sub
WHERE
  rn = 1
