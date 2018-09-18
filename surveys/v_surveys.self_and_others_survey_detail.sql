USE gabby
GO

--CREATE OR ALTER VIEW surveys.self_and_others_survey_detail AS

WITH so_long AS (
  SELECT response_id
        ,academic_year
        ,term_name
        ,reporting_term
        ,time_started
        ,date_submitted
        ,your_name_ AS respondent_name
        ,your_kipp_nj_email_account AS respondent_email_address
        ,subject_name
        ,subject_associate_id
        ,is_manager
        ,question_code
        ,response
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
      ,sub.response
      ,sub.subject_associate_id
      ,sub.subject_name
      ,sub.subject_location
      ,sub.subject_manager_id
      ,sub.subject_username
      ,sub.subject_manager_name
      ,sub.subject_manager_username
      ,sub.question_text
      ,sub.open_ended
      ,sub.response_value
      ,sub.is_manager      

      ,ROUND(AVG(sub.response_value) OVER(PARTITION BY academic_year, reporting_term, subject_location, question_code), 1) AS avg_response_value_location
      
      ,ROUND(MAX(sub.manager_response_value) OVER(PARTITION BY academic_year, reporting_term, subject_associate_id, question_code),1) AS manager_avg_response_value
      ,ROUND(MAX(sub.teammate_response_value) OVER(PARTITION BY academic_year, reporting_term, subject_associate_id, question_code),1) AS teammate_avg_response_value
      ,COALESCE(ROUND((MAX(sub.manager_response_value) OVER(PARTITION BY academic_year, reporting_term, subject_associate_id, question_code) + MAX(sub.teammate_response_value) OVER(PARTITION BY academic_year, reporting_term, subject_associate_id, question_code)) / 2,1),ROUND(AVG(sub.response_value) OVER(PARTITION BY academic_year, reporting_term, subject_associate_id, question_code), 1)) AS weighted_avg_response_value
      
      ,ROUND(MAX(sub.manager_response_value) OVER(PARTITION BY academic_year, reporting_term, subject_location, question_code),1) AS manager_avg_location_response_value
      ,ROUND(MAX(sub.teammate_response_value) OVER(PARTITION BY academic_year, reporting_term, subject_location, question_code),1) AS teammate_avg_location_response_value
      ,ROUND((MAX(sub.manager_response_value) OVER(PARTITION BY academic_year, reporting_term, subject_location, question_code) + MAX(sub.teammate_response_value) OVER(PARTITION BY academic_year, reporting_term, subject_location, question_code)) / 2,1) AS weighted_avg_location_response_value
      
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
      
           ,CONCAT(df.preferred_first_name, ' ', df.preferred_last_name) AS subject_name
           ,CONVERT(VARCHAR,df.primary_site) AS subject_location
           ,df.manager_df_employee_number AS subject_manager_id      

           ,ad.samaccountname AS subject_username

           ,mgr.displayname AS subject_manager_name
           ,mgr.samaccountname AS subject_manager_username

           ,qk.question_text
           ,qk.open_ended

           ,CONVERT(FLOAT,rs.response_value) AS response_value
           ,CASE WHEN so.is_manager = 1 AND qk.open_ended = 'N' AND so.survey_type = 'SO2018' THEN AVG(CONVERT(FLOAT,rs.response_value)) OVER(PARTITION BY so.academic_year, so.reporting_term, so.subject_associate_id, so.question_code, so.is_manager) ELSE NULL END AS manager_response_value
           ,CASE WHEN so.is_manager = 0 AND qk.open_ended = 'N' AND so.survey_type = 'SO2018' THEN AVG(CONVERT(FLOAT,rs.response_value)) OVER(PARTITION BY so.academic_year, so.reporting_term, so.subject_associate_id, so.question_code, so.is_manager) ELSE NULL END AS teammate_response_value
           
           ,so.is_manager
     FROM so_long so
     LEFT JOIN gabby.dayforce.staff_roster df
       ON (so.subject_associate_id = df.adp_associate_id OR so.subject_associate_id = CONVERT(VARCHAR,df.df_employee_number))
     JOIN gabby.adsi.user_attributes_static ad
       ON (df.adp_associate_id = ad.idautopersonalternateid OR CONVERT(VARCHAR,df.df_employee_number) = ad.employeeid)
     LEFT JOIN gabby.adsi.user_attributes_static mgr
       ON (df.manager_adp_associate_id = mgr.idautopersonalternateid OR CONVERT(VARCHAR,df.manager_df_employee_number) = mgr.employeeid)
     JOIN gabby.surveys.question_key qk
       ON so.question_code = qk.question_code
      AND qk.survey_type = 'SO'
     LEFT JOIN gabby.surveys.response_scales rs
       ON so.response = rs.response_text
      AND CASE WHEN so.academic_year <= 2017 THEN 'SO' ELSE 'SO2018' END = rs.survey_type 
    ) sub