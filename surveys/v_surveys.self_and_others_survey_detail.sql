USE gabby
GO

CREATE OR ALTER VIEW surveys.self_and_others_survey_detail AS

SELECT so.survey_type
      ,so.response_id
      ,so.academic_year
      ,so.reporting_term
      ,so.term_name
      ,so.time_started
      ,so.date_submitted      
      ,so.respondent_name
      ,so.respondent_email_address
      ,so.question_code
      ,so.response
      ,so.subject_associate_id
      ,so.is_manager
      ,so.n_managers
      ,so.n_peers
      ,so.n_total           
      ,so.question_text
      ,so.open_ended
      ,so.response_value
      ,so.response_weight
      ,(so.response_value * so.response_weight) AS response_value_weighted

      ,COALESCE(dfid.df_employee_number, adpid.df_employee_number) AS subject_employee_number
      ,COALESCE(CONCAT(dfid.preferred_first_name, ' ', dfid.preferred_last_name) 
               ,CONCAT(adpid.preferred_first_name, ' ', adpid.preferred_last_name)) AS subject_name
      ,COALESCE(dfid.legal_entity_name, adpid.legal_entity_name) AS subject_legal_entity_name
      ,CONVERT(VARCHAR,COALESCE(dfid.primary_site, adpid.primary_site)) AS subject_location
      ,COALESCE(dfid.primary_site_schoolid, adpid.primary_site_schoolid) AS subject_primary_site_schoolid
      ,COALESCE(dfid.primary_site_school_level, adpid.primary_site_school_level) AS subject_primary_site_school_level
      ,COALESCE(dfid.manager_df_employee_number, adpid.manager_df_employee_number) AS subject_manager_id      

      ,COALESCE(dfid.samaccountname, adpid.samaccountname) AS subject_username

      ,COALESCE(dfid.preferred_name, adpid.preferred_name) AS subject_manager_name
      ,COALESCE(dfid.manager_samaccountname, adpid.manager_samaccountname) AS subject_manager_username

      ,NULL AS avg_response_value_location
FROM gabby.surveys.self_and_others_survey_long_static so
LEFT JOIN gabby.people.staff_crosswalk_static dfid
  ON so.subject_associate_id = CONVERT(VARCHAR,dfid.df_employee_number)
LEFT JOIN gabby.people.staff_crosswalk_static adpid
  ON so.subject_associate_id = adpid.adp_associate_id