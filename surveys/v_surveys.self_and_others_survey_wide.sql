USE gabby
GO

CREATE OR ALTER VIEW surveys.self_and_others_survey_wide AS

WITH survey_unpivot AS (
  SELECT academic_year
        ,term_name
        ,subject_name
        ,subject_location
        ,subject_manager_name
        ,respondent_names
        ,value
        ,CONCAT(question_code, '_', field) AS pivot_field
  FROM
      (
       SELECT academic_year           
             ,term_name                  
             ,question_code       
             ,subject_name
             ,subject_location 
             ,subject_manager_name
      
             ,CONVERT(NVARCHAR(MAX),COUNT(CASE WHEN open_ended = 'N' THEN response_value END)) AS n_responses
             ,CONVERT(NVARCHAR(MAX),ROUND(AVG(CONVERT(FLOAT,response_value)), 1)) AS avg_response_value_subject      
             ,CONVERT(NVARCHAR(MAX),MAX(avg_response_value_location)) AS avg_response_value_location
             ,CONVERT(NVARCHAR(MAX),gabby.dbo.GROUP_CONCAT_D(DISTINCT respondent_name, CHAR(10))) AS respondent_names
             ,CONVERT(NVARCHAR(MAX),gabby.dbo.GROUP_CONCAT_D(CASE WHEN open_ended = 'Y' THEN response END, CHAR(10))) AS response_text
       FROM gabby.surveys.self_and_others_survey_detail      
       GROUP BY academic_year
               ,term_name                    
               ,question_code      
               ,subject_name
               ,subject_location 
               ,subject_manager_name      
      ) sub
  UNPIVOT(
    value
    FOR field IN (n_responses
                 ,avg_response_value_subject
                 ,avg_response_value_location
                 ,response_text)
   ) u
 )

SELECT academic_year
      ,term_name
      ,subject_name
      ,subject_location
      ,subject_manager_name
      ,respondent_names
      
      ,[q_1_1_b_avg_response_value_location]
      ,[q_1_1_b_avg_response_value_subject]
      ,[q_1_1_b_n_responses]
      ,[q_1_1_c_avg_response_value_location]
      ,[q_1_1_c_avg_response_value_subject]
      ,[q_1_1_c_n_responses]
      ,[q_1_1_d_avg_response_value_location]
      ,[q_1_1_d_avg_response_value_subject]
      ,[q_1_1_d_n_responses]
      ,[q_1_1_oe_avg_response_value_location]
      ,[q_1_1_oe_avg_response_value_subject]
      ,[q_1_1_oe_n_responses]
      ,[q_1_1_oe_response_text]
      ,[q_1_2_a_avg_response_value_location]
      ,[q_1_2_a_avg_response_value_subject]
      ,[q_1_2_a_n_responses]
      ,[q_1_2_b_avg_response_value_location]
      ,[q_1_2_b_avg_response_value_subject]
      ,[q_1_2_b_n_responses]
      ,[q_1_2_oe_avg_response_value_location]
      ,[q_1_2_oe_avg_response_value_subject]
      ,[q_1_2_oe_n_responses]
      ,[q_1_2_oe_response_text]
      ,[q_1_3_a_avg_response_value_location]
      ,[q_1_3_a_avg_response_value_subject]
      ,[q_1_3_a_n_responses]
      ,[q_1_3_c_avg_response_value_location]
      ,[q_1_3_c_avg_response_value_subject]
      ,[q_1_3_c_n_responses]
      ,[q_1_3_d_avg_response_value_location]
      ,[q_1_3_d_avg_response_value_subject]
      ,[q_1_3_d_n_responses]
      ,[q_1_3_e_avg_response_value_location]
      ,[q_1_3_e_avg_response_value_subject]
      ,[q_1_3_e_n_responses]
      ,[q_1_3_oe_avg_response_value_location]
      ,[q_1_3_oe_avg_response_value_subject]
      ,[q_1_3_oe_n_responses]
      ,[q_1_3_oe_response_text]
      ,[q_1_4_a_avg_response_value_location]
      ,[q_1_4_a_avg_response_value_subject]
      ,[q_1_4_a_n_responses]
      ,[q_1_4_b_avg_response_value_location]
      ,[q_1_4_b_avg_response_value_subject]
      ,[q_1_4_b_n_responses]
      ,[q_1_4_oe_avg_response_value_location]
      ,[q_1_4_oe_avg_response_value_subject]
      ,[q_1_4_oe_n_responses]
      ,[q_1_4_oe_response_text]
      ,[q_1_5_a_avg_response_value_location]
      ,[q_1_5_a_avg_response_value_subject]
      ,[q_1_5_a_n_responses]
      ,[q_1_5_b_avg_response_value_location]
      ,[q_1_5_b_avg_response_value_subject]
      ,[q_1_5_b_n_responses]
      ,[q_1_5_c_avg_response_value_location]
      ,[q_1_5_c_avg_response_value_subject]
      ,[q_1_5_c_n_responses]
      ,[q_1_5_d_avg_response_value_location]
      ,[q_1_5_d_avg_response_value_subject]
      ,[q_1_5_d_n_responses]
      ,[q_1_5_f_avg_response_value_location]
      ,[q_1_5_f_avg_response_value_subject]
      ,[q_1_5_f_n_responses]
      ,[q_1_5_oe_avg_response_value_location]
      ,[q_1_5_oe_avg_response_value_subject]
      ,[q_1_5_oe_n_responses]
      ,[q_1_5_oe_response_text]
      ,[q_1_6_a_avg_response_value_location]
      ,[q_1_6_a_avg_response_value_subject]
      ,[q_1_6_a_n_responses]
      ,[q_1_6_b_avg_response_value_location]
      ,[q_1_6_b_avg_response_value_subject]
      ,[q_1_6_b_n_responses]
      ,[q_1_6_c_avg_response_value_location]
      ,[q_1_6_c_avg_response_value_subject]
      ,[q_1_6_c_n_responses]
      ,[q_1_6_d_avg_response_value_location]
      ,[q_1_6_d_avg_response_value_subject]
      ,[q_1_6_d_n_responses]
      ,[q_1_6_oe_avg_response_value_location]
      ,[q_1_6_oe_avg_response_value_subject]
      ,[q_1_6_oe_n_responses]
      ,[q_1_6_oe_response_text]
FROM survey_unpivot
PIVOT(
  MAX(value)
  FOR pivot_field IN ([q_1_1_b_avg_response_value_location]
                     ,[q_1_1_b_avg_response_value_subject]
                     ,[q_1_1_b_n_responses]
                     ,[q_1_1_c_avg_response_value_location]
                     ,[q_1_1_c_avg_response_value_subject]
                     ,[q_1_1_c_n_responses]
                     ,[q_1_1_d_avg_response_value_location]
                     ,[q_1_1_d_avg_response_value_subject]
                     ,[q_1_1_d_n_responses]
                     ,[q_1_1_oe_avg_response_value_location]
                     ,[q_1_1_oe_avg_response_value_subject]
                     ,[q_1_1_oe_n_responses]
                     ,[q_1_1_oe_response_text]
                     ,[q_1_2_a_avg_response_value_location]
                     ,[q_1_2_a_avg_response_value_subject]
                     ,[q_1_2_a_n_responses]
                     ,[q_1_2_b_avg_response_value_location]
                     ,[q_1_2_b_avg_response_value_subject]
                     ,[q_1_2_b_n_responses]
                     ,[q_1_2_oe_avg_response_value_location]
                     ,[q_1_2_oe_avg_response_value_subject]
                     ,[q_1_2_oe_n_responses]
                     ,[q_1_2_oe_response_text]
                     ,[q_1_3_a_avg_response_value_location]
                     ,[q_1_3_a_avg_response_value_subject]
                     ,[q_1_3_a_n_responses]
                     ,[q_1_3_c_avg_response_value_location]
                     ,[q_1_3_c_avg_response_value_subject]
                     ,[q_1_3_c_n_responses]
                     ,[q_1_3_d_avg_response_value_location]
                     ,[q_1_3_d_avg_response_value_subject]
                     ,[q_1_3_d_n_responses]
                     ,[q_1_3_e_avg_response_value_location]
                     ,[q_1_3_e_avg_response_value_subject]
                     ,[q_1_3_e_n_responses]
                     ,[q_1_3_oe_avg_response_value_location]
                     ,[q_1_3_oe_avg_response_value_subject]
                     ,[q_1_3_oe_n_responses]
                     ,[q_1_3_oe_response_text]
                     ,[q_1_4_a_avg_response_value_location]
                     ,[q_1_4_a_avg_response_value_subject]
                     ,[q_1_4_a_n_responses]
                     ,[q_1_4_b_avg_response_value_location]
                     ,[q_1_4_b_avg_response_value_subject]
                     ,[q_1_4_b_n_responses]
                     ,[q_1_4_oe_avg_response_value_location]
                     ,[q_1_4_oe_avg_response_value_subject]
                     ,[q_1_4_oe_n_responses]
                     ,[q_1_4_oe_response_text]
                     ,[q_1_5_a_avg_response_value_location]
                     ,[q_1_5_a_avg_response_value_subject]
                     ,[q_1_5_a_n_responses]
                     ,[q_1_5_b_avg_response_value_location]
                     ,[q_1_5_b_avg_response_value_subject]
                     ,[q_1_5_b_n_responses]
                     ,[q_1_5_c_avg_response_value_location]
                     ,[q_1_5_c_avg_response_value_subject]
                     ,[q_1_5_c_n_responses]
                     ,[q_1_5_d_avg_response_value_location]
                     ,[q_1_5_d_avg_response_value_subject]
                     ,[q_1_5_d_n_responses]
                     ,[q_1_5_f_avg_response_value_location]
                     ,[q_1_5_f_avg_response_value_subject]
                     ,[q_1_5_f_n_responses]
                     ,[q_1_5_oe_avg_response_value_location]
                     ,[q_1_5_oe_avg_response_value_subject]
                     ,[q_1_5_oe_n_responses]
                     ,[q_1_5_oe_response_text]
                     ,[q_1_6_a_avg_response_value_location]
                     ,[q_1_6_a_avg_response_value_subject]
                     ,[q_1_6_a_n_responses]
                     ,[q_1_6_b_avg_response_value_location]
                     ,[q_1_6_b_avg_response_value_subject]
                     ,[q_1_6_b_n_responses]
                     ,[q_1_6_c_avg_response_value_location]
                     ,[q_1_6_c_avg_response_value_subject]
                     ,[q_1_6_c_n_responses]
                     ,[q_1_6_d_avg_response_value_location]
                     ,[q_1_6_d_avg_response_value_subject]
                     ,[q_1_6_d_n_responses]
                     ,[q_1_6_oe_avg_response_value_location]
                     ,[q_1_6_oe_avg_response_value_subject]
                     ,[q_1_6_oe_n_responses]
                     ,[q_1_6_oe_response_text])
 ) p