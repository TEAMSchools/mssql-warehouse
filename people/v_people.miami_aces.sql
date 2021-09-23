SELECT job_title 
,location
,position_status
,first_name
,last_name
,NULL AS SSN
,business_unit
,employee_number
,original_hire_date
,NULL as miami_aces
,flsa as Payclass
,NULL AS pay_frequency
,NULL AS highest_education_level
,NULL AS duty_days
,NULL AS teacher_eval
,address_street
,address_city
,address_state
,address_zip
,NULL AS MonthlyCarrierCost
,NULL AS MedicalCoverage
,NULL AS Contribution504B
,NULL AS BasicLifePlan
,annual_salary
FROM people.staff_roster
WHERE business_unit LIKE '%miami%'
AND position_status != 'Terminated'

ORDER BY last_name