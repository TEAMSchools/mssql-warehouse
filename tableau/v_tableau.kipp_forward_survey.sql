USE gabby
GO

CREATE OR ALTER VIEW tableau.kipp_forward_survey AS

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

        ,c.kipp_ms_graduate_c
        ,c.kipp_hs_graduate_c
        ,c.kipp_hs_class_c
        ,c.college_match_display_gpa_c
        ,c.kipp_region_name_c
        ,c.[description]
        ,c.gender_c
        ,c.ethnicity_c
  FROM gabby.alumni.enrollment_c e
  JOIN gabby.alumni.contact c
    ON e.student_c = c.id
  WHERE e.status_c = 'Graduated'
    AND e.is_deleted = 0
 )

SELECT  s.survey_id
       ,s.survey_title
       ,s.survey_response_id
       ,s.campaign_academic_year
       ,s.campaign_name
       ,s.campaign_reporting_term
       ,s.date_started
       ,s.date_submitted
       ,s.response_time
       ,s.contact_id
       ,s.respondent_salesforce_id
       ,s.survey_question_id
       ,s.question_shortname
       ,s.question_title
       ,s.question_type
       ,s.is_open_ended
       ,s.answer_id
       ,s.answer
       ,s.answer_value

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
FROM gabby.surveygizmo.survey_detail s
JOIN alumni_data a
  ON s.respondent_salesforce_id = a.student_c
 AND a.rn_latest = 1
WHERE s.survey_id = '6734664'
