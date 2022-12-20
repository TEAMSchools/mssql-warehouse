CREATE OR ALTER VIEW
  renaissance.ar_most_recent_quiz AS
SELECT
  student_number,
  academic_year,
  i_quiz_number,
  vch_content_title,
  dt_taken,
  i_lexile,
  d_percent_correct,
  i_word_count,
  n_days_ago,
  rn_quiz
FROM
  (
    SELECT
      student_number,
      academic_year,
      i_quiz_number,
      vch_content_title,
      dt_taken,
      i_lexile,
      d_percent_correct,
      i_word_count,
      rn_quiz,
      CASE
        WHEN academic_year < gabby.utilities.GLOBAL_ACADEMIC_YEAR () THEN DATEDIFF(
          DAY,
          dt_taken,
          DATEFROMPARTS(
            (academic_year + 1),
            6,
            30
          )
        )
        ELSE DATEDIFF(
          DAY,
          dt_taken,
          CURRENT_TIMESTAMP
        )
      END AS n_days_ago,
      ROW_NUMBER() OVER (
        PARTITION BY
          student_number,
          academic_year
        ORDER BY
          dt_taken DESC
      ) AS rn_recent_year
    FROM
      gabby.renaissance.ar_studentpractice_identifiers_static
  ) AS sub
WHERE
  rn_recent_year = 1
