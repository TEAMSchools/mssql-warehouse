USE gabby GO
CREATE OR ALTER VIEW
  tableau.applicant_history AS
SELECT
  c.candidate_id,
  c.candidate_first_name,
  c.candidate_last_name,
  c.kf_race,
  c.kf_gender,
  c.kf_are_you_alumnus,
  c.kf_in_which_regions_alumnus,
  app.job_city,
  app.recruiters,
  app.department_internal,
  app.job_title,
  app.application_state,
  app.application_status,
  app.application_state_lead_date,
  app.time_in_application_state_lead,
  app.application_state_new_date,
  app.time_in_application_state_new,
  app.application_status_last_change_date,
  app.application_state_in_review_date,
  app.time_in_application_state_in_review,
  app.application_state_interview_date,
  app.application_status_interview_phone_screen_date,
  app.application_status_interview_demo_date,
  app.time_in_application_state_interview,
  app.application_state_offer_date,
  app.time_in_application_state_offered,
  app.application_state_hired_date,
  app.application_state_rejected_date,
  app.application_reason_for_rejection,
  app.candidate_tags_values,
  app.[source],
  app.source_type,
  app.source_subtype,
  app.time_in_application_status_in_review_resume_review,
  app.application_id,
  app.application_status_before_withdrawal,
  app.time_in_application_status_interview_demo,
  app.application_status_before_rejection,
  app.time_in_application_status_interview_phone_screen,
  app.application_state_withdrawn_date,
  app.application_state_transferred_date,
  app.application_reason_for_withdrawal,
  app.time_in_application_status_interview_phone_screen_complete,
  app.application_status_interview_phone_screen_complete_date,
  app.time_in_application_status_interview_phone_screen_requested,
  app.application_status_interview_phone_screen_requested_date,
  COALESCE(app.application_state_lead_date, app.application_state_new_date) AS enter_sr_date,
  ROW_NUMBER() OVER (
    PARTITION BY
      c.candidate_id
    ORDER BY
      COALESCE(app.application_state_lead_date, app.application_state_new_date)
  ) AS row_most_recent
FROM
  gabby.smartrecruiters.report_applications AS app
  JOIN gabby.smartrecruiters.report_applicants AS c ON app.application_id = c.application_id
WHERE
  app.job_title <> 'New Jersey - data migrated from Salesforce'
