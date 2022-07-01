USE gabby
GO

--CREATE OR ALTER VIEW tableau.kipp_forward_survey_wide AS

WITH alumni_data AS (
  SELECT e.student_c
        ,e.[name]
        ,e.pursuing_degree_type_c
        ,e.type_c
        ,e.start_date_c
        ,e.actual_end_date_c
        ,e.major_c
        ,e.status_c
        ,ROW_NUMBER() OVER(
           PARTITION BY e.student_c
             ORDER BY e.actual_end_date_c DESC) AS rn_latest

        ,c.first_name
        ,c.last_name
        ,c.kipp_ms_graduate_c
        ,c.kipp_hs_graduate_c
        ,c.kipp_hs_class_c
        ,c.college_match_display_gpa_c
        ,c.kipp_region_name_c
        ,c.[description]
        ,c.gender_c
        ,c.ethnicity_c
        ,CAST(CAST(c.birthdate AS datetime) AS float) AS alumni_birthdate_id
  FROM gabby.alumni.enrollment_c e
  JOIN gabby.alumni.contact c
    ON e.student_c = c.id
  WHERE e.status_c = 'Graduated'
    AND e.is_deleted = 0
 )

,survey_pivot AS (
  SELECT survey_id
		,survey_title
		,survey_response_id
		,campaign_academic_year
		,campaign_name
		,campaign_reporting_term
		,date_started
		,date_submitted
		,response_time
		,contact_id
		,respondent_salesforce_id
		,[first_name]
		,[last_name]
		,[after_grad] 
		,CAST(CAST([alumni_dob] AS datetime) AS float) AS alumni_birthdate_id
		,[alumni_phone]
		,[imp_1]
		,[imp_2]
		,[imp_3]
		,[imp_4]
		,[imp_5]
		,[imp_6]
		,[imp_7]
		,[imp_8]
		,[imp_9]
		,[cur_1]
		,[cur_2]
		,[cur_3]
		,[cur_4]
		,[cur_5]
		,[cur_6]
		,[cur_7]
		,[cur_8]
		,[cur_9]
		,[cur_10]
		,[job_sat]
		,[ladder]
		,[covid]
		,[linkedin]
		,[linkedin_link]
		,[debt_binary]
		,[debt_amount]
		,[annual_income]

 FROM
     (
      SELECT survey_id
			,survey_title
			,survey_response_id
			,campaign_academic_year
			,campaign_name
			,campaign_reporting_term
			,date_started
			,date_submitted
			,response_time
			,contact_id
			,respondent_salesforce_id
			,question_shortname
			,answer
       FROM gabby.surveygizmo.survey_detail s
       WHERE survey_id = '6734664'
         --AND date_submitted > '2022-03-01'
         ) sub
  PIVOT(
    MAX(answer)
    FOR question_shortname IN ( [first_name]
						       ,[last_name]
						       ,[alumni_dob]
						       ,[alumni_phone]
						       ,[after_grad]  
						       ,[imp_1]
						       ,[imp_2]
						       ,[imp_3]
						       ,[imp_4]
						       ,[imp_5]
						       ,[imp_6]
						       ,[imp_7]
						       ,[imp_8]
						       ,[imp_9]
						       ,[cur_1]
						       ,[cur_2]
						       ,[cur_3]
						       ,[cur_4]
						       ,[cur_5]
						       ,[cur_6]
						       ,[cur_7]
						       ,[cur_8]
						       ,[cur_9]
						       ,[cur_10]
						       ,[job_sat]
						       ,[ladder]
						       ,[covid]
						       ,[linkedin]
						       ,[linkedin_link]
						       ,[debt_binary]
						       ,[debt_amount]
						       ,[annual_income])
   ) p
)

SELECT  s.survey_id
       ,s.survey_title
       ,s.survey_response_id
       ,s.date_started
       ,s.date_submitted
       ,s.response_time
       ,s.contact_id
       ,s.respondent_salesforce_id
       ,s.alumni_birthdate_id
       ,s.first_name
       ,s.last_name
       ,s.alumni_phone
       ,s.after_grad
       ,s.imp_1
       ,s.imp_2
       ,s.imp_3
       ,s.imp_4
       ,s.imp_5
       ,s.imp_6
       ,s.imp_7
       ,s.imp_8
       ,s.imp_9
       ,s.cur_1
       ,s.cur_2
       ,s.cur_3
       ,s.cur_4
       ,s.cur_5
       ,s.cur_6
       ,s.cur_7
       ,s.cur_8
       ,s.cur_9
       ,s.cur_10
       ,s.job_sat
       ,s.ladder
       ,s.covid
       ,s.linkedin
       ,s.linkedin_link
       ,s.debt_binary
       ,s.debt_amount
       ,s.annual_income
       
       ,a.[name]
       ,a.kipp_ms_graduate_c
       ,a.kipp_hs_graduate_c
       ,a.kipp_hs_class_c
       ,a.college_match_display_gpa_c
       ,a.kipp_region_name_c
       ,a.[description]
       ,a.gender_c
       ,a.ethnicity_c
       ,a.pursuing_degree_type_c
       ,a.type_c
       ,a.start_date_c
       ,a.actual_end_date_c
       ,a.major_c
       ,a.status_c

FROM survey_pivot s
LEFT JOIN alumni_data a
/*replace all this with email*/
  ON s.alumni_birthdate_id = a.alumni_birthdate_id
 AND a.rn_latest = 1
WHERE s.survey_id = '6734664'