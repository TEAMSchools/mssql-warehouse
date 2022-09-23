USE gabby
GO

--CREATE OR ALTER VIEW extracts.gsheets_battleboard AS

WITH job_codes AS (
SELECT c.df_employee_number
      ,c.primary_site_school_level
      ,c.primary_job
      ,c.primary_on_site_department
      
      ,CASE 
       WHEN c.primary_job = 'Teacher' THEN 'LEAD'
       WHEN c.primary_job = 'Teacher in Residence' THEN 'TIR'
	   WHEN c.primary_job IN ('Learning Specialist','Behavior Specialist') THEN 'LS'
	   WHEN c.primary_job = 'Paraprofessional' THEN 'PARA'
       WHEN c.primary_job = 'School Leader' THEN 'SL'
       WHEN c.primary_job = 'School Leader In Residence' THEN 'SLIR'
       WHEN c.primary_job = 'Assistant School Leader' THEN 'AP'
       WHEN c.primary_job = 'Assistant School Leader, SPED' THEN 'APSPED'
       WHEN c.primary_job = 'School Leader' THEN 'SL'
       WHEN c.primary_job LIKE '%Facilities%' THEN 'FM'
       WHEN c.primary_job LIKE '%Custodian%' THEN 'POR'
       WHEN c.primary_job LIKE '%Porter%' THEN 'POR'
       WHEN c.primary_job IN ('School Operations Manager','Associate Director of School Operations','Academic Operations Manager') THEN 'OPS'
       WHEN c.primary_job IN ('Director of School Operations', 'Director of Campus Operations','Director Campus Operations', 'Director School Operations') THEN 'DSO'
       WHEN c.primary_job = 'Social Worker' THEN 'SW'
       WHEN c.primary_job LIKE '%Nurse%' THEN 'NURSE'
       WHEN c.primary_job LIKE '%Receptionist%' THEN 'REC'
       WHEN c.primary_job LIKE '%Dean%' THEN 'DEAN'
       WHEN c.primary_job LIKE '%Counselor%' THEN 'KFWD'
       WHEN c.primary_job ='Student Support Advocate' THEN 'SSA'
       ELSE 'OTHNI'
       END AS staffing_job_code
      ,p.course_name
      ,p.credittype
      ,CASE
       WHEN c.primary_site_school_level = 'ES' AND p.credittype IS NULL THEN 'FLEX'
       WHEN c.primary_site_school_level = 'ES' THEN UPPER(RIGHT(course_name,3))
       WHEN c.primary_site_school_level = 'MS' AND p.credittype IS NULL THEN 'FLEX'
       WHEN c.primary_site_school_level = 'MS' AND p.credittype IN ('ELA','ENG','MATH','SCI','SOC','WLANG') THEN CONCAT(credittype,'-',UPPER(RIGHT(course_name,3)))
       WHEN c.primary_site_school_level = 'MS' AND p.credittype NOT IN ('ELA','ENG','MATH','SCI','SOC','WLANG') THEN CONCAT('OTH','-',UPPER(RIGHT(course_name,3)))
       WHEN c.primary_site_school_level = 'HS' AND p.credittype IS NULL THEN 'FLEX'
       WHEN c.primary_site_school_level = 'HS' AND p.credittype IN ('ENG','MATH','SCI','SOC') THEN credittype
       WHEN c.primary_site_school_level = 'HS' AND p.credittype NOT IN ('ENG','MATH','SCI','SOC') THEN 'OTH'
       ELSE NULL
       END AS modifier
      
      ,UPPER(s.abbreviation) AS abbreviation
     
      ,ROW_NUMBER() OVER (
       PARTITION BY df_employee_number ORDER BY df_employee_number) AS rn
FROM gabby.people.staff_crosswalk_static c
LEFT JOIN gabby.powerschool.sections_identifiers p
  ON p.teachernumber COLLATE SQL_Latin1_General_CP1_CI_AS = c.ps_teachernumber COLLATE SQL_Latin1_General_CP1_CI_AS
  AND p.termid >= 3200
  AND p.course_number <> 'HR'
LEFT JOIN gabby.powerschool.schools s
  ON c.primary_site COLLATE SQL_Latin1_General_CP1_CI_AS = s.name COLLATE SQL_Latin1_General_CP1_CI_AS
AND c.[status] IN ('Active','Leave')

)

,id_generator AS (
SELECT df_employee_number
      ,course_name
      ,credittype
      ,CASE
       WHEN primary_job = 'Teacher' THEN CONCAT(primary_site_school_level,'-',abbreviation COLLATE SQL_Latin1_General_CP1_CI_AS,'-',staffing_job_code,'-',modifier)
       ELSE CONCAT(primary_site_school_level,'-',abbreviation COLLATE SQL_Latin1_General_CP1_CI_AS,'-',staffing_job_code)
       END AS staffing_model_id
FROM job_codes
WHERE rn = 1
)

,seat_number AS (
SELECT df_employee_number
      ,staffing_model_id
      ,course_name
      ,credittype
      ,RIGHT(100 + ROW_NUMBER() OVER (
       PARTITION BY staffing_model_id ORDER BY df_employee_number), 2) AS seat_number
FROM id_generator
)

,etr_pivot AS (
  SELECT df_employee_number
        ,academic_year  
        ,[PM1]
        ,[PM2]
        ,[PM3]
        ,[PM4]
  FROM
      (
       SELECT df_employee_number
             ,academic_year
             ,pm_term
             ,metric_value
        FROM gabby.pm.teacher_goals_lockbox_wide
        WHERE academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1
       ) sub
  PIVOT (
    MAX(metric_value)
    FOR pm_term IN ([PM1],[PM2],[PM3],[PM4])
   ) p
 )

,current_roster AS (
SELECT c.df_employee_number
      ,c.[status]
      ,c.preferred_name
      ,c.primary_site
      ,c.primary_job
      ,c.primary_on_site_department
      ,c.mail
      ,c.google_email
      ,c.original_hire_date

      ,s.course_name
      ,s.credittype

      ,ROUND(e.[PM1], 2) AS [PM1]
      ,ROUND(e.[PM2], 2) AS [PM2]
      ,ROUND(e.[PM3], 2) AS [PM3]

      ,ROUND(p.[PM4], 2) AS last_year_final

      ,i.answer AS itr_response

      ,CONCAT(staffing_model_id,'-',seat_number) AS staffing_model_id
      
FROM gabby.people.staff_crosswalk_static c
LEFT JOIN etr_pivot e 
  ON c.df_employee_number = e.df_employee_number
 AND e.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
LEFT JOIN etr_pivot p
  ON c.df_employee_number = p.df_employee_number
 AND p.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1
LEFT JOIN seat_number s
  ON c.df_employee_number = s.df_employee_number
LEFT JOIN gabby.surveys.intent_to_return_survey_detail i
  ON c.df_employee_number = i.respondent_df_employee_number
 AND i.question_shortname = 'intent_to_return'
 AND i.campaign_academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
WHERE c.[status] IN ('Active','Leave','Prestart') 
 AND c.legal_entity_name <> 'KIPP TEAM and Family Schools Inc.'
 AND c.primary_site NOT IN ('Room 9 - 60 Park Pl','Room 10 - 121 Market St','Room 11 - 1951 NW 7th Ave')
 AND c.primary_site NOT LIKE '%Campus%'
 )

SELECT m.include AS seat_open
      ,m.academic_year
      ,m.staffing_model_id
      ,m.display_name
      
      ,r.staffing_model_id AS generated_id
      ,r.course_name AS powerschool_course
      ,r.credittype AS powerschool_credit
      ,r.df_employee_number
      ,r.preferred_name
      ,r.primary_site
      ,r.primary_job
      ,r.google_email
      ,r.original_hire_date
      ,r.PM1
      ,r.PM2
      ,r.PM3
      ,r.last_year_final
      ,r.itr_response
      ,r.[status]

FROM gabby.people.staffing_model m
FULL OUTER JOIN current_roster r
ON m.staffing_model_id = r.staffing_model_id