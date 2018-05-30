USE gabby
GO

CREATE OR ALTER VIEW tableau.renewal_letter_dashboard AS 

WITH wf AS (
  SELECT affected_employee_number
        ,renewal_status_updated
        ,renewal_status
        ,ROW_NUMBER() OVER(
           PARTITION BY affected_employee_number
             ORDER BY renewal_status_updated DESC) AS rn_recent_workflow
  FROM
      (
       SELECT RIGHT(rs.affected_employee, 6) AS affected_employee_number             
             ,CONVERT(DATETIME2,rs.workflow_data_last_modified_timestamp) AS renewal_status_updated
             ,CASE 
               WHEN rs.workflow_status = 'completed' AND rs.workflow_data_saved = 'true' THEN 'Offer Accepted'
               WHEN rs.workflow_status = 'completed' AND rs.workflow_data_saved = 'false' THEN 'SL, HR, or Employee Rejected'
               WHEN rs.workflow_status = 'open' AND rs.workflow_data_saved = 'false' THEN 'Pending Acceptance'
               WHEN rs.workflow_status = 'withdrawn' AND rs.workflow_data_saved = 'false' THEN 'DSO Withdrew Letter'
              END AS renewal_status               
       FROM gabby.dayforce.renewal_status rs  
      ) sub
 )

,was AS (
  SELECT df_employee_number
        ,future_work_assignment_effective_start
        ,future_role
        ,future_department
        ,future_location        
        ,future_legal_entity
        ,future_job_family
        ,ROW_NUMBER() OVER(
           PARTITION BY df_employee_number
             ORDER BY future_work_assignment_effective_start DESC) AS rn_recent_work_assignment
  FROM
      (
       SELECT was.employee_reference_code AS df_employee_number
             ,was.job_family_name AS future_job_family
             ,was.legal_entity_name AS future_legal_entity
             ,was.physical_location_name AS future_location
             ,was.department_name AS future_department
             ,was.job_name AS future_role
             ,CONVERT(DATE,was.work_assignment_effective_start) AS future_work_assignment_effective_start
       FROM dayforce.employee_work_assignment was
      ) sub
 )

SELECT r.df_employee_number
      ,r.preferred_name
      ,r.manager_name AS current_manager_name
      ,r.status AS current_status
      ,r.legal_entity_name AS current_legal_entity
      ,r.primary_site AS current_site
      ,r.primary_on_site_department AS current_department
      ,r.primary_job AS current_role
      ,r.is_regional_staff AS is_regional_staff_current
      
      ,wf.renewal_status
      ,wf.renewal_status_updated
      
      ,was.future_legal_entity
      ,was.future_location
      ,was.future_department
      ,was.future_job_family
      ,was.future_role      
      ,was.future_work_assignment_effective_start
FROM dayforce.staff_roster r 
LEFT JOIN wf
  ON r.df_employee_number = wf.affected_employee_number
 AND wf.rn_recent_workflow = 1
LEFT JOIN was
  ON r.df_employee_number = was.df_employee_number
 AND was.rn_recent_work_assignment = 1