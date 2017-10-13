USE gabby
GO

--CREATE OR EDIT VIEW v_payroll_edits

WITH edits_union AS
(
SELECT entity AS entity
	  ,salesforce_position_number AS sf_position_id
	  ,r.associate_id AS associate_id
	  ,r.position_id AS position_id
	  ,p.preferred_name AS name
	  ,CONVERT(varchar,salary) + ' (salary)' AS salary
	  ,CONVERT(varchar,leadership_stipend) + ' (Leadership, )' + CONVERT(varchar,relocation_stipend) + ' (Relocation, )' + CONVERT(varchar,other_stipend) + ' (Other, )' AS stipend
	  ,'' AS notes
	  ,start_date AS effective_date
	  ,'New Hire' AS source
FROM gabby.payroll.new_hire_tracker p LEFT OUTER JOIN gabby.adp.staff_roster r
	  ON  p.salesforce_position_number = r.salesforce_job_position_name_custom

UNION ALL

SELECT entity AS entity
	  ,r.salesforce_job_position_name_custom AS sf_position_id
	  ,e.associate_id AS associate_id
	  ,e.position_id AS position_id
	  ,employee_name AS name
	  ,CONVERT(varchar,amount_of_edit) + ' (amount of edit)' AS salary
	  ,'' AS stipend
	  ,description AS notes
	  ,CONVERT(datetime,LEFT(payroll_date,10)) AS effective_date
	  ,'Pay Edits' AS source
FROM gabby.payroll.payroll_edit_tracker e LEFT OUTER JOIN gabby.adp.staff_roster r
      ON e.associate_id = r.associate_id

UNION ALL

SELECT entity AS entity
	  ,r.salesforce_job_position_name_custom AS sf_position_id
	  ,employee_associate_id AS associate_id
	  ,employee_position_id AS position_id
	  ,employee_name AS name
	  ,_new_base_salary_ AS salary
	  ,bonus_stipend_amount_ AS stipend
	  ,bonus_stipend_details AS notes
	  ,effective_date_of_change AS effective_date
	  ,'Status Change' AS source
	   
FROM gabby.payroll.status_change s LEFT OUTER JOIN gabby.adp.staff_roster r
      ON s.employee_associate_id = r.associate_id
WHERE effective_date_of_change != NULL
	OR effective_date_of_change != 'varies'

)

SELECT * 
FROM edits_union
ORDER BY effective_date DESC