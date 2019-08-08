USE gabby
GO

CREATE OR ALTER TABLE surveygizmo.self_and_others_wide AS: 

WITH questions AS (
  SELECT sq.survey_id
      ,sq.id AS question_id
      ,sq.type AS question_type
      ,sq.shortname AS question_shortname

      ,nested.English AS question
FROM gabby.surveygizmo.survey_question sq
CROSS APPLY OPENJSON(title, '$')
  WITH (  
    English VARCHAR(MAX)
   ) AS nested
   )

,responses AS (
  SELECT sr.survey_id
        ,sr.id
        ,sr.date_started
        ,sr.date_submitted
        ,sr.response_time
        ,sr.status
        ,sr.contact_id

        ,nested.id AS response_id
        ,nested.type
        ,nested.question
        ,nested.shown
        ,nested.answer
  FROM gabby.surveygizmo.survey_response sr
  CROSS APPLY OPENJSON(survey_data, '$')
    WITH (
      id BIGINT,
      type VARCHAR(125),    
      question VARCHAR(MAX),
      shown BIT,
      answer VARCHAR(MAX)
     ) AS nested
  WHERE sr.status = 'Complete'
    AND sr.is_test_data = 0
  )

,so_repsonses AS (
  SELECT sr.survey_id 
        ,sr.id AS submission_id
        ,sr.date_started
        ,sr.date_submitted
        ,sr.response_time
        ,sr.status
        ,sr.contact_id
        ,sr.response_id AS answer_id
        ,sr.question
        ,sr.answer
        ,s.title AS survey_name
        ,sc.name AS campaign_name
        ,sq.question_shortname
--FROM surveygizmo.survey_response_clean sr 
  FROM responses sr --Uncomment row above, kill this row, and kill the CTE above
  LEFT JOIN surveygizmo.survey s
    ON sr.survey_id = s.id
  LEFT JOIN surveygizmo.survey_campaign sc
    ON sr.survey_id = sc.survey_id
   AND sr.date_submitted BETWEEN sc.link_open_date AND sc.link_close_date
--  LEFT JOIN surveygizmo.survey_question_clean sq
    LEFT JOIN questions sq --Uncomment row above, kill this row, and kill the CTE above
    ON sr.survey_id = sq.survey_id
   AND sr.question = sq.question
  WHERE s.title = 'Self and Others'
  )

  SELECT submission_id
        ,survey_id 
        ,date_started
        ,date_submitted
        ,response_time
        ,status
        ,contact_id
        ,survey_name
        ,campaign_name
        ,[reporting_term]
        ,[respondant_name]
        ,[respondant_email_address]
        ,[subject_name]
        ,[I can depend on this teammate to fulfill team obligations and follow through on commitments.]
        ,[I am confident that this teammate does whatever it takes to support every child we serve.]
        ,[This teammate makes me feel included amongst a team with various cultural differences.]
        ,[This teammate works to make me feel known, loved, and valued.]
        ,[This teammate seeks my feedback and takes it seriously. ]
        ,[I trust this teammate to address challenges directly and productively.]
        ,[I would choose to work with this teammate as much as I possibly can.]
        ,[This teammate meets professional expectations for punctuality. (MGR)]
        ,[This teammate meets professional expectations for presence. (MGR)]
        ,[This teammate meets professional expectations for team responsibilities. (MGR)]
        ,[Name two things this teammate does well based on the statements above.]
        ,[Name two things this teammate needs to improve upon based on the statements above.]
  FROM   (SELECT r.submission_id
                ,r.survey_id 
                ,r.date_started
                ,r.date_submitted
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
           FOR question_shortname in ([reporting_term]
                                     ,[respondant_name]
                                     ,[respondant_email_address]
                                     ,[subject_name]
                                     ,[I can depend on this teammate to fulfill team obligations and follow through on commitments.]
                                     ,[I am confident that this teammate does whatever it takes to support every child we serve.]
                                     ,[This teammate makes me feel included amongst a team with various cultural differences.]
                                     ,[This teammate works to make me feel known, loved, and valued.]
                                     ,[This teammate seeks my feedback and takes it seriously. ]
                                     ,[I trust this teammate to address challenges directly and productively.]
                                     ,[I would choose to work with this teammate as much as I possibly can.]
                                     ,[This teammate meets professional expectations for punctuality. (MGR)]
                                     ,[This teammate meets professional expectations for presence. (MGR)]
                                     ,[This teammate meets professional expectations for team responsibilities. (MGR)]
                                     ,[Name two things this teammate does well based on the statements above.]
                                     ,[Name two things this teammate needs to improve upon based on the statements above.]
                                     ) 
          ) p