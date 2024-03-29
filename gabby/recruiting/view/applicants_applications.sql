CREATE OR ALTER VIEW
  recruiting.applicants_applications AS
WITH
  upvt AS (
    SELECT
      candidate_id,
      date_value,
      [key],
      [value],
      ROW_NUMBER() OVER (
        PARTITION BY
          candidate_id,
          [key]
        ORDER BY
          date_value DESC
      ) AS rn_curr
    FROM
      (
        SELECT
          apl.candidate_id,
          CAST(
            apl.candidate_first_name AS NVARCHAR(1024)
          ) AS candidate_first_name,
          CAST(
            apl.candidate_last_name AS NVARCHAR(1024)
          ) AS candidate_last_name,
          CAST(
            apl.candidate_email AS NVARCHAR(1024)
          ) AS candidate_email,
          CAST(
            apl.taf_current_or_former_kipp_employee AS NVARCHAR(1024)
          ) AS taf_current_or_former_kipp_employee,
          CAST(
            apl.mia_teacher_certification_question AS NVARCHAR(1024)
          ) AS mia_teacher_certification_question,
          CAST(
            apl.mia_out_of_state_teaching_certification_details AS NVARCHAR(1024)
          ) AS mia_out_of_state_teaching_certification_details,
          CAST(
            apl.nj_teacher_certification_question AS NVARCHAR(1024)
          ) AS nj_teacher_certification_question,
          CAST(
            apl.nj_out_of_state_teacher_certification_details AS NVARCHAR(1024)
          ) AS nj_out_of_state_teacher_certification_details,
          CAST(
            apl.nj_out_of_state_teacher_certification_sped_credits AS NVARCHAR(1024)
          ) AS nj_out_of_state_teacher_certification_sped_credits,
          CAST(
            apl.current_employer AS NVARCHAR(1024)
          ) AS current_employer,
          CAST(
            apl.taf_affiliated_orgs AS NVARCHAR(1024)
          ) AS taf_affiliated_orgs,
          CAST(
            apl.taf_other_orgs AS NVARCHAR(1024)
          ) AS taf_other_orgs,
          CAST(
            apl.taf_city_of_interest AS NVARCHAR(1024)
          ) AS taf_city_of_interest,
          CAST(
            apl.taf_expected_salary AS NVARCHAR(1024)
          ) AS taf_expected_salary,
          CAST(apl.kf_race AS NVARCHAR(1024)) AS kf_race,
          CAST(apl.kf_gender AS NVARCHAR(1024)) AS kf_gender,
          CAST(
            apl.kf_are_you_alumnus AS NVARCHAR(1024)
          ) AS kf_are_you_alumnus,
          CAST(
            apl.kf_in_which_regions_alumnus AS NVARCHAR(1024)
          ) AS kf_in_which_regions_alumnus,
          CAST(
            apl.candidate_tags_values AS NVARCHAR(1024)
          ) AS candidate_tags_values,
          CONVERT(
            NVARCHAR(1024),
            COALESCE(
              apl.application_field_school_shared_with_nj_,
              apl.application_field_school_shared_with_mia
            )
          ) AS school_shared_with,
          CONVERT(
            NVARCHAR(1024),
            COALESCE(
              apl.nj_undergrad_gpa,
              apl.mia_undergrad_gpa
            )
          ) AS undergrad_gpa,
          CONVERT(
            NVARCHAR(1024),
            COALESCE(
              apl.nj_grad_gpa,
              apl.mia_grad_gpa
            )
          ) AS grad_gpa,
          CONVERT(
            NVARCHAR(1024),
            COALESCE(
              apl.taf_current_or_former_kipp_employee,
              apl.taf_current_or_former_kipp_njmia_employee
            )
          ) AS current_or_former_kippnjmiataf_employee,
          COALESCE(
            app.application_state_lead_date,
            app.application_state_new_date,
            app.application_state_transferred_date,
            app.application_state_in_review_date,
            app.application_state_rejected_date,
            app.application_state_hired_date
          ) AS date_value
        FROM
          smartrecruiters.report_applicants AS apl
          INNER JOIN smartrecruiters.report_applications AS app ON (
            apl.application_id = app.application_id
          )
      ) AS sub UNPIVOT (
        [value] FOR [key] IN (
          candidate_first_name,
          candidate_last_name,
          candidate_email,
          undergrad_gpa,
          grad_gpa,
          taf_current_or_former_kipp_employee,
          mia_teacher_certification_question,
          mia_out_of_state_teaching_certification_details,
          nj_teacher_certification_question,
          nj_out_of_state_teacher_certification_details,
          nj_out_of_state_teacher_certification_sped_credits,
          current_employer,
          taf_affiliated_orgs,
          taf_other_orgs,
          taf_city_of_interest,
          current_or_former_kippnjmiataf_employee,
          taf_expected_salary,
          kf_race,
          kf_gender,
          kf_are_you_alumnus,
          kf_in_which_regions_alumnus,
          candidate_tags_values,
          school_shared_with
        )
      ) AS u
  ),
  applicants_repivot AS (
    SELECT
      candidate_id,
      candidate_first_name,
      candidate_last_name,
      candidate_email,
      undergrad_gpa,
      grad_gpa,
      taf_current_or_former_kipp_employee,
      mia_teacher_certification_question,
      mia_out_of_state_teaching_certification_details,
      nj_teacher_certification_question,
      nj_out_of_state_teacher_certification_details,
      nj_out_of_state_teacher_certification_sped_credits,
      current_employer,
      taf_affiliated_orgs,
      taf_other_orgs,
      taf_city_of_interest,
      current_or_former_kippnjmiataf_employee,
      taf_expected_salary,
      kf_race,
      kf_gender,
      kf_are_you_alumnus,
      kf_in_which_regions_alumnus,
      candidate_tags_values,
      school_shared_with
    FROM
      upvt PIVOT (
        MAX([value]) FOR [key] IN (
          candidate_first_name,
          candidate_last_name,
          candidate_email,
          undergrad_gpa,
          grad_gpa,
          taf_current_or_former_kipp_employee,
          mia_teacher_certification_question,
          mia_out_of_state_teaching_certification_details,
          nj_teacher_certification_question,
          nj_out_of_state_teacher_certification_details,
          nj_out_of_state_teacher_certification_sped_credits,
          current_employer,
          taf_affiliated_orgs,
          taf_other_orgs,
          taf_city_of_interest,
          current_or_former_kippnjmiataf_employee,
          taf_expected_salary,
          kf_race,
          kf_gender,
          kf_are_you_alumnus,
          kf_in_which_regions_alumnus,
          candidate_tags_values,
          school_shared_with
        )
      ) AS p
    WHERE
      rn_curr = 1
  )
SELECT
  apl.candidate_id,
  apl.candidate_first_name,
  apl.candidate_last_name,
  apl.candidate_email,
  apl.undergrad_gpa,
  apl.grad_gpa,
  apl.taf_current_or_former_kipp_employee,
  apl.mia_teacher_certification_question,
  apl.mia_out_of_state_teaching_certification_details,
  apl.nj_teacher_certification_question,
  apl.nj_out_of_state_teacher_certification_details,
  apl.nj_out_of_state_teacher_certification_sped_credits,
  apl.current_employer,
  apl.taf_affiliated_orgs,
  apl.taf_other_orgs,
  apl.taf_city_of_interest,
  apl.current_or_former_kippnjmiataf_employee,
  apl.taf_expected_salary,
  apl.kf_race,
  apl.kf_gender,
  apl.kf_are_you_alumnus,
  apl.kf_in_which_regions_alumnus,
  apl.candidate_tags_values,
  apl.school_shared_with,
  app.application_id,
  app.application_reason_for_rejection,
  app.application_state,
  app.application_state_hired_date,
  app.application_state_in_review_date,
  app.application_state_interview_date,
  app.application_state_lead_date,
  app.application_state_new_date,
  app.application_state_offer_date,
  app.application_state_rejected_date,
  app.application_status,
  app.application_status_in_review_resume_review_date,
  app.application_status_interview_demo_date,
  app.application_status_interview_phone_screen_date,
  app.application_status_last_change_date,
  app.department_internal,
  app.job_city,
  app.job_title,
  app.recruiters,
  app.[source],
  app.source_subtype,
  app.source_type,
  app.time_in_application_state_in_review,
  app.time_in_application_state_interview,
  app.time_in_application_state_lead,
  app.time_in_application_state_new,
  app.time_in_application_state_offered,
  app.time_in_application_status_in_review_resume_review,
  CASE
    WHEN MONTH(
      COALESCE(
        app.application_state_new_date,
        app.application_state_lead_date
      )
    ) >= 9 THEN YEAR(
      COALESCE(
        app.application_state_new_date,
        app.application_state_lead_date
      )
    ) + 1
    ELSE YEAR(
      COALESCE(
        app.application_state_new_date,
        app.application_state_lead_date
      )
    )
  END AS recruiting_year
FROM
  applicants_repivot AS apl
  INNER JOIN smartrecruiters.report_applications AS app ON (
    apl.candidate_id = app.candidate_id
  )
UNION ALL
SELECT
  COALESCE(profile_id, jobapp_id) AS candidate_id,
  SUBSTRING(
    [name],
    1,
    CHARINDEX(' ', [name])
  ) AS candidate_first_name,
  SUBSTRING(
    [name],
    CHARINDEX(' ', [name]) + 1,
    LEN([name])
  ) AS candidate_last_name,
  email AS candidate_email,
  CAST(degree_1_gpa AS NVARCHAR) AS undergrad_gpa,
  CAST(degree_2_gpa AS NVARCHAR) AS grad_gpa,
  NULL AS taf_current_or_former_kipp_employee,
  NULL AS mia_teacher_certification_question,
  NULL AS mia_out_of_state_teaching_certification_details,
  NULL AS nj_teacher_certification_question,
  NULL AS nj_out_of_state_teacher_certification_details,
  NULL AS nj_out_of_state_teacher_certification_sped_credits,
  previous_employer AS current_employer,
  NULL AS taf_affiliated_orgs,
  NULL AS taf_other_orgs,
  NULL AS taf_city_of_interest,
  NULL AS current_or_former_kippnjmiataf_employee,
  NULL AS taf_expected_salary,
  race_ethnicity AS kf_race,
  gender AS kf_gender,
  NULL AS kf_are_you_alumnus,
  NULL AS kf_in_which_regions_alumnus,
  NULL AS candidate_tags_values,
  NULL AS school_shared_with,
  jobapp_id AS application_id,
  NULL AS application_reason_for_rejection,
  selection_stage AS application_state,
  hired_status_date AS application_state_hired_date,
  NULL AS application_state_in_review_date,
  interview_date AS application_state_interview_date,
  NULL AS application_state_lead_date,
  submitted_date AS application_state_new_date,
  offer_date AS application_state_offer_date,
  rejected_date AS application_state_rejected_date,
  selection_status AS application_status,
  NULL AS application_status_in_review_resume_review_date,
  interview_date AS application_status_interview_demo_date,
  phone_screen_or_contact_date AS application_status_interview_phone_screen_date,
  last_modified_date AS application_status_last_change_date,
  sub_type AS department_internal,
  city AS job_city,
  job_posting AS job_title,
  recruiter AS recruiters,
  applicant_source AS [source],
  NULL AS source_subtype,
  NULL AS source_type,
  NULL AS time_in_application_state_in_review,
  NULL AS time_in_application_state_interview,
  NULL AS time_in_application_state_lead,
  NULL AS time_in_application_state_new,
  NULL AS time_in_application_state_offered,
  NULL AS time_in_application_status_in_review_resume_review,
  CASE
    WHEN MONTH(CAST(submitted_date AS DATE)) >= 9 THEN (
      YEAR(CAST(submitted_date AS DATE)) + 1
    )
    ELSE YEAR(CAST(submitted_date AS DATE))
  END AS recruiting_year
FROM
  recruiting.applicants
