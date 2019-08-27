USE gabby
GO

CREATE OR ALTER VIEW surveygizmo.survey_detail AS

WITH survey_response_scaffold AS (
  SELECT s.survey_id
        ,s.title AS survey_title

        ,sr.survey_response_id
        ,sr.contact_id
        ,sr.date_started
        ,sr.date_submitted
        ,sr.response_time

        ,sc.academic_year
        ,sc.[name] AS campaign_name

        ,sri.respondent_df_employee_number
        ,sri.respondent_preferred_name
        ,sri.respondent_adp_associate_id
        ,sri.respondent_userprincipalname
        ,sri.respondent_mail
        ,sri.respondent_samaccountname
        ,sri.respondent_legal_entity_name
        ,sri.respondent_primary_site
        ,sri.respondent_department_name
        ,sri.respondent_primary_job
        ,sri.respondent_primary_site_schoolid
        ,sri.respondent_primary_site_school_level
        ,sri.respondent_manager_df_employee_number
        ,sri.respondent_manager_name
        ,sri.respondent_manager_mail
        ,sri.respondent_manager_userprincipalname
        ,sri.respondent_manager_samaccountname
        ,sri.subject_df_employee_number
        ,sri.subject_preferred_name
        ,sri.subject_adp_associate_id
        ,sri.subject_userprincipalname
        ,sri.subject_mail
        ,sri.subject_samaccountname
        ,sri.subject_legal_entity_name
        ,sri.subject_primary_site
        ,sri.subject_department_name
        ,sri.subject_primary_job
        ,sri.subject_primary_site_schoolid
        ,sri.subject_primary_site_school_level
        ,sri.subject_manager_df_employee_number
        ,sri.subject_manager_name
        ,sri.subject_manager_mail
        ,sri.subject_manager_userprincipalname
        ,sri.subject_manager_samaccountname
        ,sri.is_manager
        
        ,ROW_NUMBER() OVER(
           PARTITION BY s.survey_id, sc.academic_year, sc.[name], sri.respondent_df_employee_number, sri.subject_df_employee_number
             ORDER BY sr.date_submitted DESC) AS rn_respondent_survey
  FROM gabby.surveygizmo.survey_clean s
  JOIN gabby.surveygizmo.survey_response_clean sr
    ON s.survey_id = sr.survey_id
   AND sr.[status] = 'Complete'
  LEFT JOIN gabby.surveygizmo.survey_campaign_clean sc
    ON sr.survey_id = sc.survey_id
   AND sr.date_started BETWEEN sc.link_open_date AND sc.link_close_date
  LEFT JOIN gabby.surveygizmo.survey_response_identifiers_static sri
    ON sr.survey_id = sri.survey_id
   AND sr.survey_response_id = sri.survey_response_id
 )

SELECT srs.survey_id
      ,srs.survey_title
      ,srs.survey_response_id
      ,srs.contact_id
      ,srs.date_started
      ,srs.date_submitted
      ,srs.response_time
      ,srs.academic_year
      ,srs.campaign_name
      ,srs.respondent_df_employee_number
      ,srs.respondent_preferred_name
      ,srs.respondent_adp_associate_id
      ,srs.respondent_userprincipalname
      ,srs.respondent_mail
      ,srs.respondent_samaccountname
      ,srs.respondent_legal_entity_name
      ,srs.respondent_primary_site
      ,srs.respondent_department_name
      ,srs.respondent_primary_job
      ,srs.respondent_primary_site_schoolid
      ,srs.respondent_primary_site_school_level
      ,srs.respondent_manager_df_employee_number
      ,srs.respondent_manager_name
      ,srs.respondent_manager_mail
      ,srs.respondent_manager_userprincipalname
      ,srs.respondent_manager_samaccountname
      ,srs.subject_df_employee_number
      ,srs.subject_preferred_name
      ,srs.subject_adp_associate_id
      ,srs.subject_userprincipalname
      ,srs.subject_mail
      ,srs.subject_samaccountname
      ,srs.subject_legal_entity_name
      ,srs.subject_primary_site
      ,srs.subject_department_name
      ,srs.subject_primary_job
      ,srs.subject_primary_site_schoolid
      ,srs.subject_primary_site_school_level
      ,srs.subject_manager_df_employee_number
      ,srs.subject_manager_name
      ,srs.subject_manager_mail
      ,srs.subject_manager_userprincipalname
      ,srs.subject_manager_samaccountname
      ,srs.is_manager
      ,srs.rn_respondent_survey

      ,sq.shortname AS question_shortname
      ,sq.title_clean AS question_title
      ,sq.[type] AS question_type
      ,sq.is_open_ended

      ,COALESCE(qo.title_english, srd.answer) AS answer
      ,qo.value AS answer_value
FROM survey_response_scaffold srs
JOIN gabby.surveygizmo.survey_question_clean_static sq
  ON srs.survey_id = sq.survey_id
 AND sq.base_type = 'Question'
LEFT JOIN gabby.surveygizmo.survey_response_data_static srd
  ON srs.survey_id = srd.survey_id
 AND srs.survey_response_id = srd.survey_response_id
 AND sq.survey_question_id = srd.question_id
LEFT JOIN gabby.surveygizmo.survey_question_options_static qo
  ON srs.survey_id = qo.survey_id
 AND sq.survey_question_id = qo.question_id
 AND srd.answer_id = qo.option_id