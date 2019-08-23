USE gabby
GO

--CREATE OR ALTER VIEW surveygizmo.self_and_others_detail AS

SELECT d.survey_title AS survey_type
      ,d.survey_response_id AS response_id
      ,d.academic_year
      ,d.reporting_term
      ,d.campaign_name AS term_name
      ,d.date_started AS time_started
      ,d.date_submitted AS date_submitted
      ,d.respondant_name
      ,d.respondant_email_address
      ,d.question_shortname AS question_code
      ,d.answer AS response
      ,d.subject_df_employee_number AS subject_associate_id
      ,d.is_manager
      ,d.n_managers
      ,d.n_peers
      ,d.n_total
      ,d.question_text
      ,CASE WHEN question_shortname LIKE '%oe%' THEN 'Y' ELSE 'N' END as open_ended
      ,d.answer_value AS response_value

      ,CASE WHEN d.n_peers = 0 OR d.n_manager = 0 THEN d.answer_value * d.response_weight * 2
            ELSE d.answer_value * d.response_weight
       END AS response_value_weighted
      ,d.subject_df_id AS subject_employee_number
      ,d.preferred_name AS subject_name
      ,d.legal_entity_during_survey AS subject_legal_entity_name
      ,d.location_during_survey AS subject_location
      ,COALESCE(dfid.primary_site_schoolid, adpid.primary_site_schoolid) AS subject_primary_site_schoolid
      ,COALESCE(dfid.primary_site_school_level, adpid.primary_site_school_level) AS subject_primary_site_school_level
      ,d.manager_df_employee_number
      ,LEFT(d.subject_email,CHARINDEX('@',d.subject_email)-1) AS subject_username
      ,d.manager_current AS subject_manager_name
      ,LEFT(d.manager_email, CHARINDEX('@',d.manager_email)-1) AS subject_manager_username
      ,NULL AS avg_response_value_location

FROM gabbysurveygizmo.survey_detail_clean d
LEFT JOIN gabby.people.staff_crosswalk_static dfid
  ON d.subject_df_id = CONVERT(VARCHAR,dfid.df_employee_number)
LEFT JOIN gabby.people.staff_crosswalk_static adpid
  ON d.subject_df_idd = adpid.adp_associate_id
WHERE d.survey_title = 'Self & Others'
  AND CONVERT(DATE,d.date_submitted) > CONVERT(DATE,'2019-07-01')

UNION ALL 

SELECT *
FROM surveys.self_and_others_survey_detail