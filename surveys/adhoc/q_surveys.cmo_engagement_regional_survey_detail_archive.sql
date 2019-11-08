WITH historical AS (
 SELECT NULL AS survey_id
       ,'CMO Survey (Historic)' AS survey_title
       ,NULL AS survey_response_id
       ,c.academic_year AS campaign_academic_year
       ,NULL AS date_started
       ,NULL AS date_submitted
       ,CASE
         WHEN c.term_name = 'fall' THEN 'R9S1'
         WHEN c.term_name = 'spring' THEN 'R9S2'
         ELSE NULL
        END AS campaign_name
       ,CASE
         WHEN c.term_name = 'fall' THEN 'R9S1'
         WHEN c.term_name = 'spring' THEN 'R9S2'
         ELSE NULL
        END AS campaign_reporting_term
       ,CASE
         WHEN c.is_oe = 1 THEN 'Y'
         ELSE 'N'
        END AS is_open_ended
       ,c.question AS question_shortname
       ,NULL AS question_title
       ,CONVERT(NVARCHAR(MAX), c.response_text) AS answer
       ,c.response_value AS answer_value
       ,c.df_employee_number AS respondent_df_employee_number
       ,NULL AS respondent_adp_associate_id
       ,NULL AS respondent_preferred_name
       ,c.email AS respondent_mail
       ,NULL AS is_manager
       ,NULL AS respondent_department_name
       ,NULL AS respondent_legal_entity_name
       ,NULL AS respondent_manager_name
       ,c.primary_job AS respondent_primary_job
       ,c.primary_site AS respondent_primary_site
 FROM surveys.cmo_survey_final c
 
 UNION ALL
 
 SELECT NULL AS survey_id
       ,'Engagement & Regional Survey (Historic)' AS survey_title
       ,e.participant_id AS survey_response_id
       ,e.academic_year AS campaign_academic_year
       ,NULL AS date_started
       ,NULL AS date_submitted
       ,e.reporting_term AS campaign_name
       ,e.reporting_term AS campaign_reporting_term
       ,'N' AS is_open_ended
       ,e.question_code AS question_shortname
       ,q.question_text AS question_title
       ,CONVERT(NVARCHAR(MAX), e.response_value) AS answer
       ,e.response_value AS answer_value
       ,NULL AS respondent_df_employee_number
       ,e.associate_id AS respondent_adp_associate_id
       ,NULL AS respondent_preferred_name
       ,e.email AS respondent_mail
       ,NULL AS is_manager
       ,NULL AS respondent_department_name
       ,e.region AS respondent_legal_entity_name
       ,NULL AS respondent_manager_name
       ,NULL AS respondent_primary_job
       ,e.location AS respondent_primary_site
 FROM surveys.r9engagement_survey_detail e
 LEFT JOIN surveys.question_key q
   ON e.academic_year = q.academic_year
  AND e.question_code = q.question_code
  AND q.survey_type = 'CMO'

 UNION ALL

 SELECT NULL AS survey_id
       ,'Engagement & Regional Survey (Historic)' AS survey_title
       ,oe.participant_id AS survey_response_id
       ,oe.academic_year AS campaign_academic_year
       ,NULL AS date_started
       ,NULL AS date_submitted
       ,oe.reporting_term AS campaign_name
       ,oe.reporting_term AS campaign_reporting_term
       ,'Y' AS is_open_ended
       ,oe.question_code AS question_shortname
       ,q.question_text AS question_title
       ,CONVERT(NVARCHAR(MAX), oe.response_value) AS answer
       ,NULL AS answer_value
       ,NULL AS respondent_df_employee_number
       ,oe.associate_id AS respondent_adp_associate_id
       ,NULL AS respondent_preferred_name
       ,oe.email AS respondent_mail
       ,NULL AS is_manager
       ,NULL AS respondent_department_name
       ,oe.region AS respondent_legal_entity_name
       ,NULL AS respondent_manager_name
       ,NULL AS respondent_primary_job
       ,oe.location AS respondent_primary_site
 FROM surveys.r9engagement_survey_oe oe
 LEFT JOIN surveys.question_key q
   ON oe.academic_year = q.academic_year
  AND oe.question_code = q.question_code
  AND q.survey_type = 'CMO'
)

SELECT CONVERT(BIGINT, h.survey_id) AS survey_id
      ,CONVERT(NVARCHAR(256), h.survey_title) AS survey_title
      ,CONVERT(BIGINT, h.survey_response_id) AS survey_response_id
      ,CONVERT(INT, h.campaign_academic_year) AS campaign_academic_year
      ,CONVERT(DATE, h.date_started) AS date_started
      ,CONVERT(DATE, h.date_submitted) AS date_submitted
      ,CONVERT(NVARCHAR(256), h.campaign_name) AS campaign_name
      ,CONVERT(NVARCHAR(256), h.campaign_reporting_term) AS campaign_reporting_term
      ,CONVERT(VARCHAR(1), h.is_open_ended) AS is_open_ended
      ,CONVERT(NVARCHAR(256), h.question_shortname) AS question_shortname
      ,CONVERT(VARCHAR(500), h.question_title) AS question_title
      ,CONVERT(NVARCHAR(MAX), h.answer) AS answer
      ,CONVERT(VARCHAR(500), h.answer_value) AS answer_value
      ,CONVERT(BIGINT, h.respondent_df_employee_number) AS respondent_df_employee_number
      ,CONVERT(VARCHAR(25), h.respondent_adp_associate_id) AS respondent_adp_associate_id
      ,CONVERT(VARCHAR(125), h.respondent_preferred_name) AS respondent_preferred_name
      ,CONVERT(VARCHAR(125), h.respondent_mail) AS respondent_mail
      ,CONVERT(INT, h.is_manager) AS is_manager
      ,CONVERT(NVARCHAR(256), h.respondent_department_name) AS respondent_department_name
      ,CONVERT(NVARCHAR(256), h.respondent_legal_entity_name) AS respondent_legal_entity_name
      ,CONVERT(VARCHAR(125), h.respondent_manager_name) AS respondent_manager_name
      ,CONVERT(NVARCHAR(256), h.respondent_primary_job) AS respondent_primary_job
      ,CONVERT(NVARCHAR(256), h.respondent_primary_site) AS respondent_primary_site
INTO gabby.surveys.cmo_engagement_regional_survey_detail_archive
FROM historical h