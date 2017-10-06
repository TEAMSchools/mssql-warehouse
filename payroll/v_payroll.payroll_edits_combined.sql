USE gabby
GO

CREATE OR ALTER VIEW payroll.payroll_edits_combined AS

SELECT entity AS entity
	     ,salesforce_position_number AS sf_position_id
	     ,NULL AS associate_id
	     ,NULL AS position_id
	     ,preferred_name AS name
	     ,CONVERT(DATE,start_date) AS effective_date
      ,'New Hire' AS source
      ,CONVERT(NVARCHAR,salary) AS salary
	     ,leadership_stipend
      ,relocation_stipend
      ,other_stipend
	     ,CONVERT(NVARCHAR,ISNULL(leadership_stipend,0) + ISNULL(relocation_stipend,0) + ISNULL(other_stipend,0)) AS total_stipend
      ,NULL AS notes
FROM gabby.payroll.new_hire_tracker 

UNION ALL

SELECT entity AS entity
	     ,NULL AS sf_position_id
	     ,associate_id AS associate_id
	     ,position_id AS position_id
	     ,employee_name AS name
	     ,CONVERT(DATE,LEFT(payroll_date,10)) AS effective_date      
      ,'Pay Edits' AS source
      ,CONVERT(NVARCHAR,amount_of_edit) AS salary
	     ,NULL AS leadership_stipend
      ,NULL AS relocation_stipend
      ,NULL AS other_stipend      
      ,NULL AS total_stipend
	     ,description AS notes
FROM gabby.payroll.payroll_edit_tracker

UNION ALL

SELECT entity AS entity
	     ,NULL AS sf_position_id
	     ,employee_associate_id AS associate_id
	     ,employee_position_id AS position_id
	     ,employee_name AS name	     
      ,CONVERT(DATE,effective_date_of_change) AS effective_date
      ,'Status Change' AS source	   
      ,CONVERT(NVARCHAR,_new_base_salary_) AS salary
      ,NULL AS leadership_stipend
      ,NULL AS relocation_stipend
      ,NULL AS other_stipend      
	     ,CONVERT(NVARCHAR,bonus_stipend_amount_) AS total_stipend
	     ,bonus_stipend_details AS notes	     
FROM gabby.payroll.status_change
WHERE effective_date_of_change != 'varies'