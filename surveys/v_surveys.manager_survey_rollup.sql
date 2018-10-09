USE gabby
GO

CREATE OR ALTER VIEW surveys.manager_survey_rollup AS

SELECT survey_type
      ,academic_year
      ,reporting_term
      ,term_name            
      ,subject_name
      ,subject_location
      ,region AS subject_legal_entity_name
      ,reporting_schoolid AS subject_primary_site_schoolid
      ,school_level AS subject_primary_site_school_level
      ,subject_manager_id
      ,subject_username
      ,subject_manager_name
      ,subject_manager_username
      ,question_code
      ,question_text     
      
      ,AVG(response_value) AS avg_response_value
      ,MAX(avg_response_value_location) AS avg_response_value_location
FROM gabby.surveys.manager_survey_detail
WHERE open_ended = 'N'
GROUP BY survey_type
        ,academic_year
        ,reporting_term
        ,term_name            
        ,subject_name
        ,subject_location
        ,region
        ,reporting_schoolid
        ,school_level
        ,subject_manager_id
        ,subject_username
        ,subject_manager_name
        ,subject_manager_username
        ,question_code
        ,question_text