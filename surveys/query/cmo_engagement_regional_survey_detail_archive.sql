WITH
  historical AS (
    SELECT
      NULL AS survey_id,
      'CMO Survey (Historic)' AS survey_title,
      NULL AS survey_response_id,
      c.academic_year AS campaign_academic_year,
      NULL AS date_started,
      NULL AS date_submitted,
      CASE
        WHEN c.term_name = 'fall' THEN 'R9S1'
        WHEN c.term_name = 'spring' THEN 'R9S2'
        ELSE NULL
      END AS campaign_name,
      CASE
        WHEN c.term_name = 'fall' THEN 'R9S1'
        WHEN c.term_name = 'spring' THEN 'R9S2'
        ELSE NULL
      END AS campaign_reporting_term,
      CASE
        WHEN c.is_oe = 1 THEN 'Y'
        ELSE 'N'
      END AS is_open_ended,
      c.question AS question_shortname,
      NULL AS question_title,
      CAST(c.response_text AS NVARCHAR(MAX)) AS answer,
      c.response_value AS answer_value,
      c.df_employee_number AS respondent_df_employee_number,
      NULL AS respondent_adp_associate_id,
      NULL AS respondent_preferred_name,
      c.email AS respondent_mail,
      NULL AS is_manager,
      NULL AS respondent_department_name,
      NULL AS respondent_legal_entity_name,
      NULL AS respondent_manager_name,
      c.primary_job AS respondent_primary_job,
      c.primary_site AS respondent_primary_site
    FROM
      surveys.cmo_survey_final AS c
    UNION ALL
    SELECT
      NULL AS survey_id,
      'Engagement & Regional Survey (Historic)' AS survey_title,
      e.participant_id AS survey_response_id,
      e.academic_year AS campaign_academic_year,
      NULL AS date_started,
      NULL AS date_submitted,
      e.reporting_term AS campaign_name,
      e.reporting_term AS campaign_reporting_term,
      'N' AS is_open_ended,
      e.question_code AS question_shortname,
      q.question_text AS question_title,
      CAST(e.response_value AS NVARCHAR(MAX)) AS answer,
      e.response_value AS answer_value,
      NULL AS respondent_df_employee_number,
      e.associate_id AS respondent_adp_associate_id,
      NULL AS respondent_preferred_name,
      e.email AS respondent_mail,
      NULL AS is_manager,
      NULL AS respondent_department_name,
      e.region AS respondent_legal_entity_name,
      NULL AS respondent_manager_name,
      NULL AS respondent_primary_job,
      e.location AS respondent_primary_site
    FROM
      surveys.r9engagement_survey_detail AS e
      LEFT JOIN surveys.question_key AS q ON e.academic_year = q.academic_year
      AND e.question_code = q.question_code
      AND q.survey_type = 'CMO'
    UNION ALL
    SELECT
      NULL AS survey_id,
      'Engagement & Regional Survey (Historic)' AS survey_title,
      oe.participant_id AS survey_response_id,
      oe.academic_year AS campaign_academic_year,
      NULL AS date_started,
      NULL AS date_submitted,
      oe.reporting_term AS campaign_name,
      oe.reporting_term AS campaign_reporting_term,
      'Y' AS is_open_ended,
      oe.question_code AS question_shortname,
      q.question_text AS question_title,
      CAST(oe.response_value AS NVARCHAR(MAX)) AS answer,
      NULL AS answer_value,
      NULL AS respondent_df_employee_number,
      oe.associate_id AS respondent_adp_associate_id,
      NULL AS respondent_preferred_name,
      oe.email AS respondent_mail,
      NULL AS is_manager,
      NULL AS respondent_department_name,
      oe.region AS respondent_legal_entity_name,
      NULL AS respondent_manager_name,
      NULL AS respondent_primary_job,
      oe.location AS respondent_primary_site
    FROM
      surveys.r9engagement_survey_oe AS oe
      LEFT JOIN surveys.question_key AS q ON oe.academic_year = q.academic_year
      AND oe.question_code = q.question_code
      AND q.survey_type = 'CMO'
  )
SELECT
  CAST(h.survey_id AS BIGINT) AS survey_id,
  CAST(h.survey_title AS NVARCHAR(256)) AS survey_title,
  CAST(h.survey_response_id AS BIGINT) AS survey_response_id,
  CAST(h.campaign_academic_year AS INT) AS campaign_academic_year,
  CAST(h.date_started AS DATE) AS date_started,
  CAST(h.date_submitted AS DATE) AS date_submitted,
  CAST(h.campaign_name AS NVARCHAR(256)) AS campaign_name,
  CAST(h.campaign_reporting_term AS NVARCHAR(256)) AS campaign_reporting_term,
  CAST(h.is_open_ended AS VARCHAR(1)) AS is_open_ended,
  CAST(h.question_shortname AS NVARCHAR(256)) AS question_shortname,
  CAST(h.question_title AS VARCHAR(500)) AS question_title,
  CAST(h.answer AS NVARCHAR(MAX)) AS answer,
  CAST(h.answer_value AS VARCHAR(500)) AS answer_value,
  CAST(h.respondent_df_employee_number AS BIGINT) AS respondent_df_employee_number,
  CAST(
    h.respondent_adp_associate_id AS VARCHAR(25)
  ) AS respondent_adp_associate_id,
  CAST(h.respondent_preferred_name AS VARCHAR(125)) AS respondent_preferred_name,
  CAST(h.respondent_mail AS VARCHAR(125)) AS respondent_mail,
  CAST(h.is_manager AS INT) AS is_manager,
  CAST(
    h.respondent_department_name AS NVARCHAR(256)
  ) AS respondent_department_name,
  CAST(
    h.respondent_legal_entity_name AS NVARCHAR(256)
  ) AS respondent_legal_entity_name,
  CAST(h.respondent_manager_name AS VARCHAR(125)) AS respondent_manager_name,
  CAST(h.respondent_primary_job AS NVARCHAR(256)) AS respondent_primary_job,
  CAST(h.respondent_primary_site AS NVARCHAR(256)) AS respondent_primary_site INTO gabby.surveys.cmo_engagement_regional_survey_detail_archive
FROM
  historical AS h
