USE gabby
GO

CREATE OR ALTER VIEW extracts.foundation_new_staff_form AS

WITH adp AS (
  SELECT e.location_description AS school_name
	       ,e.first_name AS first_name
	       ,e.last_name AS last_name
	       ,e.birth_date AS date_of_birth
	       ,e.gender AS gender
	       ,e.eeo_ethnic_description AS ethnicity	       
	       ,e.hire_date AS start_date_in_this_role
	       ,e.job_title_description AS job_title
	       ,e.grades_taught_custom AS grade_taught
	       ,e.subject_dept_custom AS subject
	       ,e.salesforce_job_position_name_custom

        ,a.mail AS work_email_address

	       ,NULL AS years_teaching	
  FROM gabby.adp.staff_roster e 
  LEFT OUTER JOIN gabby.adsi.user_attributes a
    ON e.associate_id = a.idautopersonalternateid
  WHERE e.hire_date >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)
    AND e.rn_curr = 1
 )

,salesforce AS (
  SELECT j.profile_application_c
        ,j.job_position_c

        ,pr.years_of_full_time_teaching_c AS years_teaching
	       ,pr.kipp_alumus_c AS kipp_alumni
	       ,pr.race_ethnicity_c AS ethnicity
	       ,pr.teacher_prep_program_name_c AS atp
	       ,pr.teacher_prep_program_region_c AS atp_city

        ,po.name AS salesforce_position_id	       
        ,po.grade_c AS grade_taught
	       ,po.subject_area_c AS subject	       
  FROM gabby.recruiting.job_application_c j 
  LEFT OUTER JOIN gabby.recruiting.profile_application_c pr
	  ON j.profile_application_c = pr.id 
	 LEFT OUTER JOIN gabby.recruiting.job_position_c po
	  ON j.job_position_c = po.id
  WHERE j.stage_c = 'Hired'
 )

SELECT 'KIPP New Jersey' AS region
	      ,c.school_name
	      ,c.first_name
	      ,c.last_name
	      ,c.date_of_birth
	      ,c.gender
	      ,COALESCE(c.ethnicity, s.ethnicity) AS ethnicity
	      ,c.work_email_address
	      ,c.start_date_in_this_role
	      ,1 AS fte
	      ,c.job_title
	      ,ISNULL(s.kipp_alumni, 'No') AS kipp_alumni
	      ,COALESCE(c.grade_taught, s.grade_taught) AS grade_taught
	      ,COALESCE(c.subject, s.subject) AS subject
	      ,COALESCE(s.years_teaching, c.years_teaching) AS years_teaching
	      ,s.atp
	      ,s.atp_city
FROM adp c 
LEFT OUTER JOIN salesforce s
	 ON c.salesforce_job_position_name_custom = s.salesforce_position_id