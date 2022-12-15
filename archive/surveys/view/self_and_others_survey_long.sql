USE gabby GO
CREATE OR ALTER VIEW
  surveys.self_and_others_survey_long AS
WITH
  so_long AS (
    SELECT
      sub.response_id,
      sub.academic_year,
      sub.term_name,
      sub.reporting_term,
      sub.time_started,
      sub.date_submitted,
      sub.respondent_name,
      sub.respondent_email_address,
      sub.subject_name,
      sub.subject_associate_id,
      sub.is_manager,
      sub.question_code,
      sub.response,
      sub.survey_type,
      SUM(sub.is_manager) OVER (
        PARTITION BY
          sub.academic_year,
          sub.reporting_term,
          sub.subject_associate_id,
          sub.question_code
      ) AS n_managers,
      COUNT(
        CASE
          WHEN sub.is_manager = 0 THEN sub.respondent_email_address
        END
      ) OVER (
        PARTITION BY
          sub.academic_year,
          sub.reporting_term,
          subject_associate_id,
          sub.question_code
      ) AS n_peers,
      COUNT(sub.respondent_email_address) OVER (
        PARTITION BY
          sub.academic_year,
          sub.reporting_term,
          sub.subject_associate_id,
          sub.question_code
      ) AS n_total
    FROM
      (
        SELECT
          CAST(u.response_id AS INT) AS response_id,
          CAST(u.academic_year AS INT) AS academic_year,
          CAST(u.term_name AS VARCHAR(5)) AS term_name,
          CAST(u.reporting_term AS VARCHAR(5)) AS reporting_term,
          u.time_started,
          u.date_submitted,
          CAST(u.your_name_ AS VARCHAR(125)) AS respondent_name,
          CAST(
            u.your_kipp_nj_email_account AS VARCHAR(125)
          ) AS respondent_email_address,
          CAST(u.subject_name AS VARCHAR(125)) AS subject_name,
          CAST(u.subject_associate_id AS VARCHAR(25)) AS subject_associate_id,
          CAST(u.is_manager AS INT) AS is_manager,
          CAST(u.question_code AS VARCHAR(25)) AS question_code,
          u.response,
          CASE
            WHEN u.academic_year <= 2017 THEN 'SO'
            ELSE 'SO2018'
          END AS survey_type
        FROM
          gabby.surveys.self_and_others_survey_final UNPIVOT (
            response FOR question_code IN (
              q_1_1_b,
              q_1_1_c,
              q_1_1_d,
              q_1_1_oe,
              q_1_2_a,
              q_1_2_b,
              q_1_2_oe,
              q_1_3_a,
              q_1_3_c,
              q_1_3_d,
              q_1_3_e,
              q_1_3_oe,
              q_1_4_a,
              q_1_4_b,
              q_1_4_oe,
              q_1_5_a,
              q_1_5_b,
              q_1_5_c,
              q_1_5_d,
              q_1_5_f,
              q_1_5_oe,
              q_1_6_a,
              q_1_6_b,
              q_1_6_c,
              q_1_6_d,
              q_1_6_oe
            )
          ) u
      ) sub
  )
SELECT
  so.survey_type,
  so.response_id,
  so.academic_year,
  so.reporting_term,
  so.term_name,
  so.time_started,
  so.date_submitted,
  so.respondent_name,
  so.respondent_email_address,
  so.question_code,
  so.response,
  so.subject_associate_id,
  so.is_manager,
  so.n_managers,
  so.n_peers,
  so.n_total,
  CASE
    WHEN so.academic_year <= 2017 THEN 1.0
    WHEN so.is_manager = 1 THEN CAST(so.n_total AS FLOAT) / 2.0 /* manager response weight */
    WHEN so.is_manager = 0 THEN (CAST(so.n_total AS FLOAT) / 2.0) / CAST(so.n_peers AS FLOAT) /* peer response weight */
  END AS response_weight,
  qk.question_text,
  CAST(qk.open_ended AS VARCHAR(5)) AS open_ended,
  CAST(rs.response_value AS FLOAT) AS response_value
FROM
  so_long AS so
  INNER JOIN gabby.surveys.question_key AS qk ON so.question_code = qk.question_code
  AND qk.survey_type = 'SO'
  LEFT JOIN gabby.surveys.response_scales AS rs ON so.response = rs.response_text
  AND so.survey_type = rs.survey_type
