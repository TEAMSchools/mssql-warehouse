USE gabby GO
CREATE OR ALTER VIEW
  renaissance.ar_studentpractice_rollup AS
SELECT
  student_number,
  academic_year,
  dt_taken AS date_taken,
  MIN(dt_taken) OVER (
    PARTITION BY
      student_number,
      academic_year
  ) AS min_date_taken,
  SUM(
    CASE
      WHEN rn_quiz = 1 THEN ti_passed
    END
  ) AS n_books_passed,
  COUNT(
    CASE
      WHEN rn_quiz = 1 THEN i_quiz_number
    END
  ) AS n_books_read,
  SUM(
    CASE
      WHEN ti_passed = 1
      AND rn_quiz = 1 THEN d_points_earned
    END
  ) AS n_points_earned,
  SUM(
    CASE
      WHEN ti_passed = 1
      AND rn_quiz = 1 THEN i_word_count
    END
  ) AS n_words_read,
  SUM(
    CASE
      WHEN ch_fiction_non_fiction = 'F'
      AND rn_quiz = 1 THEN 1
      ELSE 0
    END
  ) AS n_fiction,
  SUM(
    CASE
      WHEN rn_quiz = 1 THEN d_percent_correct
    END
  ) AS total_pct_correct,
  SUM(
    CASE
      WHEN rn_quiz = 1 THEN fl_lexile_calc
    END
  ) AS total_lexile
FROM
  gabby.renaissance.ar_studentpractice_identifiers_static AS
GROUP BY
  student_number,
  academic_year,
  dt_taken
