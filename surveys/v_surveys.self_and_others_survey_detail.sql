USE gabby
GO

CREATE OR ALTER VIEW surveys.self_and_others_survey_detail AS

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
        ,question_code
        ,response
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

SELECT 'SO' AS survey_type
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
      
      ,CONCAT(adp.preferred_first, ' ', adp.preferred_last) AS subject_name
      ,adp.location_custom AS subject_location
      ,adp.manager_custom_assoc_id AS subject_manager_id      

      ,ad.samaccountname AS subject_username

      ,mgr.displayname AS subject_manager_name
      ,mgr.samaccountname AS subject_manager_username

      ,qk.question_text
      ,qk.open_ended

      ,rs.response_value
      ,ROUND(AVG(CONVERT(FLOAT,rs.response_value)) OVER(PARTITION BY so.academic_year, so.reporting_term, so.question_code, adp.location_custom), 1) AS avg_response_value_location
FROM so_long so
JOIN gabby.adp.staff_roster adp
  ON so.subject_associate_id = adp.associate_id
 AND adp.rn_curr = 1
JOIN gabby.adsi.user_attributes ad
  ON adp.associate_id = ad.idautopersonalternateid
LEFT OUTER JOIN gabby.adsi.user_attributes mgr
  ON adp.manager_custom_assoc_id = mgr.idautopersonalternateid
JOIN gabby.surveys.question_key qk
  ON so.question_code = qk.question_code
 AND qk.survey_type = 'SO'
LEFT OUTER JOIN gabby.surveys.response_scales rs
  ON so.response = rs.response_text
 AND rs.survey_type = 'SO'