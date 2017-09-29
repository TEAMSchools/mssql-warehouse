USE gabby
GO

----CREATE OR EDIT VIEW v_new_staff_feed

WITH core AS
(
SELECT 'KIPP New Jersey' AS region
	,e.location_description AS school_name
	,e.first_name AS first_name
	,e.last_name AS last_name
	,e.birth_date AS date_of_birth
	,e.gender AS gender
	,e.eeo_ethnic_description AS ethnicity
	,a.mail AS work_email_address
	,'No' AS kipp_alumni
	,e.hire_date AS start_date_in_this_role
	,1 AS fte
	,job_title_description AS job_title
	,grades_taught_custom AS grade_taught
	,subject_dept_custom AS subject
	,salesforce_job_position_name_custom
	,'' AS years_teaching
	
FROM ADP.export_people_details e LEFT OUTER JOIN adsi.user_attributes a
ON e.associate_id = a.idautopersonalternateid

WHERE e.hire_date >= CONVERT(datetime, '07/01/2017') --Not sure how to set up global academic year

), 
salesforce AS 
(
SELECT pr.years_of_full_time_teaching_c AS years_teaching
	,po.grade_c AS grade_taught
	,po.subject_area_c AS subject
	,po.name AS salesforce_position_id
	,pr.kipp_alumus_c AS kipp_alumni
	,pr.race_ethnicity_c AS ethnicity
	,pr.teacher_prep_program_name_c AS atp
	,pr.teacher_prep_program_region_c AS atp_city
FROM recruiting.job_application_c j LEFT OUTER JOIN recruiting.profile_application_c pr
	ON j.profile_application_c = pr.id 
	LEFT OUTER JOIN recruiting.job_position_c po
	ON j.job_position_c = po.id
)

SELECT region
	,school_name
	,first_name
	,last_name
	,date_of_birth
	,gender
	,COALESCE(c.ethnicity, s.ethnicity) AS ethnicity
	,work_email_address
	,start_date_in_this_role
	,fte
	,job_title
	,COALESCE(s.kipp_alumni, c.kipp_alumni) AS kipp_alumni
	,COALESCE(c.grade_taught, s.grade_taught) AS grade_taught
	,COALESCE(c.subject, s.subject) AS subject
	,COALESCE(s.years_teaching,c.years_teaching) AS years_teaching
	,atp
	,atp_city

FROM core c LEFT OUTER JOIN salesforce s
	ON c.salesforce_job_position_name_custom = s.salesforce_position_id