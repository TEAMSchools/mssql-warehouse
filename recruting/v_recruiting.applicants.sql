USE gabby
GO

CREATE OR ALTER VIEW recruiting.applicants AS

SELECT pa.id
      ,pa.name AS profile_id
      ,pa.race_ethnicity_c AS race_ethnicity
      ,pa.gender_c AS gender
      ,pa.years_full_time_experience_c AS years_full_time_experience
      ,pa.years_of_full_time_teaching_c AS years_of_full_time_teaching
      ,pa.degree_1_school_name_c AS degree_1_school_name
      ,pa.degree_1_major_area_of_study_c AS degree_1_major_area_of_study
      ,pa.degree_1_gpa_c AS degree_1_gpa
      ,pa.degree_2_school_name_c AS degree_2_school_name
      ,pa.degree_2_major_area_of_study_c AS degree_2_major_area_of_study
      ,pa.degree_2_gpa_c AS degree_2_gpa
        
      ,a.name as jobapp_id      
      ,a.hired_status_date_c AS hired_status_date
      ,a.total_days_in_process_c AS total_days_in_process
      ,a.application_review_score_c AS application_review_score
      ,a.average_teacher_phone_score_c AS average_teacher_phone_score
      ,a.average_teacher_in_person_score_c AS average_teacher_in_person_score
      ,COALESCE(a.submitted_status_date_c, a.in_progress_status_date_c) AS submitted_date
        
      ,j.name AS job_position_id
      ,j.position_name_c AS job_position_name
      ,j.created_date AS postion_created_date
      ,j.desired_start_date_c AS desired_start_date
      ,j.date_position_filled_c AS date_position_filled
      ,j.subject_area_c AS subject_area
      ,j.grade_level_c AS grade_level
      ,j.grade_c AS grade
      ,j.job_sub_type_c AS job_sub_type
        
      ,p.name AS job_posting
FROM gabby.recruiting.profile_application_c pa 
LEFT JOIN gabby.recruiting.job_application_c a
  ON pa.id = a.profile_application_c
LEFT JOIN gabby.recruiting.job_position_c  j
  ON a.job_position_c = j.id     
LEFT JOIN gabby.recruiting.job_posting_c p
  ON j.job_posting_c = p.id