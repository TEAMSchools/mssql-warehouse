USE gabby
GO

--CREATE OR ALTER VIEW tableau.kipp_forward_survey

WITH salesforce_data AS (
SELECT
       d.answer AS salesforce_id
      ,d.survey_response_id

      ,c.kipp_ms_graduate_c
      ,c.kipp_hs_graduate_c
      ,c.kipp_hs_class_c
      ,c.college_match_display_gpa_c
      ,c.kipp_region_school_c
      ,c.[description]
      ,c.gender_c
      ,c.ethnicity_c

      ,e.pursuing_degree_type_c
      ,e.start_date_c
      ,e.actual_end_date_c
      ,e.major_c
      ,e.status_c
      --need way to select just latest degree graduated from--
      --,ROW_NUMBER() OVER(
      --     PARTITION BY e.status_c,e.pursuing_degree_type_c
      --     ORDER BY e.actual_end_date_c DESC) AS latest_graduation

FROM surveygizmo.survey_detail d
JOIN gabby.alumni.contact c
  ON d.answer = c.salesforce_id_c
JOIN gabby.alumni.enrollment_c e
  ON c.salesforce_id_c = e.student_c
WHERE 
  d.survey_id = '6734664'
  AND d.question_shortname = 'salesforce_id'

)

SELECT
      s.survey_id
     ,s.survey_title
     ,s.survey_question_id
     ,s.question_shortname
     ,s.question_title
     ,s.question_type
     ,s.is_open_ended
     ,s.survey_response_id
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
     ,d.kipp_ms_graduate_c
     ,d.kipp_hs_graduate_c
     ,d.kipp_hs_class_c
     ,d.college_match_display_gpa_c
     ,d.kipp_region_school_c
     ,d.[description]
     ,d.gender_c
     ,d.ethnicity_c

     ,d.pursuing_degree_type_c
     ,d.start_date_c
     ,d.actual_end_date_c
     ,d.major_c
     ,d.status_c

FROM gabby.surveygizmo.survey_detail s
JOIN salesforce_data d
  ON d.survey_response_id = s.survey_response_id
WHERE s.survey_id = '6734664'


