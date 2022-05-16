USE gabby
GO

CREATE OR ALTER VIEW recruiting.leading_indicators AS

WITH latest_update_date AS (
  SELECT application_id
        ,MAX(latest_update) AS last_update_date
  FROM
    (SELECT a.application_id 
        ,a.application_state_new_date AS application_date
        ,a.application_state_in_review_date AS review_date
        ,a.application_state_interview_date AS interview_date
        ,a.application_status_interview_phone_screen_requested_date AS phone_screen_requested
        ,a.application_status_interview_phone_screen_complete_date AS phone_screen_complete
        ,a.application_status_interview_demo_date AS final_interview_demo
        ,a.application_state_offer_date AS offer_date
        ,a.application_state_hired_date AS hired_date
     FROM smartrecruiters.report_applications a) AS p
  
  UNPIVOT(
  latest_update 
  FOR date_val IN (application_date
                  ,review_date
                  ,interview_date
                  ,phone_screen_requested
                  ,phone_screen_complete
                  ,final_interview_demo
                  ,offer_date
                  ,hired_date) ) AS unpvt
                  GROUP BY application_id
  )


SELECT a.application_id
      ,a.application_state_new_date AS application_date
      ,a.application_state_in_review_date AS review_date
      ,a.application_state_interview_date AS interview_date
      ,a.application_status_interview_phone_screen_requested_date AS phone_screen_requested
      ,a.application_status_interview_phone_screen_complete_date AS phone_screen_completed
      ,a.application_status_interview_demo_date AS final_interview_demo
      ,a.application_state_offer_date AS offer_made
      ,a.application_state_hired_date AS offer_accepted
      ,a.application_state_rejected_date AS rejected_date
      ,a.application_state_withdrawn_date AS withdrawn_date
      ,a.application_status
      ,a.department_internal
      ,a.job_city
      ,a.job_title
      ,a.recruiters
      ,a.[source]
      ,a.source_type
      ,a.source_subtype
      /*List of titles tracked by Recruiting Team include these words*/
      ,CASE
        WHEN a.job_title LIKE '%Teacher%' 
          OR a.job_title LIKE '%Teacher in Residence%'
          OR a.job_title LIKE '%Learning Specialist%'
          OR a.job_title LIKE '%Paraprofessional%'
          OR a.job_title LIKE '%Speech Language Pathologist%'
          OR a.job_title LIKE '%Social Worker%'
          OR a.job_title LIKE '%Behavior Analyst%'
          OR a.job_title LIKE '%Behavior Specialist%'
          OR a.job_title LIKE '%Assistant Dean%'
          OR a.job_title LIKE '%Dean%'
          OR a.job_title LIKE '%Dean of Students%'
             THEN 1
        ELSE 0
       END AS included_title
      ,p.candidate_id
      ,p.candidate_email
      ,p.candidate_first_name
      ,p.candidate_last_name

      ,DATENAME(WW, GETDATE()) AS current_week
      ,d.last_update_date

FROM smartrecruiters.report_applicants p
INNER JOIN smartrecruiters.report_applications a
  ON p.application_id = a.application_id
JOIN latest_update_date d
  ON p.application_id = d.application_id