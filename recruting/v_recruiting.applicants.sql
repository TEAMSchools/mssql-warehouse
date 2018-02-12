USE gabby
GO

CREATE OR ALTER VIEW recruiting.applicants AS

SELECT  adp.associate_id

        ,pa.id
        ,pa.name AS profile_id
        ,pa.race_ethnicity_c
        ,pa.gender_c
        ,pa.years_full_time_experience_c AS years_full_time_experience
        ,pa.years_of_full_time_teaching_c AS years_of_full_time_teaching
        ,pa.degree_1_school_name_c
        ,pa.degree_1_major_area_of_study_c
        ,pa.degree_1_gpa_c
        ,pa.degree_2_school_name_c
        ,pa.degree_2_major_area_of_study_c
        ,pa.degree_2_gpa_c
        
        ,a.name as jobapp_id
        ,COALESCE(a.submitted_status_date_c,a.in_progress_status_date_c) AS Submitted_date
        ,a.hired_status_date_c
        ,a.total_days_in_process_c
        ,a.application_review_score_c
        ,a.average_teacher_phone_score_c
        ,a.average_teacher_in_person_score_c
        
        ,j.name AS job_position_id
        ,j.position_name_c AS job_position_name
        ,j.created_date AS postion_created_date
        ,j.desired_start_date_c
        ,j.date_position_filled_c
        ,j.subject_area_c
        ,j.grade_level_c
        ,j.grade_c
        ,j.job_sub_type_c
        
        ,p.name AS job_posting

FROM gabby.recruiting.profile_application_c pa 
     LEFT OUTER JOIN gabby.recruiting.job_application_c a
     ON pa.id = a.profile_application_c
     LEFT OUTER JOIN gabby.recruiting.job_position_c  j
     ON a.job_position_c = j.id
     LEFT OUTER JOIN gabby.adp.staff_roster adp
     ON j.name = adp.salesforce_job_position_name_custom
     LEFT OUTER JOIN gabby.recruiting.job_posting_c p
     ON j.job_posting_c = p.id
   