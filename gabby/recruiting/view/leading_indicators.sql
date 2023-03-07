CREATE OR ALTER VIEW
  recruiting.leading_indicators AS
WITH
  applications AS (
    SELECT
      application_id,
      status_type,
      date_val,
      job_city,
      recruiters,
      department_internal,
      job_title,
      application_state,
      source,
      source_type,
      source_subtype
    FROM
      (
        SELECT
          application_id,
          job_city,
          recruiters,
          department_internal,
          job_title,
          application_state,
          source,
          source_type,
          source_subtype,
          application_state_new_date AS application_date,
          application_state_in_review_date AS review_date,
          application_state_interview_date AS interview_date,
          (
            application_status_interview_phone_screen_requested_date
          ) AS phone_screen_requested,
          (
            application_status_interview_phone_screen_complete_date
          ) AS phone_screen_complete,
          application_status_interview_demo_date AS final_interview_demo,
          application_state_offer_date AS offer_date,
          application_state_hired_date AS hired_date
        FROM
          smartrecruiters.report_applications
      ) AS sub UNPIVOT (
        date_val FOR status_type IN (
          application_date,
          review_date,
          interview_date,
          phone_screen_requested,
          phone_screen_complete,
          final_interview_demo,
          offer_date,
          hired_date
        )
      ) AS u
  )
SELECT
  a.application_id,
  a.status_type,
  a.date_val,
  a.job_city,
  a.recruiters,
  a.job_title,
  a.application_state,
  a.source,
  a.source_type,
  a.source_subtype,
  b.candidate_id,
  CONCAT(
    b.candidate_last_name,
    ', ',
    b.candidate_first_name
  ) AS candidate_last_first,
  b.candidate_email,
  b.current_employer,
  b.candidate_tags_values,
  COALESCE(
    b.nj_undergrad_gpa,
    b.mia_undergrad_gpa
  ) AS undergrad_gpa,
  COALESCE(b.nj_grad_gpa, b.mia_grad_gpa) AS grad_gpa,
  COALESCE(
    b.nj_teacher_certification_question,
    b.mia_teacher_certification_question
  ) AS certification_instate,
  COALESCE(
    b.nj_out_of_state_teacher_certification_details,
    b.mia_out_of_state_teaching_certification_details
  ) AS certification_outstate,
  b.nj_out_of_state_teacher_certification_sped_credits AS nj_sped_credits,
  b.taf_affiliated_orgs,
  b.taf_other_orgs,
  b.taf_current_or_former_kipp_employee,
  COALESCE(
    b.taf_current_or_former_kipp_nj_mia_employee,
    b.taf_current_or_former_kipp_njmia_employee
  ) AS former_kippnjmia,
  b.taf_expected_salary,
  b.kf_race,
  b.kf_gender,
  b.kf_are_you_alumnus,
  b.kf_in_which_regions_alumnus
FROM
  applications AS a
  LEFT JOIN smartrecruiters.report_applicants AS b ON (
    a.application_id = b.application_id
  )
