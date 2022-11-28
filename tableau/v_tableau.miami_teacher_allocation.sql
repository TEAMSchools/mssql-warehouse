USE gabby
GO

--CREATE OR ALTER VIEW tableau.teacher_allocation_miami AS

/*assigning row numbers for earliest job title and salary in last academic year*/
WITH last_year AS (
	SELECT eh.employee_number
	      ,eh.job_title AS last_year_job
          ,s.annual_salary AS last_year_salary 
          ,ROW_NUMBER() OVER(PARTITION BY eh.employee_number ORDER BY s.annual_salary) AS rn
	FROM people.employment_history_static eh
    JOIN people.salary_history_static s
      ON s.employee_number = eh.employee_number
	WHERE business_unit_code = 'KIPP_MIAMI'
	AND s.regular_pay_effective_date BETWEEN DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR()-1,07,01) AND DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(),06,30)

    )
    
SELECT primary_site
      ,df_employee_number
      ,preferred_name
      ,last_year_job
      ,primary_job AS current_job
      ,last_year_salary
      ,annual_salary
      ,status
      ,c.original_hire_date
     ,CASE
      WHEN c.primary_job IN ('Assistant School Leader',
                             'Assistant School Leader, SPED',
                             'School Leader', 
                             'School Leader in Residence',
                             'Social Worker',
                             'Counselor',
                             'Dean of Students',
                             'Head of Schools',
                             'Executive Director') THEN 'Instructional Staff'
      WHEN c.primary_job IN ('Teacher',
                             'Teacher In Residence',
                             'Learning Specialist') THEN 'Teachers'
      ELSE 'Not Included' END AS job_type
FROM people.staff_crosswalk_static c
JOIN last_year l
  ON l.employee_number = c.df_employee_number
AND l.rn = 1