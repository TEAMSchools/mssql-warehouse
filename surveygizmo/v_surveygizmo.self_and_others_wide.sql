USE gabby
GO

--CREATE OR ALTER VIEW surveygizmo.self_and_others_wide AS: 

WITH so_repsonses AS (
  SELECT sr.survey_id 
        ,sr.survey_response_id

        ,src.date_started
        ,src.date_submitted
        ,src.response_time
        ,src.status
        ,src.contact_id
        ,sr.question
        ,sr.answer
        ,s.title AS survey_name
        ,sc.name AS campaign_name
        ,sq.shortname AS question_shortname
  FROM gabby.surveygizmo.survey_response_data sr
  LEFT JOIN gabby.surveygizmo.survey_response_clean src
    ON sr.survey_response_id = src.id
   AND sr.survey_id = src.survey_id
  LEFT JOIN gabby.surveygizmo.survey s
    ON sr.survey_id = s.id
  LEFT JOIN gabby.surveygizmo.survey_campaign sc
    ON sr.survey_id = sc.survey_id
   AND CONVERT(VARCHAR,src.date_submitted,103) BETWEEN CONVERT(VARCHAR,sc.link_open_date,103) AND CONVERT(VARCHAR,sc.link_close_date,103)
  LEFT JOIN gabby.surveygizmo.survey_question_clean sq
    ON sr.survey_id = sq.survey_id
   AND sr.question_id = sq.id
  WHERE s.title = 'Self and Others'
  )

,so_wide AS (
  SELECT survey_response_id
        ,survey_id 
        ,date_started
        ,date_submitted
        ,response_time
        ,status
        ,contact_id
        ,gabby.utilities.DATE_TO_SY(CONVERT(DATE,LEFT(date_submitted,10))) AS academic_year
        ,survey_name
        ,campaign_name
        ,reporting_term
        ,respondent_name
        ,respondent_email_address
        ,subject_name
        ,is_manager
        ,SO_1
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
        ,SO_m3
  FROM   (SELECT r.survey_response_id
                ,r.survey_id 
                ,r.date_started AS date_started
                ,r.date_submitted AS date_submitted
                ,r.response_time
                ,r.status
                ,r.contact_id
                ,r.survey_name
                ,r.campaign_name
                ,r.question_shortname
                ,r.answer
          FROM so_repsonses r) sub
  PIVOT (
           MAX(answer)
           FOR question_shortname in (reporting_term
                                     ,respondent_name
                                     ,respondent_email_address
                                     ,subject_name
                                     ,is_manager
                                     ,SO_1
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
                                     ,SO_m3
                                     ) 
          ) p
  )

SELECT survey_response_id
      ,survey_id 
      ,date_started
      ,date_submitted
      ,response_time
      ,status
      ,contact_id
      ,gabby.utilities.DATE_TO_SY(CONVERT(DATE,LEFT(date_submitted,10))) AS academic_year
      ,survey_name
      ,campaign_name
      ,reporting_term
      ,respondent_name
      ,respondent_email_address
      ,subject_name
      ,is_manager
      ,SO_1
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
      ,SO_m3
      ,RIGHT(LEFT(subject_name,LEN(subject_name)-1),6) AS subject_associate_id
      ,ROW_NUMBER() OVER( PARTITION BY academic_year, campaign_name, respondent_email_address, subject_name ORDER BY date_submitted DESC) AS rn_submission
FROM so_wide