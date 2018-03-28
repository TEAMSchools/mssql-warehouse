USE gabby
GO

CREATE OR ALTER VIEW surveys.manager_survey_detail AS

WITH manager_long AS (
  SELECT response_id
        ,academic_year
        ,reporting_term
        ,term_name      
        ,time_started
        ,date_submitted
        ,status
        ,associate_id
        ,salesforce_id
        ,email_address
        ,your_name_ AS respondent_name
        ,manager_name
        ,manager_associate_id      
        ,question_code
        ,response
  FROM gabby.surveys.manager_survey_final
  UNPIVOT(
    response
    FOR question_code IN (q_1
                         ,q_2
                         ,q_3
                         ,q_4
                         ,q_5
                         ,q_6
                         ,q_7
                         ,q_8
                         ,q_9
                         ,q_10
                         ,q_11
                         ,q_12
                         ,q_13
                         ,q_14
                         ,q_15
                         ,q_16
                         ,q_17
                         ,q_18)
   ) u
 )

SELECT sub.survey_type
      ,sub.response_id
      ,sub.academic_year
      ,sub.reporting_term
      ,sub.term_name
      ,sub.time_started
      ,sub.date_submitted
      ,sub.status
      ,sub.respondent_associate_id
      ,sub.respondent_salesforce_id
      ,sub.respondent_email_address
      ,sub.respondent_name
      ,sub.subject_associate_id
      ,sub.question_code
      ,sub.response
      ,sub.subject_name
      ,sub.subject_location
      ,sub.subject_manager_id
      ,sub.reporting_schoolid
      ,sub.school_level
      ,sub.region
      ,sub.subject_username
      ,sub.subject_manager_name
      ,sub.subject_manager_username
      ,sub.question_text
      ,sub.open_ended
      ,sub.response_value

      ,ROUND(AVG(response_value) OVER(PARTITION BY academic_year, reporting_term, question_code, subject_location), 1) AS avg_response_value_location
FROM
    (
     SELECT 'MGR' AS survey_type
           ,mgr.response_id
           ,CONVERT(INT,mgr.academic_year) AS academic_year
           ,CONVERT(VARCHAR,mgr.reporting_term) AS reporting_term
           ,mgr.term_name
           ,mgr.time_started
           ,mgr.date_submitted
           ,mgr.status
           ,mgr.associate_id  AS respondent_associate_id
           ,mgr.salesforce_id AS respondent_salesforce_id
           ,mgr.email_address AS respondent_email_address
           ,mgr.respondent_name      
           ,mgr.manager_associate_id AS subject_associate_id
           ,CONVERT(VARCHAR,mgr.question_code) AS question_code
           ,mgr.response
      
           ,CONCAT(df.preferred_first_name, ' ', df.preferred_last_name) AS subject_name
           ,CONVERT(VARCHAR,df.primary_site) AS subject_location
           ,df.manager_adp_associate_id AS subject_manager_id      
           ,CASE
             WHEN df.primary_site = 'Rise Academy' THEN 73252
             WHEN df.primary_site = 'Newark Collegiate Academy' THEN 73253
             WHEN df.primary_site = 'SPARK Academy' THEN 73254
             WHEN df.primary_site = 'THRIVE Academy' THEN 73255
             WHEN df.primary_site = 'Seek Academy' THEN 73256
             WHEN df.primary_site = 'Life Academy' THEN 73257
             WHEN df.primary_site = 'Bold Academy' THEN 73258
             WHEN df.primary_site = 'Lanning Square Primary' THEN 179901
             WHEN df.primary_site = 'Lanning Square MS' THEN 179902
             WHEN df.primary_site = 'Whittier Middle' THEN 179903
             WHEN df.primary_site = 'TEAM Academy' THEN 133570965
             WHEN df.primary_site = 'Pathways' THEN 732574573
            END AS reporting_schoolid
           ,CASE
             WHEN df.primary_site IN ('SPARK Academy','THRIVE Academy','Seek Academy','Life Academy','Lanning Square Primary','Pathways') THEN 'ES'
             WHEN df.primary_site IN ('Rise Academy','Lanning Square MS','Whittier Middle','TEAM Academy','Bold Academy') THEN 'MS'
             WHEN df.primary_site IN ('Newark Collegiate Academy') THEN 'HS'
            END AS school_level
           ,CASE
             WHEN df.primary_site IN ('SPARK Academy','THRIVE Academy','Seek Academy','Life Academy','Pathways'
                                         ,'Rise Academy','TEAM Academy','Bold Academy','Newark Collegiate Academy') THEN 'TEAM'
             WHEN df.primary_site IN ('Lanning Square Primary','Lanning Square MS','Whittier Middle') THEN 'KCNA'
            END AS region

           ,ad.samaccountname AS subject_username

           ,admgr.displayname AS subject_manager_name
           ,admgr.samaccountname AS subject_manager_username
      
           ,qk.question_text
           ,qk.open_ended

           ,CONVERT(FLOAT,rs.response_value) AS response_value
     FROM manager_long mgr
     JOIN gabby.dayforce.staff_roster df
       ON mgr.manager_associate_id = df.adp_associate_id
     JOIN gabby.adsi.user_attributes_static ad
       ON df.adp_associate_id = ad.idautopersonalternateid
     LEFT JOIN gabby.adsi.user_attributes_static admgr
       ON df.manager_adp_associate_id = admgr.idautopersonalternateid
     JOIN gabby.surveys.question_key qk
       ON mgr.question_code = qk.question_code
      AND qk.survey_type = 'MGR'
     LEFT JOIN gabby.surveys.response_scales rs
       ON mgr.response = rs.response_text
      AND rs.survey_type = 'MGR'
    ) sub