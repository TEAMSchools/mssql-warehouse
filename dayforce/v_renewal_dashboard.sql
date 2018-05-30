USE gabby
GO

CREATE OR ALTER VIEW renewal_dashboard AS 

WITH mwf AS
(
SELECT RIGHT(mwf.affected_employee,6) AS id
      ,MAX(mwf.workflow_data_last_modified_timestamp) AS max_workflow_date

FROM dayforce.renewal_status mwf

GROUP BY mwf.affected_employee
)

,wf AS
(
SELECT LEFT(rs.affected_employee,LEN(rs.affected_employee)-9) AS affected_employee
      ,CASE WHEN rs.workflow_status = 'completed' AND rs.workflow_data_saved = 'true' THEN 'Offer Accepted'
           WHEN rs.workflow_status = 'completed' AND rs.workflow_data_saved = 'false' THEN 'SL, HR, or employee rejected'
           WHEN rs.workflow_status = 'open' AND rs.workflow_data_saved = 'false' THEN 'pending acceptance'
           WHEN rs.workflow_status = 'withdrawn' AND rs.workflow_data_saved = 'false' THEN 'DSO withdrew letter'
           END AS renewal_status
      ,RIGHT(rs.affected_employee,6) AS id
      ,rs.workflow_data_last_modified_timestamp

FROM dayforce.renewal_status rs LEFT OUTER JOIN
     mwf
     ON RIGHT(rs.affected_employee,6) = mwf.id
WHERE rs.workflow_data_last_modified_timestamp = mwf.max_workflow_date
)

,mwas AS
(
SELECT mwas.employee_reference_code AS max_ref_code
      ,MAX(mwas.work_assignment_effective_start) AS max_start

FROM dayforce.employee_work_assignment mwas 

GROUP BY mwas.employee_reference_code
)

,was AS
(
SELECT was.employee_reference_code
      ,was.job_family_name AS future_job_family
      ,was.legal_entity_name AS future_legal_entity
      ,was.physical_location_name AS future_location
      ,was.department_name AS future_dept
      ,was.job_name AS future_role
FROM dayforce.employee_work_assignment was LEFT OUTER JOIN
     mwas
     ON was.employee_reference_code = mwas.max_ref_code
WHERE mwas.max_start = was.work_assignment_effective_start
)

SELECT r.df_employee_number
      ,r.preferred_name
--      ,r.manager_name
      ,r.status
      ,r.legal_entity_name AS current_entity
      ,r.primary_site AS current_site
      ,r.primary_on_site_department AS current_department
      ,r.primary_job AS current_role
      
      ,wf.renewal_status
      ,wf.workflow_data_last_modified_timestamp
      
      ,was.future_legal_entity
      ,was.future_location
      ,was.future_dept
      ,was.future_job_family
      ,was.future_role
      
FROM dayforce.staff_roster r LEFT OUTER JOIN
     wf
     ON r.df_employee_number = wf.id
     LEFT OUTER JOIN was
     ON was.employee_reference_code = r.df_employee_number
     
WHERE r.status IN ('Active','Inactive')
  AND r.legal_entity_name NOT IN ('KIPP NEW JERSEY')
  AND r.primary_site_entity NOT LIKE '%regional%'
  AND primary_site != 'Room 9 - 60 Park pl'
