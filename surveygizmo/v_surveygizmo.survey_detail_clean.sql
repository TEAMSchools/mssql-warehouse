USE gabby
GO

CREATE OR ALTER VIEW surveygizmo.survey_detail_clean AS

WITH scaffold AS (

SELECT survey_id
      ,survey_response_id
      ,reporting_term
      ,respondent_name
      ,respondent_email_address
      ,subject_name
      ,CASE WHEN is_manager LIKE 'Yes%' THEN 1 
            WHEN is_manager LIKE 'No%' THEN 0
            ELSE is_manager
            END AS is_manager
FROM (SELECT survey_id
            ,survey_response_id
            ,shortname
            ,answer
      FROM surveygizmo.survey_detail
      WHERE shortname IN ('reporting_term'
                         ,'respondent_name'
                         ,'respondent_email_address'
                         ,'subject_name'
                         ,'is_manager')
      ) sub
PIVOT (
           MAX(answer)
           FOR shortname in (reporting_term
                            ,respondent_name
                            ,respondent_email_address
                            ,subject_name
                            ,is_manager)
     ) p

)

,all_responses_long AS (

SELECT s.survey_id
      ,s.survey_response_id
      ,s.reporting_term
      ,s.respondent_name
      ,s.respondent_email_address
      ,s.subject_name
      ,s.is_manager
      ,CASE WHEN s.subject_name LIKE '%]' THEN
                 SUBSTRING(s.subject_name,CHARINDEX('[', s.subject_name) + 1,(CHARINDEX(']', s.subject_name) - CHARINDEX('[', s.subject_name) - 1)) 
            ELSE null
       END AS subject_df_id
      ,d.survey_title
      ,d.contact_id
      ,d.date_started
      ,d.date_submitted
      ,d.response_time
      ,d.campaign_name
      ,d.academic_year
      ,d.shortname AS question_shortname
      ,d.title_english AS question_long
      ,d.answer
      
      ,CASE WHEN ISNUMERIC(d.answer_value) = 1
            THEN d.answer_value
            ELSE NULL
       END AS answer_value

      ,ROW_NUMBER() OVER( PARTITION BY d.academic_year, d.campaign_name, s.survey_id, s.respondent_email_address, s.subject_name, d.title_english ORDER BY date_submitted DESC) AS rn_submission

FROM scaffold s 
LEFT JOIN gabby.surveygizmo.survey_detail d
       ON s.survey_id = d.survey_id
      AND s.survey_response_id = d.survey_response_id
WHERE d.academic_year IS NOT NULL
  AND d.academic_year >= 2019
  AND d.shortname NOT IN ('reporting_term'
                         ,'respondent_name'
                         ,'respondent_email_address'
                         ,'subject_name'
                         ,'is_manager')
)

SELECT a.*

      ,w.legal_entity_name AS legal_entity_during_survey
      ,w.job_name AS job_during_survey
      ,w.physical_location_name AS location_during_survey

      ,r.preferred_name
      ,r.eeo_ethnic_description
      ,r.gender
      ,r.birth_date
      ,r.primary_address_zip_postal_code
      ,r.original_hire_date
      ,r.job_title_description AS job_current
      ,r.legal_entity_name AS legal_entity_current
      ,r.salesforce_job_position_name_custom 
      ,r.manager_name AS manager_current
      ,r.userprincipalname AS subject_email
      ,r.manager_df_employee_number

      ,m.userprincipalname AS manager_email

      ,CASE 
        WHEN a.academic_year <= 2017 THEN 1.0
        WHEN a.is_manager = 1 THEN CONVERT(FLOAT,a.n_total) / 2.0 /* manager response weight */
        WHEN a.is_manager = 0 THEN (CONVERT(FLOAT,a.n_total) / 2.0) / CONVERT(FLOAT,a.n_peers) /* peer response weight */
       END AS response_weight

FROM (SELECT *
            ,COUNT(a.respondent_email_address) OVER(PARTITION BY a.academic_year, a.reporting_term, a.subject_df_id, a.question_long) AS n_total
            ,SUM(a.is_manager) OVER(PARTITION BY a.survey_id, a.academic_year, a.reporting_term, a.subject_df_id, a.question_long) AS n_managers
            ,COUNT(CASE WHEN a.is_manager = 0 THEN a.respondent_email_address END) OVER(PARTITION BY a.academic_year, a.reporting_term, a.subject_df_id, a.question_long) AS n_peers
      FROM all_responses_long a 
      WHERE a.rn_submission = 1) a
LEFT JOIN dayforce.employee_work_assignment w
  ON a.subject_df_id = w.employee_reference_code
 AND a.date_submitted BETWEEN w.work_assignment_effective_start AND (CASE WHEN w.work_assignment_effective_end = '' OR ISNULL(w.work_assignment_effective_end,'') = '' THEN GETDATE() ELSE w.work_assignment_effective_end END)
LEFT JOIN tableau.staff_roster r
  ON a.subject_df_id = r.df_employee_number 
LEFT JOIN tableau.staff_roster m
  ON r.manager_df_employee_number = m.df_employee_number
WHERE rn_submission = 1
  AND w.primary_work_assignment = 1