WITH job_loc_mins AS (
  SELECT employee_number
        ,[location]
        ,job_title
        ,MIN(eh.position_effective_start_date) OVER(PARTITION BY eh.employee_number, eh.[location], job_title) AS job_loc_start
  FROM people.employment_history_static eh
  )

SELECT eh.employee_number
      ,NULL AS State_staff_ID
      ,cw.preferred_first_name
      ,cw.preferred_last_name
--      ,NULL as prior_name
      ,cw.userprincipalname
--      ,NULL as prior_email
      ,birth_date AS dob --leaving null on this video
      ,cw.primary_race_ethnicity_reporting
      ,cw.primary_race_ethnicity_reporting
      ,cw.gender 
      ,COALESCE(cw.rehire_date, cw.original_hire_date) AS hire_date
      ,eh.job_title AS primary_job
      ,eh.[location]
      ,jlm.job_loc_start --A min works! (KINDA)
      ,cw.termination_date  
--      ,cw.status_reason
      ,cw.primary_on_site_department
      ,cw.grades_taught
      ,cw.primary_on_site_department
      ,cw.legal_entity_name
      --,Work location_mapped  --mapping
      --,Role type_mapped  --mapping
      --,Ethnicity_mapped  ---mapping
      --,Gender_mapped  --mapping
      --,Survey Type --mapping
      ,CASE 
        WHEN cw.status = 'Leave' THEN 'DO NOT SURVEY'
        WHEN cw.primary_job = 'Security' THEN 'DO NOT SURVEY' --our security folks don't have computers...
        ELSE NULL
       END AS survey_override
FROM people.employment_history_static eh
JOIN people.staff_crosswalk_static cw
  ON eh.employee_number = cw.df_employee_number
 AND CONVERT(DATE, '2023-03-01') BETWEEN eh.position_effective_start_date AND COALESCE(eh.position_effective_end_date, DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR()+1,6,30)) --update as needed
 AND eh.primary_position = 'Yes' --Ignoring secondary roles
JOIN job_loc_mins jlm
  ON jlm.employee_number = eh.employee_number
 AND jlm.job_title = eh.job_title
 AND jlm.[location] = eh.[location]
WHERE cw.termination_date > CONVERT(DATE, '2022-03-01') OR termination_date IS NULL --update as needed
GROUP BY eh.employee_number
      ,cw.preferred_first_name
      ,cw.preferred_last_name
      ,cw.userprincipalname
      ,birth_date
      ,cw.primary_race_ethnicity_reporting
      ,cw.primary_race_ethnicity_reporting
      ,cw.gender 
      ,cw.rehire_date
      ,cw.original_hire_date
      ,eh.job_title
      ,eh.[location]
      ,jlm.job_loc_start --A min works! (KINDA)
      ,cw.termination_date  
      ,cw.status_reason
      ,cw.grades_taught
      ,cw.primary_on_site_department
      ,cw.legal_entity_name
      ,cw.[status]
      ,cw.primary_job