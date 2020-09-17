USE gabby
GO

CREATE OR ALTER VIEW surveys.manager_survey_detail AS

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
      ,s.legal_entity_name AS subject_legal_entity_name
      ,s.primary_site AS subject_primary_site
      ,d.subject_primary_site_schoolid
      ,d.subject_primary_site_school_level
      ,d.subject_manager_df_employee_number
      ,NULL AS subject_manager_adp_associate_id
      ,d.subject_samaccountname
      ,d.subject_manager_name
      ,d.subject_manager_samaccountname
      ,w.job_name AS subject_dayforce_role
FROM gabby.surveygizmo.survey_detail d
LEFT JOIN gabby.dayforce.employee_work_assignment w
  ON d.subject_df_employee_number = w.employee_reference_code
 AND d.date_submitted BETWEEN w.work_assignment_effective_start AND w.work_assignment_effective_end
 AND w.primary_work_assignment = 1
LEFT JOIN gabby.people.staff_crosswalk_static s
  ON d.subject_df_employee_number = s.df_employee_number
WHERE d.survey_title = 'Manager Survey'
  AND d.rn_respondent_subject = 1
  AND d.campaign_academic_year >= 2019

UNION ALL

SELECT NULL AS survey_id
      ,sda.survey_type AS survey_title
      ,sda.response_id AS survey_response_id
      ,sda.academic_year AS campaign_academic_year
      ,NULL AS date_started
      ,sda.date_submitted
      ,sda.reporting_term AS campaign_name
      ,sda.reporting_term AS campaign_reporting_term
      ,sda.open_ended AS is_open_ended
      ,sda.question_code AS question_shortname
      ,sda.question_text AS question_title
      ,sda.response AS answer
      ,sda.response_value AS answer_value
      ,NULL AS respondent_df_employee_number
      ,sda.respondent_name AS respondent_preferred_name
      ,sda.respondent_email_address AS respondent_mail
      ,NULL AS is_manager
      ,sda.subject_df_employee_number
      ,sda.subject_associate_id AS subject_adp_associate_id
      ,sda.subject_name AS subject_preferred_name
      ,sda.region AS subject_legal_entity_name
      ,sda.subject_location AS subject_primary_site
      ,sda.reporting_schoolid AS subject_primary_site_schoolid
      ,sda.school_level AS subject_primary_site_school_level
      ,sda.subject_manager_df_employee_number
      ,sda.subject_manager_id AS subject_manager_adp_associate_id
      ,COALESCE(sbjt.samaccountname, sda.subject_username) AS subject_samaccountname
      ,sda.subject_manager_name
      ,COALESCE(mgr.samaccountname, sda.subject_manager_username) AS subject_manager_samaccountname
      ,w.job_name AS subject_dayforce_role
FROM surveys.manager_survey_detail_archive  sda
LEFT JOIN gabby.people.staff_crosswalk_static sbjt
  ON sda.subject_df_employee_number = sbjt.df_employee_number
LEFT JOIN gabby.people.staff_crosswalk_static mgr
  ON sda.subject_manager_df_employee_number = mgr.df_employee_number
LEFT JOIN gabby.dayforce.employee_work_assignment w
  ON sda.subject_df_employee_number = w.employee_reference_code
 AND sda.date_submitted BETWEEN w.work_assignment_effective_start AND w.work_assignment_effective_end
 AND w.primary_work_assignment = 1