USE gabby
GO

--CREATE OR ALTER VIEW recruiting.leading_indicators AS

SELECT a.application_id
      ,a.application_state_new_date AS application_date
      ,a.application_status_interview_phone_screen_requested_date AS phone_screen_requested
      ,a.application_status_interview_phone_screen_complete_date AS phone_screen_completed
      ,a.application_status_interview_demo_date AS final_interview_demo
      ,a.application_state_offer_date AS offer_made
      ,a.application_state_hired_date AS offer_accepted
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
      ,DATENAME(WW, a.application_state_new_date) AS application_date_week
      ,DATENAME(WW, a.application_status_interview_phone_screen_requested_date) AS phone_screen_requested_week
      ,DATENAME(WW, a.application_status_interview_phone_screen_complete_date) AS phone_screen_completed_week
      ,DATENAME(WW, a.application_status_interview_demo_date) AS interview_demo_week
      ,DATENAME(WW, a.application_state_offer_date) AS offer_made_week
      ,DATENAME(WW, a.application_state_hired_date)AS offer_accepted_week

      ,p.candidate_id
      ,p.candidate_email
      ,p.candidate_first_name
      ,p.candidate_last_name

      ,DATENAME(WW, GETDATE()) AS current_week
FROM smartrecruiters.report_applicants p
INNER JOIN smartrecruiters.report_applications a
  ON p.application_id = a.application_id