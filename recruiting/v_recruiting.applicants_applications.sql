USE gabby
GO

CREATE OR ALTER VIEW recruiting.applicants_applications AS 

WITH applicants_long AS (

  SELECT candidate_id
        ,[key]
        ,[values]
  FROM (
    SELECT CONVERT(nvarchar(100), candidate_id) AS candidate_id
          ,CONVERT(nvarchar(100), candidate_first_name) AS candidate_first_name
          ,CONVERT(nvarchar(100), candidate_last_name) AS candidate_last_name
          ,CONVERT(nvarchar(100), candidate_email) AS candidate_email
          ,CONVERT(nvarchar(100), COALESCE(nj_undergrad_gpa, mia_undergrad_gpa)) AS undergrad_gpa
          ,CONVERT(nvarchar(100), COALESCE(nj_grad_gpa,mia_grad_gpa)) AS grad_gpa
          ,CONVERT(nvarchar(100), taf_current_or_former_kipp_employee) AS taf_current_or_former_kipp_employee
          ,CONVERT(nvarchar(100), mia_teacher_certification_question) AS mia_teacher_certification_question
          ,CONVERT(nvarchar(100), mia_out_of_state_teaching_certification_details) AS mia_out_of_state_teaching_certification_details
          ,CONVERT(nvarchar(100), nj_teacher_certification_question) AS nj_teacher_certification_question
          ,CONVERT(nvarchar(100), nj_out_of_state_teacher_certification_details) AS nj_out_of_state_teacher_certification_details
          ,CONVERT(nvarchar(100), nj_out_of_state_teacher_certification_sped_credits) AS nj_out_of_state_teacher_certification_sped_credits
          ,CONVERT(nvarchar(100), current_employer) AS current_employer
          ,CONVERT(nvarchar(100), taf_affiliated_orgs) AS taf_affiliated_orgs
          ,CONVERT(nvarchar(100), taf_other_orgs) AS taf_other_orgs
          ,CONVERT(nvarchar(100), taf_city_of_interest) AS taf_city_of_interest
          ,CONVERT(nvarchar(100), COALESCE(taf_current_or_former_kipp_employee,taf_current_or_former_kipp_njmia_employee)) AS current_or_former_kippnjmiataf_employee
          ,CONVERT(nvarchar(100), taf_expected_salary) AS taf_expected_salary
          ,CONVERT(nvarchar(100), kf_race) AS kf_race
          ,CONVERT(nvarchar(100), kf_gender) AS kf_gender
          ,CONVERT(nvarchar(100), kf_are_you_alumnus) AS kf_are_you_alumnus
          ,CONVERT(nvarchar(100), kf_in_which_regions_alumnus) AS kf_in_which_regions_alumnus
          ,CONVERT(nvarchar(100), candidate_tags_values) AS candidate_tags_values
          --,school_shared_with --not a live field, but we're adding it later
    FROM gabby.smartrecruiters.report_applicants) p
    UNPIVOT( [values] for [key] in (candidate_first_name
                                   ,candidate_last_name
                                   ,candidate_email
                                   ,undergrad_gpa
                                   ,grad_gpa
                                   ,taf_current_or_former_kipp_employee
                                   ,mia_teacher_certification_question
                                   ,mia_out_of_state_teaching_certification_details
                                   ,nj_teacher_certification_question
                                   ,nj_out_of_state_teacher_certification_details
                                   ,nj_out_of_state_teacher_certification_sped_credits
                                   ,current_employer
                                   ,taf_affiliated_orgs
                                   ,taf_other_orgs
                                   ,taf_city_of_interest
                                   ,current_or_former_kippnjmiataf_employee
                                   ,taf_expected_salary
                                   ,kf_race
                                   ,kf_gender
                                   ,kf_are_you_alumnus
                                   ,kf_in_which_regions_alumnus
                                   ,candidate_tags_values
                                   --,school_shared_with --not a live field, but we're adding it later
                                   ) 
                               )as unpvt
  )

,applicants_repivot AS (
SELECT candidate_id
       ,candidate_first_name
       ,candidate_last_name
       ,candidate_email
       ,undergrad_gpa
       ,grad_gpa
       ,taf_current_or_former_kipp_employee
       ,mia_teacher_certification_question
       ,mia_out_of_state_teaching_certification_details
       ,nj_teacher_certification_question
       ,nj_out_of_state_teacher_certification_details
       ,nj_out_of_state_teacher_certification_sped_credits
       ,current_employer
       ,taf_affiliated_orgs
       ,taf_other_orgs
       ,taf_city_of_interest
       ,current_or_former_kippnjmiataf_employee
       ,taf_expected_salary
       ,kf_race
       ,kf_gender
       ,kf_are_you_alumnus
       ,kf_in_which_regions_alumnus
       ,candidate_tags_values
FROM applicants_long
PIVOT(MAX([values]) FOR [key] IN (candidate_first_name
                                 ,candidate_last_name
                                 ,candidate_email
                                 ,undergrad_gpa
                                 ,grad_gpa
                                 ,taf_current_or_former_kipp_employee
                                 ,mia_teacher_certification_question
                                 ,mia_out_of_state_teaching_certification_details
                                 ,nj_teacher_certification_question
                                 ,nj_out_of_state_teacher_certification_details
                                 ,nj_out_of_state_teacher_certification_sped_credits
                                 ,current_employer
                                 ,taf_affiliated_orgs
                                 ,taf_other_orgs
                                 ,taf_city_of_interest
                                 ,current_or_former_kippnjmiataf_employee
                                 ,taf_expected_salary
                                 ,kf_race
                                 ,kf_gender
                                 ,kf_are_you_alumnus
                                 ,kf_in_which_regions_alumnus
                                 ,candidate_tags_values
                                 )) p
                                 
  )

SELECT apl.candidate_id
      ,apl.candidate_last_name
      ,apl.candidate_email
      ,apl.undergrad_gpa
      ,apl.grad_gpa
      ,apl.taf_current_or_former_kipp_employee
      ,apl.mia_teacher_certification_question
      ,apl.mia_out_of_state_teaching_certification_details
      ,apl.nj_teacher_certification_question
      ,apl.nj_out_of_state_teacher_certification_details
      ,apl.nj_out_of_state_teacher_certification_sped_credits
      ,apl.current_employer
      ,apl.taf_affiliated_orgs
      ,apl.taf_other_orgs
      ,apl.taf_city_of_interest
      ,apl.current_or_former_kippnjmiataf_employee
      ,apl.taf_expected_salary
      ,apl.kf_race
      ,apl.kf_gender
      ,apl.kf_are_you_alumnus
      ,apl.kf_in_which_regions_alumnus
      ,apl.candidate_tags_values

      ,app.application_id
      ,app.application_reason_for_rejection
      ,app.application_state
      ,app.application_state_hired_date
      ,app.application_state_in_review_date
      ,app.application_state_interview_date
      ,app.application_state_lead_date
      ,app.application_state_new_date
      ,app.application_state_offer_date
      ,app.application_state_rejected_date
      ,app.application_status
      ,app.application_status_in_review_resume_review_date
      ,app.application_status_interview_demo_date
      ,app.application_status_interview_phone_screen_date
      ,app.application_status_last_change_date
      ,app.department_internal
      ,app.job_city
      ,app.job_title
      ,app.recruiters
      ,app.source
      ,app.source_subtype
      ,app.source_type
      ,app.time_in_application_state_in_review
      ,app.time_in_application_state_interview
      ,app.time_in_application_state_lead
      ,app.time_in_application_state_new
      ,app.time_in_application_state_offered
      ,app.time_in_application_status_in_review_resume_review

FROM applicants_repivot apl
JOIN gabby.smartrecruiters.report_applications app
  ON apl.candidate_id = app.candidate_id