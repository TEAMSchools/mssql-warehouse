USE gabby
GO

CREATE OR ALTER VIEW surveys.self_and_others_detail AS

SELECT d.survey_id
      ,d.survey_title
      ,d.survey_response_id
      ,d.campaign_academic_year
      ,d.date_started
      ,d.date_submitted
      ,d.campaign_name
      ,d.campaign_reporting_term
      ,d.is_open_ended
      ,d.question_shortname
      ,d.question_title
      ,d.answer
      ,d.answer_value
      ,d.respondent_df_employee_number
      ,d.respondent_preferred_name
      ,d.respondent_mail
      ,d.is_manager
      ,d.subject_df_employee_number
      ,d.subject_adp_associate_id
      ,d.subject_preferred_name
      ,d.subject_legal_entity_name
      ,d.subject_primary_site
      ,d.subject_primary_site_schoolid
      ,d.subject_primary_site_school_level
      ,d.subject_manager_df_employee_number
      ,d.subject_samaccountname
      ,d.subject_manager_name
      ,d.subject_manager_samaccountname
      ,CASE 
        WHEN d.is_open_ended = 'Y' THEN NULL
        WHEN ISNUMERIC(d.answer_value) = 0 THEN NULL
        /* manager weight = half of total possible */
        WHEN d.is_manager = 1 
             THEN (COUNT(d.survey_response_id) OVER(PARTITION BY d.survey_id, d.campaign_academic_year, d.campaign_name, d.question_shortname, d.subject_df_employee_number) * 0.5) 
                    / SUM(d.is_manager) OVER(PARTITION BY d.survey_id, d.campaign_academic_year, d.campaign_name, d.question_shortname, d.subject_df_employee_number)
        /* peer weight = half of total possible */
        ELSE (COUNT(d.survey_response_id) OVER(PARTITION BY d.survey_id, d.campaign_academic_year, d.campaign_name, d.question_shortname, d.subject_df_employee_number) * 0.5)
               / SUM(ABS(d.is_manager - 1)) OVER(PARTITION BY d.survey_id, d.campaign_academic_year, d.campaign_name, d.question_shortname, d.subject_df_employee_number)
       END AS answer_weight
      ,CASE 
        WHEN d.is_open_ended = 'Y' THEN NULL
        WHEN ISNUMERIC(d.answer_value) = 0 THEN NULL
        /* manager weight = half of total possible */
        WHEN d.is_manager = 1 
             THEN (COUNT(d.survey_response_id) OVER(PARTITION BY d.survey_id, d.campaign_academic_year, d.campaign_name, d.question_shortname, d.subject_df_employee_number) * 0.5) 
                    / SUM(d.is_manager) OVER(PARTITION BY d.survey_id, d.campaign_academic_year, d.campaign_name, d.question_shortname, d.subject_df_employee_number)
                    * d.answer_value 
        ELSE (COUNT(d.survey_response_id) OVER(PARTITION BY d.survey_id, d.campaign_academic_year, d.campaign_name, d.question_shortname, d.subject_df_employee_number) * 0.5)
               / SUM(ABS(d.is_manager - 1)) OVER(PARTITION BY d.survey_id, d.campaign_academic_year, d.campaign_name, d.question_shortname, d.subject_df_employee_number)
               * d.answer_value 
       END AS answer_value_weighted
       /* DEBUG weighted average
      ,CASE
        WHEN d.is_open_ended = 'Y' THEN NULL
        ELSE COUNT(d.survey_response_id) OVER(PARTITION BY d.survey_id, d.campaign_academic_year, d.campaign_name, d.question_shortname, d.subject_df_employee_number) 
       END AS n_total
      ,SUM(d.is_manager) OVER(PARTITION BY d.survey_id, d.campaign_academic_year, d.campaign_name, d.question_shortname) AS n_managers
      ,SUM(ABS(d.is_manager - 1)) OVER(PARTITION BY d.survey_id, d.campaign_academic_year, d.campaign_name, d.question_shortname) AS n_peers
      ,COUNT(d.survey_response_id) OVER(PARTITION BY d.survey_id, d.campaign_academic_year, d.campaign_name, d.question_shortname) * 0.5 AS manager_peer_split
      ,(COUNT(d.survey_response_id) OVER(PARTITION BY d.survey_id, d.campaign_academic_year, d.campaign_name, d.question_shortname) * 0.5) 
         / SUM(d.is_manager) OVER(PARTITION BY d.survey_id, d.campaign_academic_year, d.campaign_name, d.question_shortname) AS manager_weight
      ,(COUNT(d.survey_response_id) OVER(PARTITION BY d.survey_id, d.campaign_academic_year, d.campaign_name, d.question_shortname) * 0.5) 
         / SUM(ABS(d.is_manager - 1)) OVER(PARTITION BY d.survey_id, d.campaign_academic_year, d.campaign_name, d.question_shortname) AS peer_weight
      --*/
FROM gabby.surveygizmo.survey_detail d
WHERE d.survey_title = 'Self and Others'
  AND d.rn_respondent_subject = 1
  AND d.campaign_academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

UNION ALL 

SELECT NULL AS survey_id
      ,survey_type AS survey_title
      ,response_id AS survey_response_id
      ,academic_year AS campaign_academic_year
      ,NULL AS date_started
      ,date_submitted
      ,reporting_term AS campaign_name
      ,reporting_term AS campaign_reporting_term
      ,open_ended AS is_open_ended
      ,question_code AS question_shortname
      ,question_text AS question_title
      ,response AS answer
      ,response_value AS answer_value
      ,NULL AS respondent_df_employee_number
      ,respondent_name AS respondent_preferred_name
      ,respondent_email_address AS respondent_mail
      ,is_manager
      ,subject_employee_number AS subject_df_employee_number
      ,subject_associate_id AS subject_adp_associate_id
      ,subject_name AS subject_preferred_name
      ,subject_legal_entity_name
      ,subject_location AS subject_primary_site
      ,subject_primary_site_schoolid
      ,subject_primary_site_school_level
      ,subject_manager_id AS subject_manager_df_employee_number
      ,subject_username AS subject_samaccountname
      ,subject_manager_name
      ,subject_manager_username AS subject_manager_samaccountname
      ,response_weight
      ,response_value_weighted AS answer_value_weighted
FROM surveys.self_and_others_survey_detail_archive