CREATE OR ALTER VIEW
  renaissance.ar_studentpractice_identifiers AS
SELECT
  student_identifier AS student_number,
  fiction_non_fiction AS ch_fiction_non_fiction,
  percent_correct AS d_percent_correct,
  points_earned AS d_points_earned,
  date_quiz_completed_local AS dt_taken,
  CAST(lexile_level AS FLOAT) AS fl_lexile_calc,
  lexile_level AS i_lexile,
  questions_correct AS i_questions_correct,
  questions_presented AS i_questions_presented,
  quiz_number AS i_quiz_number,
  NULL AS i_student_practice_id,
  NULL AS i_user_id,
  word_count AS i_word_count,
  NULL AS ti_book_rating,
  passed AS ti_passed,
  content_title AS vch_content_title,
  lexile_measure AS vch_lexile_display,
  academic_year,
  CASE
  /* for failing attempts, valid row should be most recent */
    WHEN passed = 0 THEN ROW_NUMBER() OVER (
      PARTITION BY
        student_identifier,
        quiz_number,
        passed
      ORDER BY
        date_quiz_completed_local DESC
    )
    /* for passing attempts, valid row should be first */
    WHEN passed = 1 THEN ROW_NUMBER() OVER (
      PARTITION BY
        student_identifier,
        quiz_number,
        passed
      ORDER BY
        date_quiz_completed_local ASC
    )
  END AS rn_quiz
FROM
  (
    SELECT
      CAST(
        CASE
          WHEN ISNUMERIC(student_identifier) = 1 THEN student_identifier
        END AS INT
      ) AS student_identifier,
      quiz_number,
      content_title,
      CAST(
        date_quiz_completed_local AS DATE
      ) AS date_quiz_completed_local,
      passed,
      CAST(word_count AS FLOAT) AS word_count,
      points_earned,
      CAST(questions_correct AS FLOAT) AS questions_correct,
      CAST(questions_presented AS FLOAT) AS questions_presented,
      percent_correct,
      lexile_level,
      lexile_measure,
      CASE
        WHEN fiction_non_fiction = 'Fiction' THEN 'F'
        WHEN fiction_non_fiction = 'NonFiction' THEN 'NF'
      END AS fiction_non_fiction,
      CAST(LEFT(school_year, 4) AS INT) AS academic_year
    FROM
      gabby.renaissance.accelerated_reader
    WHERE
      quiz_deleted = 0
      AND quiz_type = 'Reading Practice Quiz'
  ) AS sub
WHERE
  student_identifier IS NOT NULL
