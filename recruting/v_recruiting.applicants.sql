USE gabby
GO

CREATE OR ALTER VIEW recruiting.applicants AS

WITH position_parse AS (
  SELECT pn.id
        ,pn.name AS position_number
        ,pn.position_name_c AS position_name        
        ,pn.region_c AS region        
        ,pn.city_c AS city
        ,pn.created_date
        ,pn.desired_start_date_c AS desired_start_date
        ,pn.date_position_filled_c AS date_filled        
        ,pn.job_type_c AS job_type
        ,pn.job_sub_type_c AS sub_type
        ,pn.status_c AS status        
        ,pn.replacement_or_new_position_c AS new_or_replacement        
        ,pn.job_posting_c AS job_posting
        ,LEN(pn.position_name_c) - LEN(REPLACE(pn.position_name_c, '_', '')) AS n
        ,REPLACE(LEFT(pn.position_name_c, LEN(pn.position_name_c) - CHARINDEX('_', REVERSE(pn.position_name_c))), '_', '.') AS position_name_splitter
        ,CASE 
          WHEN CHARINDEX('_',pn.position_name_c) = 0 THEN NULL
          WHEN LEN(RIGHT(pn.position_name_c, CHARINDEX('_', REVERSE(pn.position_name_c)) - 1)) > 3 THEN NULL
          ELSE LEN(RIGHT(pn.position_name_c, CHARINDEX('_', REVERSE(pn.position_name_c)) - 1))
         END AS position_count
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
      ,a.applicant_source_c AS applicant_source
      ,a.cultivation_regional_source_detail_c AS regional_source_detail      
      ,a.phone_interview_status_date_c AS phone_screen_or_contact_date
      ,a.in_person_interview_status_date_c AS interview_date
      ,a.offer_extended_date_c AS offer_date
      ,a.stage_c AS selection_stage
      ,a.selection_status_c AS selection_status
      ,a.selection_notes_c AS selection_notes
      ,COALESCE(a.submitted_status_date_c, a.in_progress_status_date_c) AS submitted_date
      ,LEFT(RIGHT(a.resume_url_c,LEN(a.resume_url_c)-9),LEN(RIGHT(a.resume_url_c,LEN(a.resume_url_c)-9))-39) AS resume_url
        
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
      ,j.position_count
      ,CASE 
        WHEN j.position_name_splitter IS NULL THEN NULL 
        WHEN j.n = 4 THEN PARSENAME(j.position_name_splitter, 4) 
        ELSE 'Invalid position_name Format' 
       END AS recruiter
      ,CASE 
        WHEN j.position_name_splitter IS NULL THEN NULL 
        WHEN j.n = 4 THEN PARSENAME(j.position_name_splitter, 3) 
        ELSE 'Invalid position_name Format' 
       END AS location
      ,CASE 
        WHEN j.position_name_splitter IS NULL THEN NULL 
        WHEN j.n = 4 THEN PARSENAME(j.position_name_splitter, 2) 
        ELSE 'Invalid position_name Format' 
       END AS role_short
      ,CASE 
        WHEN j.position_name_splitter IS NULL THEN NULL 
        WHEN j.n = 4 THEN PARSENAME(j.position_name_splitter, 1) 
        ELSE 'Invalid position_name Format' 
       END AS recruiring_year
        
      ,p.name AS job_posting

      ,'application' as candidate_type

      ,NULL AS cult_grade_level_interest
      ,NULL AS cult_subject_interest
FROM gabby.recruiting.profile_application_c pa 
LEFT JOIN gabby.recruiting.contact c
  ON pa.contact_id_c = LEFT(c.id, 15)
LEFT JOIN gabby.recruiting.job_application_c a
  ON pa.id = a.profile_application_c
LEFT JOIN gabby.recruiting.job_posting_c p
  ON p.id= a.job_posting_c
LEFT JOIN position_parse  j
  ON a.job_position_c = j.id


UNION ALL

SELECT c.id AS id
      ,p.name AS profile_id
      ,NULL AS years_full_time_experience
      ,NULL AS years_of_full_time_teaching
      ,NULL AS undergrad_school_name
      ,NULL AS undergrad_major_area_of_study
      ,NULL AS undergrad_gpa
      ,NULL AS degree_1_school_name
      ,NULL AS degree_1_major_area_of_study
      ,NULL AS degree_1_gpa
      ,NULL AS degree_2_school_name
      ,NULL AS degree_2_major_area_of_study
      ,NULL AS degree_2_gpa
      ,NULL AS is_certified
      ,NULL AS certificate_type
      ,NULL AS certificate_subject
      ,NULL AS certificate_state
      ,NULL AS certificate_expiration
      ,co.name AS name
      ,co.email
      ,co.ethnicity_c AS race_ethnicity
      ,co.gender_c AS gender
      ,co.title AS previous_role
      ,co.current_employer_c AS previous_employer
      ,c.name AS jobapp_id
      ,NULL AS hired_status_date
      ,NULL AS total_days_in_process
      ,NULL AS application_review_score
      ,NULL AS average_teacher_phone_score
      ,NULL AS average_teacher_in_person_score
      ,c.regional_source_c AS applicant_source
      ,COALESCE(c.regional_source_detail_c, c.referred_by_c, c.identified_by_c) AS regional_source_detail
      ,c.first_contact_date_c AS phone_screen_or_contact_date
      ,NULL AS interview_date
      ,NULL AS offer_date
      ,c.cultivation_stage_c AS selection_stage
      ,c.current_status_c  AS selection_status
      ,CONCAT(c.cultivation_notes_c, 'regions applied to this year: ' + c.regions_applied_to_this_year_c) AS selection_notes
      ,NULL AS submitted_date
      ,NULL AS resume_url
      ,NULL AS position_number
      ,c.job_position_name_c AS position_name
      ,NULL AS city
      ,c.experience_type_c AS job_type
      ,NULL AS sub_type
      ,NULL AS status
      ,NULL AS new_or_replacement
      ,NULL AS region
      ,NULL AS desired_start_date
      ,c.created_date AS created_date
      ,NULL AS date_filled
      ,NULL AS position_count
      ,NULL AS recruiter
      ,NULL AS location
      ,NULL AS role_short
      ,COALESCE(c.future_prospect_year_c, (CONVERT(VARCHAR(25),gabby.utilities.DATE_TO_SY(c.created_date)) + '-' + CONVERT(VARCHAR(25),gabby.utilities.DATE_TO_SY(c.created_date) + 1))) AS recruiting_year
      ,c.instructional_experience_level_c AS job_posting
      ,'culitvation' AS candidate_type
      ,c.primary_interest_general_grade_level_c AS cult_grade_level_interest
      ,c.primary_interest_general_subject_c AS cult_subject_interest
FROM gabby.recruiting.cultivation_c c 
LEFT JOIN gabby.recruiting.profile_application_c p
  ON c.contact_c = p.applicant_c
LEFT JOIN gabby.recruiting.contact co
  ON c.contact_c = LEFT(co.id, 15)
WHERE p.name IS NULL 