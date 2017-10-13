USE gabby
GO

CREATE OR ALTER VIEW payroll.payroll_edits_combined AS

SELECT p.entity AS entity
	     ,p.salesforce_position_number AS sf_position_id
	     ,r.associate_id AS associate_id
	     ,r.position_id AS position_id
	     ,p.preferred_name AS name
	     ,CONVERT(DATE,p.start_date) AS effective_date
      ,'New Hire' AS source
      ,CONVERT(NVARCHAR,p.salary) AS salary
	     ,p.leadership_stipend
      ,p.relocation_stipend
      ,p.other_stipend
	     ,CONVERT(NVARCHAR,ISNULL(p.leadership_stipend,0) + ISNULL(p.relocation_stipend,0) + ISNULL(p.other_stipend,0)) AS total_stipend
      ,NULL AS notes
FROM gabby.payroll.new_hire_tracker p 
LEFT OUTER JOIN gabby.adp.staff_roster r
  ON p.salesforce_position_number = r.salesforce_job_position_name_custom
 AND r.rn_curr = 1

UNION ALL

SELECT e.entity AS entity
	     ,r.salesforce_job_position_name_custom AS sf_position_id
	     ,e.associate_id AS associate_id
	     ,e.position_id AS position_id
	     ,employee_name AS name
	     ,CONVERT(DATE,e.payroll_date) AS effective_date      
      ,'Pay Edits' AS source
      ,CONVERT(NVARCHAR,e.amount_of_edit) AS salary
	     ,NULL AS leadership_stipend
      ,NULL AS relocation_stipend
      ,NULL AS other_stipend      
      ,NULL AS total_stipend
	     ,e.description AS notes
FROM gabby.payroll.payroll_edit_tracker e 
LEFT OUTER JOIN gabby.adp.staff_roster r
  ON e.associate_id = r.associate_id
 AND r.rn_curr = 1

UNION ALL

SELECT s.entity AS entity
	     ,r.salesforce_job_position_name_custom AS sf_position_id
	     ,s.employee_associate_id AS associate_id
	     ,s.employee_position_id AS position_id
	     ,s.employee_name AS name	     
      ,CONVERT(DATE,s.effective_date_of_change) AS effective_date
      ,'Status Change' AS source	   
      ,CONVERT(NVARCHAR,s._new_base_salary_) AS salary
      ,NULL AS leadership_stipend
      ,NULL AS relocation_stipend
      ,NULL AS other_stipend      
	     ,CONVERT(NVARCHAR,s.bonus_stipend_amount_) AS total_stipend
	     ,s.bonus_stipend_details AS notes	     
FROM gabby.payroll.status_change s 
LEFT OUTER JOIN gabby.adp.staff_roster r
  ON s.employee_associate_id = r.associate_id
 AND r.rn_curr = 1
WHERE s.effective_date_of_change != 'varies'