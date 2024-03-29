CREATE OR ALTER VIEW
  tableau.ar_time_series_current AS
WITH
  time_series_data AS (
    SELECT
      co.student_number,
      co.lastfirst,
      co.academic_year,
      co.reporting_schoolid AS schoolid,
      co.grade_level,
      co.team,
      co.advisor_name,
      co.iep_status,
      co.[date],
      co.region,
      CAST(dts.alt_name AS VARCHAR(25)) AS term,
      CAST(dts.time_per_name AS VARCHAR(25)) AS goal_term,
      dts.[start_date] AS term_start_date,
      dts.end_date AS term_end_date,
      dts.is_curterm,
      y1dts.[start_date] AS y1_start_date,
      y1dts.end_date AS y1_end_date,
      enr.course_name,
      enr.course_number,
      enr.section_number,
      enr.teacher_name,
      hr.section_number AS homeroom_section,
      hr.teacher_name AS homeroom_teacher,
      CASE
        WHEN y1_goal.words_goal > 0 THEN y1_goal.words_goal
      END AS words_goal_yr,
      CASE
        WHEN term_goal.words_goal > 0 THEN term_goal.words_goal
      END AS words_goal_term,
      ar.n_words_read,
      ar.n_points_earned,
      ar.n_books_read,
      ar.n_fiction,
      ar.total_lexile,
      ar.total_pct_correct,
      bk.n_days_ago AS last_book_days_ago,
      bk.i_lexile AS last_book_lexile,
      bk.d_percent_correct AS last_book_pct_correct,
      bk.i_word_count AS last_book_word_count,
      CASE
        WHEN bk.rn_quiz > 1 THEN 'RETAKE - ' + bk.vch_content_title
        ELSE bk.vch_content_title
      END AS last_book_title
    FROM
      powerschool.cohort_identifiers_scaffold_current_static AS co
      LEFT JOIN reporting.reporting_terms AS dts ON (
        co.schoolid = dts.schoolid
        AND (
          co.[date] BETWEEN dts.[start_date] AND dts.end_date
        )
        AND dts.identifier = 'AR'
        AND dts.time_per_name != 'ARY'
        AND dts._fivetran_deleted = 0
      )
      LEFT JOIN reporting.reporting_terms AS y1dts ON (
        co.academic_year = y1dts.academic_year
        AND co.schoolid = y1dts.schoolid
        AND y1dts.identifier = 'AR'
        AND y1dts.time_per_name = 'ARY'
        AND y1dts._fivetran_deleted = 0
      )
      LEFT JOIN powerschool.course_enrollments_current_static AS enr ON (
        co.student_number = enr.student_number
        AND co.academic_year = enr.academic_year
        AND co.[db_name] = enr.[db_name]
        AND enr.credittype = 'ENG'
        AND enr.course_enroll_status = 0
        AND enr.section_enroll_status = 0
        AND enr.rn_subject = 1
      )
      LEFT JOIN powerschool.course_enrollments_current_static AS hr ON (
        co.student_number = hr.student_number
        AND co.academic_year = hr.academic_year
        AND co.schoolid = hr.schoolid
        AND co.[db_name] = hr.[db_name]
        AND hr.course_number = 'HR'
        AND hr.course_enroll_status = 0
        AND hr.section_enroll_status = 0
        AND hr.rn_course_yr = 1
      )
      LEFT JOIN renaissance.ar_goals_current_static AS y1_goal ON (
        co.student_number = y1_goal.student_number
        AND co.academic_year = y1_goal.academic_year
        AND y1_goal.reporting_term = 'ARY'
      )
      LEFT JOIN renaissance.ar_goals_current_static AS term_goal ON (
        co.student_number = term_goal.student_number
        AND co.academic_year = term_goal.academic_year
        AND dts.time_per_name = term_goal.reporting_term
      )
      LEFT JOIN renaissance.ar_most_recent_quiz_static AS bk ON (
        co.student_number = bk.student_number
        AND co.academic_year = bk.academic_year
      )
      LEFT JOIN renaissance.ar_studentpractice_rollup_static AS ar ON (
        co.student_number = ar.student_number
        AND co.[date] = ar.date_taken
      )
    WHERE
      co.enroll_status = 0
      AND (
        co.school_level = 'MS'
        OR (
          /* ad-hoc exception for Seek 4*/
          co.schoolid = 73256
          AND co.grade_level >= 3
        )
      )
      AND co.[date] <= CAST(CURRENT_TIMESTAMP AS DATE)
  ),
  running_calcs AS (
    SELECT
      student_number,
      lastfirst,
      academic_year,
      region,
      schoolid,
      grade_level,
      team,
      advisor_name,
      iep_status,
      term,
      [date],
      course_name,
      course_number,
      section_number,
      teacher_name,
      homeroom_section,
      homeroom_teacher,
      words_goal_yr,
      goal_term,
      is_curterm,
      words_goal_term,
      n_words_read,
      n_points_earned,
      n_books_read,
      n_fiction,
      total_lexile,
      total_pct_correct,
      last_book_title,
      last_book_days_ago,
      last_book_lexile,
      last_book_pct_correct,
      words_goal_yr * (
        CAST(
          DATEDIFF(DAY, y1_start_date, [date]) AS FLOAT
        ) / CAST(
          DATEDIFF(DAY, y1_start_date, y1_end_date) AS FLOAT
        )
      ) AS ontrack_words_yr,
      words_goal_term * (
        CAST(
          DATEDIFF(DAY, term_start_date, [date]) AS FLOAT
        ) / CAST(
          DATEDIFF(
            DAY,
            term_start_date,
            term_end_date
          ) AS FLOAT
        )
      ) AS ontrack_words_term,
      CASE
        WHEN DATEPART(WEEK, [date]) = DATEPART(
          WEEK,
          CAST(CURRENT_TIMESTAMP AS DATE)
        ) THEN 1
        WHEN DATEPART(WEEK, [date]) = DATEPART(
          WEEK,
          MAX([date]) OVER (
            PARTITION BY
              schoolid,
              academic_year,
              student_number
          )
        ) THEN 1
        ELSE 0
      END AS is_current_week,
      SUM(n_words_read) OVER (
        PARTITION BY
          student_number,
          academic_year,
          term
        ORDER BY
          [date]
      ) AS n_words_read_running_term,
      SUM(n_words_read) OVER (
        PARTITION BY
          student_number,
          academic_year
        ORDER BY
          [date]
      ) AS n_words_read_running_yr
    FROM
      time_series_data
  )
SELECT
  student_number,
  lastfirst,
  academic_year,
  region,
  schoolid,
  grade_level,
  team,
  advisor_name,
  iep_status,
  term,
  [date],
  course_name,
  course_number,
  section_number,
  teacher_name,
  homeroom_section,
  homeroom_teacher,
  words_goal_yr,
  NULL AS points_goal_yr,
  goal_term,
  words_goal_term,
  NULL AS points_goal_term,
  n_words_read,
  n_points_earned,
  n_books_read,
  n_fiction,
  total_lexile,
  total_pct_correct,
  last_book_title,
  last_book_days_ago,
  last_book_lexile,
  last_book_pct_correct,
  ontrack_words_yr,
  ontrack_words_term,
  is_current_week,
  is_curterm,
  n_words_read_running_term,
  n_words_read_running_yr,
  CASE
    WHEN ontrack_words_term IS NULL THEN NULL
    WHEN n_words_read_running_term >= ontrack_words_term THEN 1
    ELSE 0
  END AS is_ontrack_term,
  CASE
    WHEN ontrack_words_yr IS NULL THEN NULL
    WHEN n_words_read_running_yr >= ontrack_words_yr THEN 1
    ELSE 0
  END AS is_ontrack_yr
FROM
  running_calcs
