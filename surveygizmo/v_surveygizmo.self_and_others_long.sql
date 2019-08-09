USE gabby
GO

CREATE OR ALTER VIEW surveygizmo.self_and_others_survey_long AS

WITH so_long AS (
  SELECT sub.response_id
        ,sub.academic_year
        ,sub.term_name
        ,sub.reporting_term
        ,sub.time_started
        ,sub.date_submitted
        ,sub.respondent_name
        ,sub.respondent_email_address
        ,sub.subject_name
        ,sub.subject_associate_id
        ,sub.is_manager
        ,sub.question_code
        ,sub.response
        ,sub.survey_type
        ,SUM(sub.is_manager) OVER(PARTITION BY sub.academic_year, sub.reporting_term, sub.subject_associate_id, sub.question_code) AS n_managers
        ,COUNT(CASE WHEN sub.is_manager = 0 THEN sub.respondent_email_address END) OVER(PARTITION BY sub.academic_year, sub.reporting_term, subject_associate_id, sub.question_code) AS n_peers
        ,COUNT(sub.respondent_email_address) OVER(PARTITION BY sub.academic_year, sub.reporting_term, sub.subject_associate_id, sub.question_code) AS n_total
  FROM
      (
       SELECT CONVERT(INT,u.submission_id) AS response_id
             ,CONVERT(INT,u.academic_year) AS academic_year
             ,CASE WHEN u.reporting_term = 'SO1' THEN 'PM1'
                   WHEN u.reporting_term = 'SO2' THEN 'PM2'
                   WHEN u.reporting_term = 'SO3' THEN 'PM3'
                   WHEN u.reporting_term = 'SO4' THEN 'PM4'
                   END AS term_name
             ,COALESCE(CONVERT(VARCHAR(25),u.reporting_term),CONVERT(VARCHAR(25),u.campaign_name)) AS reporting_term
             ,u.date_started AS time_started
             ,u.date_submitted
             ,CONVERT(VARCHAR(125),u.respondent_name) AS respondent_name
             ,CONVERT(VARCHAR(125),u.respondent_email_addresst) AS respondent_email_address
             ,CONVERT(VARCHAR(125),u.subject_name) AS subject_name
             ,CONVERT(VARCHAR(25),u.subject_associate_id) AS subject_associate_id
             ,CONVERT(INT,u.is_manager) AS is_manager
             ,CONVERT(VARCHAR(25),u.question_code) AS question_code
             ,u.answer AS response
             ,CASE WHEN u.academic_year <= 2017 THEN 'SO' ELSE 'SO2018' END AS survey_type
       FROM gabby.surveygizmo.self_and_others_wide
       WHERE rn_submission = 1
       UNPIVOT(
         answer
         FOR question_code IN (SO_1
                              ,SO_2
                              ,SO_3
                              ,SO_4
                              ,SO_5
                              ,SO_6
                              ,SO_7
                              ,SO_oe1
                              ,SO_oe2
                              ,SO_m1
                              ,SO_m2
                              ,SO_m3)
        ) u
   ) sub
 )

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
      ,CASE 
        WHEN so.academic_year <= 2017 THEN 1.0
        WHEN so.is_manager = 1 THEN CONVERT(FLOAT,so.n_total) / 2.0 /* manager response weight */
        WHEN so.is_manager = 0 THEN (CONVERT(FLOAT,so.n_total) / 2.0) / CONVERT(FLOAT,so.n_peers) /* peer response weight */
       END AS response_weight

      ,qk.question_text
      ,CONVERT(VARCHAR(5),qk.open_ended) AS open_ended

      ,CONVERT(FLOAT,rs.response_value) AS response_value
FROM so_long so
JOIN gabby.surveys.question_key qk
  ON so.question_code = qk.question_code
 AND qk.survey_type = 'SO'
LEFT JOIN gabby.surveys.response_scales rs
  ON so.response = rs.response_text
 AND so.survey_type = rs.survey_type 