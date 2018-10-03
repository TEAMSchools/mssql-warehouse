USE gabby
GO

CREATE OR ALTER VIEW surveys.self_and_others_survey_detail AS

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
       SELECT u.response_id
             ,CONVERT(INT,u.academic_year) AS academic_year
             ,u.term_name
             ,CONVERT(VARCHAR(5),u.reporting_term) AS reporting_term
             ,u.time_started
             ,u.date_submitted
             ,u.your_name_ AS respondent_name
             ,u.your_kipp_nj_email_account AS respondent_email_address
             ,u.subject_name
             ,CONVERT(VARCHAR(25),u.subject_associate_id) AS subject_associate_id
             ,u.is_manager
             ,CONVERT(VARCHAR(25),u.question_code) AS question_code
             ,u.response
             ,CASE WHEN u.academic_year <= 2017 THEN 'SO' ELSE 'SO2018' END AS survey_type
       FROM gabby.surveys.self_and_others_survey_final
       UNPIVOT(
         response
         FOR question_code IN (q_1_1_b
                              ,q_1_1_c
                              ,q_1_1_d
                              ,q_1_1_oe
                              ,q_1_2_a
                              ,q_1_2_b
                              ,q_1_2_oe
                              ,q_1_3_a
                              ,q_1_3_c
                              ,q_1_3_d
                              ,q_1_3_e
                              ,q_1_3_oe
                              ,q_1_4_a
                              ,q_1_4_b
                              ,q_1_4_oe
                              ,q_1_5_a
                              ,q_1_5_b
                              ,q_1_5_c
                              ,q_1_5_d
                              ,q_1_5_f
                              ,q_1_5_oe
                              ,q_1_6_a
                              ,q_1_6_b
                              ,q_1_6_c
                              ,q_1_6_d
                              ,q_1_6_oe)
        ) u
   ) sub
 ) 

SELECT sub.survey_type
      ,sub.response_id
      ,sub.academic_year
      ,sub.reporting_term
      ,sub.term_name
      ,sub.time_started
      ,sub.date_submitted
      ,sub.respondent_name
      ,sub.respondent_email_address
      ,sub.question_code
      ,sub.subject_associate_id
      ,sub.is_manager
      ,sub.n_managers
      ,sub.n_peers
      ,sub.n_total
      ,sub.question_text
      ,sub.open_ended      
      ,sub.subject_name
      ,sub.subject_location
      ,sub.subject_manager_id
      ,sub.subject_username
      ,sub.subject_manager_name
      ,sub.subject_manager_username      
      ,sub.response
      ,sub.response_value
      ,sub.response_weight      
      ,(sub.response_value * sub.response_weight) AS response_value_weighted

      ,ROUND(SUM(sub.response_value * sub.response_weight) OVER(PARTITION BY academic_year, reporting_term, subject_location, question_code)
               / SUM(sub.response_weight) OVER(PARTITION BY academic_year, reporting_term, subject_location, question_code)
            ,1) AS avg_response_value_location
FROM
    (
     SELECT so.survey_type
           ,so.response_id
           ,CONVERT(INT,so.academic_year) AS academic_year
           ,CONVERT(VARCHAR,so.reporting_term) AS reporting_term
           ,so.term_name
           ,so.time_started
           ,so.date_submitted      
           ,so.respondent_name
           ,so.respondent_email_address
           ,CONVERT(VARCHAR,so.question_code) AS question_code
           ,so.response
           ,so.subject_associate_id
           ,so.is_manager
           ,so.n_managers
           ,so.n_peers
           ,so.n_total           

           ,qk.question_text
           ,qk.open_ended           

           ,CONVERT(FLOAT,rs.response_value) AS response_value           

           ,CONCAT(df.preferred_first_name, ' ', df.preferred_last_name) AS subject_name
           ,CONVERT(VARCHAR,df.primary_site) AS subject_location
           ,df.manager_df_employee_number AS subject_manager_id      

           ,ad.samaccountname AS subject_username

           ,mgr.displayname AS subject_manager_name
           ,mgr.samaccountname AS subject_manager_username           
           
           ,CASE 
             WHEN so.academic_year <= 2017 THEN 1.0
             WHEN so.is_manager = 1 THEN CONVERT(FLOAT,so.n_total) / 2.0 /* manager response weight */
             WHEN so.is_manager = 0 THEN (CONVERT(FLOAT,so.n_total) / 2.0) / CONVERT(FLOAT,so.n_peers) /* peer response weight */
            END AS response_weight
     FROM so_long so
     JOIN gabby.surveys.question_key qk
       ON so.question_code = qk.question_code
      AND qk.survey_type = 'SO'
     LEFT JOIN gabby.surveys.response_scales rs
       ON so.response = rs.response_text
      AND so.survey_type = rs.survey_type 
     LEFT JOIN gabby.dayforce.staff_roster df
       ON (so.subject_associate_id = df.adp_associate_id OR so.subject_associate_id = CONVERT(VARCHAR,df.df_employee_number))
     LEFT JOIN gabby.adsi.user_attributes_static ad
       ON (df.adp_associate_id = ad.idautopersonalternateid OR CONVERT(VARCHAR,df.df_employee_number) = ad.employeeid)
     LEFT JOIN gabby.adsi.user_attributes_static mgr
       ON (df.manager_adp_associate_id = mgr.idautopersonalternateid OR CONVERT(VARCHAR,df.manager_df_employee_number) = mgr.employeeid)     
    ) sub