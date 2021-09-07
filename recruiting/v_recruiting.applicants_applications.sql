USE gabby
GO

CREATE OR ALTER VIEW recruiting.applicants_applications AS 

WITH upvt AS (
  SELECT candidate_id
        ,date_value
        ,[key]
        ,[value]
        ,ROW_NUMBER() OVER(
           PARTITION BY candidate_id, [key] 
             ORDER BY date_value DESC) AS rn_curr
  FROM
      (
       SELECT apl.candidate_id
             ,CONVERT(NVARCHAR(1024), apl.candidate_first_name) AS candidate_first_name
             ,CONVERT(NVARCHAR(1024), apl.candidate_last_name) AS candidate_last_name
             ,CONVERT(NVARCHAR(1024), apl.candidate_email) AS candidate_email
             ,CONVERT(NVARCHAR(1024), apl.taf_current_or_former_kipp_employee) AS taf_current_or_former_kipp_employee
             ,CONVERT(NVARCHAR(1024), apl.mia_teacher_certification_question) AS mia_teacher_certification_question
             ,CONVERT(NVARCHAR(1024), apl.mia_out_of_state_teaching_certification_details) AS mia_out_of_state_teaching_certification_details
             ,CONVERT(NVARCHAR(1024), apl.nj_teacher_certification_question) AS nj_teacher_certification_question
             ,CONVERT(NVARCHAR(1024), apl.nj_out_of_state_teacher_certification_details) AS nj_out_of_state_teacher_certification_details
             ,CONVERT(NVARCHAR(1024), apl.nj_out_of_state_teacher_certification_sped_credits) AS nj_out_of_state_teacher_certification_sped_credits
             ,CONVERT(NVARCHAR(1024), apl.current_employer) AS current_employer
             ,CONVERT(NVARCHAR(1024), apl.taf_affiliated_orgs) AS taf_affiliated_orgs
             ,CONVERT(NVARCHAR(1024), apl.taf_other_orgs) AS taf_other_orgs
             ,CONVERT(NVARCHAR(1024), apl.taf_city_of_interest) AS taf_city_of_interest
             ,CONVERT(NVARCHAR(1024), apl.taf_expected_salary) AS taf_expected_salary
             ,CONVERT(NVARCHAR(1024), apl.kf_race) AS kf_race
             ,CONVERT(NVARCHAR(1024), apl.kf_gender) AS kf_gender
             ,CONVERT(NVARCHAR(1024), apl.kf_are_you_alumnus) AS kf_are_you_alumnus
             ,CONVERT(NVARCHAR(1024), apl.kf_in_which_regions_alumnus) AS kf_in_which_regions_alumnus
             ,CONVERT(NVARCHAR(1024), apl.candidate_tags_values) AS candidate_tags_values
             ,CONVERT(NVARCHAR(1024), COALESCE(apl.application_field_school_shared_with_nj_
											 ,apl.application_field_school_shared_with_miami_)) AS school_shared_with
             ,CONVERT(NVARCHAR(1024), COALESCE(apl.nj_undergrad_gpa
                                             ,apl.mia_undergrad_gpa)) AS undergrad_gpa
             ,CONVERT(NVARCHAR(1024), COALESCE(apl.nj_grad_gpa
                                             ,apl.mia_grad_gpa)) AS grad_gpa
             ,CONVERT(NVARCHAR(1024), COALESCE(apl.taf_current_or_former_kipp_employee
                                             ,apl.taf_current_or_former_kipp_njmia_employee)) AS current_or_former_kippnjmiataf_employee
             
             ,COALESCE(app.application_state_lead_date
                      ,app.application_state_new_date
                      ,app.application_state_transferred_date
                      ,app.application_state_in_review_date
                      ,app.application_state_rejected_date
                      ,app.application_state_hired_date) AS date_value
       FROM gabby.smartrecruiters.report_applicants apl
       JOIN gabby.smartrecruiters.report_applications app
         ON apl.application_id = app.application_id
      ) sub
  UNPIVOT(
    [value]
    FOR [key] IN (candidate_first_name
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
                 ,school_shared_with)
   ) u
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
		,school_shared_with
  FROM upvt
  PIVOT(
    MAX([value])
    FOR [key] IN (candidate_first_name
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
				 ,school_shared_with)
   ) p
  WHERE rn_curr = 1
 )

SELECT apl.candidate_id
      ,apl.candidate_first_name
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
	  ,apl.school_shared_with


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
      ,app.[source]
      ,app.source_subtype
      ,app.source_type
      ,app.time_in_application_state_in_review
      ,app.time_in_application_state_interview
      ,app.time_in_application_state_lead
      ,app.time_in_application_state_new
      ,app.time_in_application_state_offered
      ,app.time_in_application_status_in_review_resume_review
      ,CASE 
        WHEN MONTH(COALESCE(app.application_state_new_date, app.application_state_lead_date)) >= 9
             THEN YEAR(COALESCE(app.application_state_new_date, app.application_state_lead_date)) + 1
        ELSE YEAR(COALESCE(app.application_state_new_date, app.application_state_lead_date))
       END AS recruiting_year
FROM applicants_repivot apl
JOIN gabby.smartrecruiters.report_applications app
  ON apl.candidate_id = app.candidate_id

UNION ALL

SELECT COALESCE(a.profile_id, a.jobapp_id) AS candidate_id
      ,SUBSTRING(a.[name], 1, CHARINDEX(' ', a.[name])) AS candidate_first_name
      ,SUBSTRING(a.[name]
                ,CHARINDEX(' ', a.[name]) + 1
                ,LEN(a.[name])) AS candidate_last_name
      ,a.email AS candidate_email
      ,CONVERT(NVARCHAR, a.degree_1_gpa) AS undergrad_gpa
      ,CONVERT(NVARCHAR,a.degree_2_gpa) AS grad_gpa
      ,NULL AS taf_current_or_former_kipp_employee
      ,NULL AS mia_teacher_certification_question
      ,NULL AS mia_out_of_state_teaching_certification_details
      ,NULL AS nj_teacher_certification_question
      ,NULL AS nj_out_of_state_teacher_certification_details
      ,NULL AS nj_out_of_state_teacher_certification_sped_credits
      ,a.previous_employer AS current_employer
      ,NULL AS taf_affiliated_orgs
      ,NULL AS taf_other_orgs
      ,NULL AS taf_city_of_interest
      ,NULL AS current_or_former_kippnjmiataf_employee
      ,NULL AS taf_expected_salary
      ,a.race_ethnicity AS kf_race
      ,a.gender AS kf_gender
      ,NULL AS kf_are_you_alumnus
      ,NULL AS kf_in_which_regions_alumnus
      ,NULL AS candidate_tags_values
	  ,NULL AS school_shared_with
      ,a.jobapp_id AS application_id
      ,NULL AS application_reason_for_rejection
      ,a.selection_stage AS application_state
      ,a.hired_status_date AS application_state_hired_date
      ,NULL AS application_state_in_review_date
      ,a.interview_date AS application_state_interview_date
      ,NULL AS application_state_lead_date
      ,a.submitted_date AS application_state_new_date
      ,a.offer_date AS application_state_offer_date
      ,a.rejected_date AS application_state_rejected_date
      ,a.selection_status AS application_status
      ,NULL AS application_status_in_review_resume_review_date
      ,a.interview_date AS application_status_interview_demo_date
      ,a.phone_screen_or_contact_date AS application_status_interview_phone_screen_date
      ,a.last_modified_date AS application_status_last_change_date
      ,a.sub_type AS department_internal
      ,a.city AS job_city
      ,a.job_posting AS job_title
      ,a.recruiter AS recruiters
      ,a.applicant_source AS [source]
      ,NULL AS source_subtype
      ,NULL AS source_type
      ,NULL AS time_in_application_state_in_review
      ,NULL AS time_in_application_state_interview
      ,NULL AS time_in_application_state_lead
      ,NULL AS time_in_application_state_new
      ,NULL AS time_in_application_state_offered
      ,NULL AS time_in_application_status_in_review_resume_review
      ,CASE 
        WHEN MONTH(CONVERT(DATE, a.submitted_date)) >= 9 THEN YEAR(CONVERT(DATE, a.submitted_date)) + 1
        ELSE YEAR(CONVERT(DATE, a.submitted_date))
       END AS recruiting_year
FROM gabby.recruiting.applicants a
