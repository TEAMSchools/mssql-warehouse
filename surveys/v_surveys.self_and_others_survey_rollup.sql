USE gabby
GO

CREATE OR ALTER VIEW surveys.self_and_others_survey_rollup AS

SELECT survey_type
      ,academic_year
      ,reporting_term
      ,term_name            
      ,subject_employee_number
      ,subject_name
      ,subject_location
      ,subject_legal_entity_name
      ,subject_primary_site_schoolid
      ,subject_primary_site_school_level
      ,subject_manager_id
      ,subject_username
      ,subject_manager_name
      ,subject_manager_username
      ,question_code
      ,question_text     
      
      ,ROUND(AVG(response_value), 1) AS avg_response_value
      ,SUM(response_weight) AS total_response_weight
      ,SUM(response_value_weighted) AS total_weighted_response_value
      ,ROUND(SUM(response_value_weighted) / SUM(response_weight), 1) AS avg_weighted_response_value
      ,MAX(avg_response_value_location) AS avg_response_value_location
FROM gabby.surveys.self_and_others_survey_detail
WHERE open_ended = 'N'
GROUP BY survey_type
        ,academic_year
        ,reporting_term
        ,term_name   
        ,subject_employee_number         
        ,subject_name
        ,subject_location
        ,subject_legal_entity_name
        ,subject_primary_site_schoolid
        ,subject_primary_site_school_level
        ,subject_manager_id
        ,subject_username
        ,subject_manager_name
        ,subject_manager_username
        ,question_code
        ,question_text