USE gabby
GO

CREATE OR ALTER VIEW recruiting.applicants AS

WITH position_parse AS (
  SELECT pn.name AS position_number
        ,REPLACE(LEFT(pn.position_name_c,LEN(pn.position_name_c) - CHARINDEX('_',REVERSE(pn.position_name_c))),'_','.') AS position_name_splitter
        ,pn.position_name_c AS position_name
        ,CASE WHEN CHARINDEX('_',pn.position_name_c) = 0 
             THEN NULL
             WHEN LEN(RIGHT(pn.position_name_c,CHARINDEX('_',REVERSE(pn.position_name_c))-1)) > 3
             THEN NULL
             ELSE LEN(RIGHT(pn.position_name_c,CHARINDEX('_',REVERSE(pn.position_name_c))-1))
          END AS position_count
        ,pn.city_c AS city
        ,pn.desired_start_date_c AS desired_start_date
        ,pn.created_date
        ,pn.job_type_c AS job_type
        ,pn.job_sub_type_c AS sub_type
        ,pn.status_c AS status
        ,pn.date_position_filled_c AS date_filled
        ,pn.replacement_or_new_position_c AS new_or_replacement
        ,pn.region_c AS region

        ,LEN(pn.position_name_c)-LEN(REPLACE(pn.position_name_c,'_','')) AS n
        ,pn.id
        ,pn.job_posting_c AS job_posting

  FROM gabby.recruiting.job_position_c pn
  WHERE pn.city_c IN ('Newark', 'Camden', 'Newark & Camden', 'Miami')
  )

SELECT pa.id
      ,pa.name AS profile_id
      ,pa.years_full_time_experience_c AS years_full_time_experience
      ,pa.years_of_full_time_teaching_c AS years_of_full_time_teaching
      ,pa.undergraduate_degree_school_name_c AS undergrad_school_name
      ,pa.undergraduate_major_area_of_study_c AS undergrad_major_area_of_study
      ,pa.undergraduate_gpa_c AS undergrad_gpa
      ,pa.degree_1_school_name_c AS degree_1_school_name
      ,pa.degree_1_major_area_of_study_c AS degree_1_major_area_of_study
      ,pa.degree_1_gpa_c AS degree_1_gpa
      ,pa.degree_2_school_name_c AS degree_2_school_name
      ,pa.degree_2_major_area_of_study_c AS degree_2_major_area_of_study
      ,pa.degree_2_gpa_c AS degree_2_gpa
      ,pa.current_certification_c AS is_certified
      ,pa.certificate_type_c AS certificate_type
      ,pa.certificate_subject_s_c AS certificate_subject
      ,pa.certificate_state_c AS certificate_state
      ,pa.certificate_expiration_c AS certificate_expiration
      
      ,c.name
      ,c.email
      ,c.ethnicity_c AS race_ethnicity
      ,c.gender_c AS gender
      ,c.title AS previous_role
      ,c.current_employer_c AS previous_employer

      ,a.name AS jobapp_id      
      ,a.hired_status_date_c AS hired_status_date
      ,a.total_days_in_process_c AS total_days_in_process
      ,a.application_review_score_c AS application_review_score
      ,a.average_teacher_phone_score_c AS average_teacher_phone_score
      ,a.average_teacher_in_person_score_c AS average_teacher_in_person_score
      ,COALESCE(a.submitted_status_date_c, a.in_progress_status_date_c) AS submitted_date
      ,a.applicant_source_c AS applicant_score
      ,a.cultivation_regional_source_c AS regional_source
      ,a.cultivation_regional_source_detail_c AS regional_source_detail
      ,LEFT(RIGHT(a.resume_url_c,LEN(a.resume_url_c)-9),LEN(RIGHT(a.resume_url_c,LEN(a.resume_url_c)-9))-39) AS resume_url
      ,a.phone_interview_status_date_c AS phone_screen_date
      ,a.in_person_interview_status_date_c AS interview_date
      ,a.offer_extended_date_c AS offer_date
      ,a.stage_c AS selection_stage
      ,a.status_c AS selection_status
      ,a.selection_notes_c AS selection_notes
        
      ,j.position_number
      ,j.position_name
      ,j.city
      ,j.job_type
      ,j.sub_type
      ,j.status
      ,j.new_or_replacement
      ,j.region
      ,j.desired_start_date
      ,j.created_date
      ,j.date_filled
      ,CASE WHEN position_name_splitter IS NULL THEN NULL WHEN j.n = 4 THEN PARSENAME(j.position_name_splitter,4) ELSE 'Invalid position_name Format' END AS recruiter
      ,CASE WHEN position_name_splitter IS NULL THEN NULL WHEN j.n = 4 THEN PARSENAME(j.position_name_splitter,3) ELSE 'Invalid position_name Format' END AS location
      ,CASE WHEN position_name_splitter IS NULL THEN NULL WHEN j.n = 4 THEN PARSENAME(j.position_name_splitter,2) ELSE 'Invalid position_name Format' END AS role_short
      ,CASE WHEN position_name_splitter IS NULL THEN NULL WHEN j.n = 4 THEN PARSENAME(j.position_name_splitter,1) ELSE 'Invalid position_name Format' END AS recruiing_year
      ,j.position_count
        
      ,p.name AS job_posting
FROM gabby.recruiting.profile_application_c pa 
LEFT JOIN gabby.recruiting.contact c
  ON pa.contact_id_c = LEFT(c.id, 15)
LEFT JOIN gabby.recruiting.job_application_c a
  ON pa.id = a.profile_application_c
LEFT JOIN position_parse  j
  ON a.job_position_c = j.id
LEFT JOIN gabby.recruiting.job_posting_c p
  ON j.job_posting = p.id