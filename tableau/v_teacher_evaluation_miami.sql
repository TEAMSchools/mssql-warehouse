USE gabby
GO

CREATE OR ALTER VIEW tableau.miami_teacher_evaluation AS 


WITH pm_last_year AS (
	SELECT df_employee_number
	      ,overall_tier
	FROM gabby.pm.teacher_goals_overall_scores_static
	WHERE academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()-1
	  AND pm_term = 'PM4'
	  AND legal_entity_name = 'KIPP Miami'
)

,job_last_year AS (
	SELECT employee_number
	      ,job_title AS last_year_job
          ,work_assignment_start_date
          ,ROW_NUMBER() OVER(
           PARTITION BY employee_number
             ORDER BY work_assignment_start_date DESC) AS rn_latest
	FROM people.employment_history_static
	WHERE business_unit_code = 'KIPP_MIAMI'
	AND work_assignment_start_date < DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(),06,30)
)

SELECT c.primary_site AS 'School Name'
      ,'2332' AS 'School #'
      ,c.preferred_name AS 'Name'
      ,'' AS 'SSN'
      ,w.[Miami - ACES Number] AS 'ACES #'

      ,CASE
       WHEN s.overall_tier = 4 THEN 'C'
       WHEN s.overall_tier = 3 THEN 'D'
       WHEN s.overall_tier = 2 AND w.[Years Teaching - In any State] >3 THEN 'E'
       WHEN s.overall_tier = 2 AND w.[Years Teaching - In any State] <=3 THEN 'F' 
       WHEN s.overall_tier = 2 AND c.original_hire_date > DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR()-3,07,01) THEN 'E' 
       WHEN s.overall_tier = 2 AND c.original_hire_date < DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR()-3,07,01) THEN 'F' 
       WHEN s.overall_tier = 1 THEN 'G'    
       WHEN c.primary_job NOT IN ('Teacher','Teacher in Residence','Learning Specialist','Assistant School Leader','School Leader','Dean of Students') THEN 'Z' 
       ELSE 'I'
       END AS 'Personnel Evaluation'
      ,'' AS 'Instructional Leadership'
      ,'' AS 'Instructional Practice'
      ,'' AS 'Professional and Job Responsibilities'
      ,'' AS 'Student Performance'
      ,'' AS 'Measures of Student Performance'
      ,'' AS 'Data Validation'

	  ,j.last_year_job  
      ,c.primary_job AS current_job
      ,c.original_hire_date    
      ,s.overall_tier

      ,c.termination_date
      ,c.[status]
      ,w.[Years Teaching - In any State]
      ,c.df_employee_number AS 'Employee #'

FROM gabby.people.staff_crosswalk_static c
LEFT JOIN pm_last_year s
  ON c.df_employee_number = s.df_employee_number
LEFT JOIN job_last_year j
  ON c.df_employee_number = j.employee_number
LEFT JOIN gabby.adp.workers_custom_field_group_wide_static w
  ON c.df_employee_number = w.[Employee Number]
WHERE c.legal_entity_name = 'KIPP Miami'
AND c.original_hire_date < DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(),07,01)
AND j.rn_latest = 1