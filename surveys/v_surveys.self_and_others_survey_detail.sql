USE gabby
GO

--CREATE OR ALTER VIEW surveys.self_and_others_detail AS

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
       END AS response_weight
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

--UNION ALL 

--SELECT survey_type
--      ,response_id
--      ,campaign_academic_year
--      ,reporting_term
--      ,term_name
--      ,time_started
--      ,date_submitted
--      ,respondent_name
--      ,respondent_email_address
--      ,question_code
--      ,response
--      ,subject_associate_id
--      ,is_manager
--      ,n_managers
--      ,n_peers
--      ,n_total
--      ,question_text
--      ,open_ended
--      ,response_value
--      ,response_weight
--      ,response_value_weighted
--      ,subject_employee_number
--      ,subject_name
--      ,subject_legal_entity_name
--      ,subject_location
--      ,subject_primary_site_schoolid
--      ,subject_primary_site_school_level
--      ,subject_manager_id
--      ,subject_username
--      ,subject_manager_name
--      ,subject_manager_username
--      ,avg_response_value_location
--FROM surveys.self_and_others_survey_detail_archive