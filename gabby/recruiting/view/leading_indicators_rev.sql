
WITH applications AS (
SELECT
      application_id,
      status_type,
      date_val,
      job_city,
      recruiters,
      department_internal
      job_title
    FROM
      (
        SELECT
          application_id,
          job_city,
          recruiters,
          department_internal,
          job_title,
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
          gabby.smartrecruiters.report_applications
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

SELECT * 
FROM applications AS a
JOIN gabby.smartrecruiters.report_applicants AS s
  ON a.application_id = s.application_id