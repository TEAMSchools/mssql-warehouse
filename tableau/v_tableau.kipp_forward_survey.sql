USE gabby
GO

CREATE OR ALTER VIEW tableau.kipp_forward_survey AS

WITH alumni_data AS (
SELECT 
      c.salesforce_id_c
     ,c.kipp_ms_graduate_c
     ,c.kipp_hs_graduate_c
     ,c.kipp_hs_class_c
     ,c.college_match_display_gpa_c
     ,c.kipp_region_name_c
     ,c.[description]
     ,c.gender_c
     ,c.ethnicity_c

     ,e.[name]
     ,e.pursuing_degree_type_c
     ,e.type_c
     ,e.start_date_c
     ,e.actual_end_date_c
     ,e.major_c
     ,e.status_c

     ,s.survey_response_id

     ,ROW_NUMBER() OVER (
      PARTITION BY status_c,student_c
      ORDER BY actual_end_date_c DESC) AS rn_latest

FROM gabby.alumni.contact c
JOIN gabby.alumni.enrollment_c e
  ON c.salesforce_id_c = e.student_c
JOIN gabby.surveygizmo.survey_detail s
  ON s.answer = c.salesforce_id_c
WHERE status_c = 'Graduated'
)

SELECT
      s.survey_id
     ,s.survey_response_id
     ,s.survey_title
     ,s.survey_question_id
     ,s.question_shortname
     ,s.question_title
     ,s.question_type
     ,s.is_open_ended
     ,s.answer_id
     ,s.contact_id
     ,s.date_started
     ,s.date_submitted
     ,s.response_time
     ,s.campaign_academic_year
     ,s.campaign_name
     ,s.campaign_reporting_term
     ,s.answer_value
     ,s.answer

     ,a.salesforce_id_c
     ,a.kipp_ms_graduate_c
     ,a.kipp_hs_graduate_c
     ,a.kipp_hs_class_c
     ,a.college_match_display_gpa_c
     ,a.kipp_region_name_c
     ,a.[description]
     ,a.gender_c
     ,a.ethnicity_c
     ,a.[name]
     ,a.pursuing_degree_type_c
     ,a.type_c
     ,a.start_date_c
     ,a.actual_end_date_c
     ,a.major_c
     ,a.status_c

FROM gabby.surveygizmo.survey_detail s
JOIN alumni_data a
  ON s.survey_response_id = a.survey_response_id
WHERE rn_latest = 1
AND survey_id = '6734664'