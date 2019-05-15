USE gabby
GO

CREATE OR ALTER VIEW renaissance.ar_studentpractice_identifiers AS

SELECT student_number
      ,ch_fiction_non_fiction
      ,d_percent_correct
      ,d_points_earned
      ,dt_taken
      ,fl_lexile_calc
      ,i_lexile 
      ,i_questions_correct
      ,i_questions_presented
      ,i_quiz_number           
      ,i_student_practice_id
      ,i_user_id
      ,i_word_count      
      ,ti_book_rating
      ,ti_passed
      ,vch_content_title
      ,vch_lexile_display      

      ,gabby.utilities.DATE_TO_SY(dt_taken) AS academic_year

      ,CASE
        /* for failing attempts, valid row should be most recent */
        WHEN ti_passed = 0 THEN ROW_NUMBER() OVER(
                                  PARTITION BY student_number, i_quiz_number, ti_passed
                                    ORDER BY dt_taken DESC) 
        /* for passing attempts, valid row should be first */
        WHEN ti_passed = 1 THEN ROW_NUMBER() OVER(
                                  PARTITION BY student_number, i_quiz_number, ti_passed
                                    ORDER BY dt_taken ASC) 
       END AS rn_quiz
FROM
    (
     SELECT CONVERT(INT,ar.i_student_practice_id) AS i_student_practice_id
           ,CONVERT(INT,ar.i_user_id) AS i_user_id
           ,CONVERT(INT,ar.i_quiz_number) AS i_quiz_number
           ,CONVERT(VARCHAR(250),ar.vch_content_title) AS vch_content_title
           ,CONVERT(DATE,ar.dt_taken) AS dt_taken
           ,CONVERT(INT,ar.ti_passed) AS ti_passed
           ,CONVERT(FLOAT,ar.i_word_count) AS i_word_count
           ,ar.d_percent_correct
           ,CONVERT(FLOAT,ar.i_questions_correct) AS i_questions_correct
           ,CONVERT(FLOAT,ar.i_questions_presented) AS i_questions_presented
           ,ar.fl_lexile_calc
           ,CONVERT(INT,ar.i_lexile) AS i_lexile
           ,CONVERT(VARCHAR(25),ar.vch_lexile_display) AS vch_lexile_display
           ,ar.d_points_earned
           ,CONVERT(VARCHAR(2),ar.ch_fiction_non_fiction) AS ch_fiction_non_fiction
           ,CONVERT(INT,ar.ti_book_rating) AS ti_book_rating

           ,CONVERT(INT,CASE WHEN ISNUMERIC(u.vch_previous_idnum) = 1 THEN u.vch_previous_idnum END) AS student_number
     FROM gabby.renaissance.ar_studentpractice ar
     JOIN gabby.renaissance.rl_user u
       ON ar.i_user_id = u.i_user_id
     WHERE ar.i_content_type_id = 31
       AND ar.ti_row_status = 1
       AND ar.ch_status != 'U'
    ) sub