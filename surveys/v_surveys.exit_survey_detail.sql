USE gabby
GO

CREATE OR ALTER VIEW surveys.exit_survey_detail AS

SELECT 	adp.associate_id
 ,adp.termination_date AS 'Official Termination Date'
	,adp.termination_reason_description AS 'Official Termination Reason'
	,adp.job_title_description AS 'Job Title'
	,adp.birth_date AS 'Date of Birth'
	,adp.eeo_ethnic_description AS 'Ethnicity'
	,adp.subject_dept_custom AS 'Department'
	,COALESCE(adp.location_custom, adp.location_description)  AS 'Location'
	,adp.benefits_eligibility_class_description AS 'Benefits Class'
	,COALESCE(adp.manager_name, adp.reports_to_name) AS 'Manager'
	,adp.is_management AS 'Management'
	,adp.gender AS 'Gender'
	,LEFT(adp.position_id,3) AS 'City'
	,LEFT(adp.position_id,3) AS 'State'
	,LEFT(adp.position_id,3) AS 'ZIP'
	,adp.hire_date AS 'Hire_date'
	,adp.position_status AS 'Position Status'
	
	,es.timestamp AS 'es Survey Date'
	,es.q_1 AS 'es Survey Title'
	,es.q_2 AS 'es Survey Location'
	,es.q_3 AS 'NPS'
	,es.q_4 AS 'NPS_Explanation'
	,es.q_5	AS 'Voluntary  Termination?'
	,es.q_6 AS 'es Survey Reason for leaving'
	,es.q_7 AS 'Next Role'
	,es.q_8 AS 'Next Title'
	,es.q_9 AS 'Expectation Alignment'
	,es.q_10 AS 'Open Comment'
	,es.q_11 AS 'Anonymous'
	,es.q_12 AS 'Consider KIPP in future?'
	,es.q_13 AS 'What does KIPP do well?'
	,es.q_14 AS 'How can KIPP improve?'
	,es.q_15 AS 'Rating: Career Growth'
	,es.q_16 AS 'Rating: Schedule Flexibility'
	,es.q_17 AS 'Rating: Compensation & Benefits'
	,es.q_18 AS 'Rating: School Culture'
	,es.q_19 AS 'Rating: Immediate Principal/Supervisor'
	,es.q_20 AS 'Rating: Kid Focus'
	,es.q_21 AS 'Rating: Impact'
	,es.q_22 AS 'Rating: Improvement'
	,es.q_23 AS 'Rating: Freedom'
	,es.q_24 AS 'Rating: Fun'
	,es.q_25 AS 'Rating: TEAMwork'
	,MONTH(adp.Hire_Date) AS 'Hire Month'
	,CASE WHEN MONTH(adp.termination_date) > 6 
			THEN REPLACE(STR(YEAR(adp.termination_date))+'-'+STR(YEAR(adp.termination_date)+1),' ','')
			ELSE REPLACE(STR(YEAR(adp.termination_date)-1)+'-'+STR(YEAR(adp.termination_date)),' ','') END 
				AS 'Termination Academic Year'
	,CASE WHEN YEAR(adp.Termination_date) IS NULL
			THEN YEAR(GETDATE()) - YEAR(adp.Hire_Date) + 1
			ELSE YEAR(adp.termination_date) - YEAR(adp.Hire_Date) + 1 END
				AS 'Years at KIPP'
	

FROM gabby.adp.staff_roster adp FULL OUTER JOIN gabby.surveys.exit_survey es

	ON adp.associate_id = es.associate_id
