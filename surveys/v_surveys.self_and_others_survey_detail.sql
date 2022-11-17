USE gabby
GO

CREATE OR ALTER VIEW surveys.self_and_others_survey_detail AS

SELECT d.survey_id
      ,d.survey_title
      ,d.survey_response_id
      ,d.campaign_academic_year
      ,d.date_started
      ,d.date_submitted
      ,d.campaign_name
      ,CAST(d.campaign_reporting_term AS VARCHAR(25)) AS campaign_reporting_term
      ,d.is_open_ended
      ,CAST(d.question_shortname AS VARCHAR(250)) AS question_shortname
      ,d.question_title
      ,d.answer
      ,d.answer_value
      ,d.respondent_df_employee_number
      ,d.respondent_preferred_name
      ,r.primary_race_ethnicity_reporting AS respondent_race_ethnicity_reporting
      ,r.gender AS respondent_gender
      ,d.respondent_mail
      ,d.is_manager
      ,d.subject_df_employee_number
      ,d.subject_adp_associate_id
      ,d.subject_preferred_name
      ,s.primary_race_ethnicity_reporting AS subject_race_ethnicity_reporting
      ,s.gender AS subject_gender
      ,s.legal_entity_name AS subject_legal_entity_name
      ,s.primary_site AS subject_primary_site
      ,d.subject_primary_site_schoolid
      ,d.subject_primary_site_school_level
      ,s.manager_df_employee_number AS subject_manager_df_employee_number
      ,d.subject_samaccountname
      ,s.manager_preferred_last_name + ', ' + s.manager_preferred_first_name AS subject_manager_name
      ,s.manager_samaccountname AS subject_manager_samaccountname
      ,d.subject_primary_job AS subject_role 
      ,d.subject_department_name
      ,s.grades_taught AS subject_grades_taught
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
LEFT JOIN gabby.people.staff_crosswalk_static s
  ON d.subject_df_employee_number = s.df_employee_number
LEFT JOIN gabby.people.staff_crosswalk_static r
  ON d.respondent_df_employee_number = r.df_employee_number
WHERE d.survey_title = 'Self and Others'
  AND d.rn_respondent_subject = 1
  AND d.campaign_academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)

UNION ALL 

SELECT NULL AS survey_id
      ,a.survey_type AS survey_title
      ,a.response_id AS survey_response_id
      ,a.academic_year AS campaign_academic_year
      ,NULL AS date_started
      ,CAST(a.date_submitted AS DATE)
      ,a.reporting_term AS campaign_name
      ,a.reporting_term AS campaign_reporting_term
      ,a.open_ended AS is_open_ended
      ,a.question_code AS question_shortname
      ,CAST(a.question_text AS VARCHAR(500)) AS question_title
      ,a.response AS answer
      ,a.response_value AS answer_value
      ,NULL AS respondent_df_employee_number
      ,a.respondent_name AS respondent_preferred_name
      ,r.primary_race_ethnicity_reporting AS respondent_race_ethnicity_reporting
      ,r.gender AS respondent_gender
      ,a.respondent_email_address AS respondent_mail
      ,a.is_manager
      ,a.subject_employee_number AS subject_df_employee_number
      ,a.subject_associate_id AS subject_adp_associate_id
      ,a.subject_name AS subject_preferred_name
      ,s.primary_race_ethnicity_reporting AS subject_race_ethnicity_reporting
      ,s.gender AS subject_gender
      ,a.subject_legal_entity_name
      ,a.subject_location AS subject_primary_site
      ,a.subject_primary_site_schoolid
      ,a.subject_primary_site_school_level
      ,a.subject_manager_id AS subject_manager_df_employee_number
      ,a.subject_username AS subject_samaccountname
      ,a.subject_manager_name
      ,a.subject_manager_username AS subject_manager_samaccountname
      ,w.job_title AS subject_role
      ,w.home_department AS subject_department_name
      ,NULL AS primary_grade_taught
      ,a.response_weight
      ,a.response_value_weighted AS answer_value_weighted
FROM gabby.surveys.self_and_others_survey_detail_archive a 
LEFT JOIN gabby.people.employment_history_static w
  ON a.subject_employee_number = w.employee_number
 AND a.date_submitted BETWEEN w.effective_start_date AND w.effective_end_date
 AND w.primary_position = 'Yes'
 AND w.position_status <> 'Terminated'
LEFT JOIN gabby.people.staff_crosswalk_static s
  ON a.subject_employee_number = s.df_employee_number
LEFT JOIN gabby.people.staff_crosswalk_static r
  ON a.respondent_email_address = r.samaccountname
