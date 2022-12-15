USE gabby GO
CREATE OR ALTER VIEW
  surveys.manager_survey_long AS
WITH
  manager_long AS (
    SELECT
      response_id,
      academic_year,
      reporting_term,
      term_name,
      time_started,
      date_submitted,
      status,
      associate_id,
      salesforce_id,
      email_address,
      your_name_ AS respondent_name,
      manager_name,
      manager_associate_id,
      question_code,
      response
    FROM
      gabby.surveys.manager_survey_final UNPIVOT (
        response FOR question_code IN (
          q_1,
          q_2,
          q_3,
          q_4,
          q_5,
          q_6,
          q_7,
          q_8,
          q_9,
          q_10,
          q_11,
          q_12,
          q_13,
          q_14,
          q_15,
          q_16,
          q_17,
          q_18
        )
      ) u
  )
SELECT
  'MGR' AS survey_type,
  CAST(mgr.response_id AS INT) AS response_id,
  CAST(mgr.academic_year AS INT) AS academic_year,
  CAST(mgr.reporting_term AS VARCHAR(5)) AS reporting_term,
  CAST(mgr.term_name AS VARCHAR(5)) AS term_name,
  CAST(
    CASE
      WHEN ISDATE(mgr.time_started) = 0 THEN NULL
      ELSE mgr.time_started
    END AS DATETIME2
  ) AS time_started,
  CAST(
    CASE
      WHEN ISDATE(mgr.date_submitted) = 0 THEN NULL
      ELSE mgr.date_submitted
    END AS DATETIME2
  ) AS date_submitted,
  CAST(mgr.status AS VARCHAR(25)) AS status,
  CAST(mgr.associate_id AS VARCHAR(25)) AS respondent_associate_id,
  CAST(mgr.salesforce_id AS VARCHAR(25)) AS respondent_salesforce_id,
  CAST(mgr.email_address AS VARCHAR(125)) AS respondent_email_address,
  CAST(mgr.respondent_name AS VARCHAR(125)) AS respondent_name,
  CAST(mgr.manager_associate_id AS VARCHAR(25)) AS subject_associate_id,
  CAST(mgr.question_code AS VARCHAR(25)) AS question_code,
  mgr.response,
  qk.question_text,
  CAST(qk.open_ended AS VARCHAR(5)) AS open_ended,
  CAST(rs.response_value AS FLOAT) AS response_value
FROM
  manager_long AS mgr
  INNER JOIN gabby.surveys.question_key AS qk ON mgr.question_code = qk.question_code
  AND qk.survey_type = 'MGR'
  LEFT JOIN gabby.surveys.response_scales AS rs ON mgr.response = rs.response_text
  AND rs.survey_type = 'MGR'
