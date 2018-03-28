USE gabby
GO

CREATE OR ALTER VIEW extracts.foundation_new_staff_form AS

WITH dayforce AS (
  SELECT e.primary_site AS school_name
	       ,e.preferred_first_name AS first_name
	       ,e.preferred_last_name AS last_name
	       ,e.birth_date AS date_of_birth
	       ,e.gender
	       ,e.primary_ethnicity AS ethnicity	       
	       ,e.original_hire_date AS start_date_in_this_role
	       ,e.primary_job AS job_title
	       ,e.grades_taught AS grade_taught
	       ,e.subjects_taught AS subject
	       ,e.salesforce_id

        ,a.mail AS work_email_address
  FROM gabby.dayforce.staff_roster e 
  LEFT JOIN gabby.adsi.user_attributes_static a
    ON e.adp_associate_id = a.idautopersonalternateid
  WHERE e.original_hire_date >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)    
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
	      ,s.years_teaching
	      ,s.atp
	      ,s.atp_city
FROM dayforce c 
LEFT JOIN salesforce s
	 ON c.salesforce_id = s.salesforce_position_id