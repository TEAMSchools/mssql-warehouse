USE gabby
GO

CREATE OR ALTER VIEW tableau.teacher_allocation_miami AS

/*assigning row numbers for earliest job title and salary in last academic year*/
WITH last_year AS (
  SELECT eh.employee_number
        ,eh.job_title AS last_year_job
        
        ,s.annual_salary AS last_year_salary 
        
        ,ROW_NUMBER() OVER(
           PARTITION BY eh.employee_number 
           ORDER BY s.annual_salary
         ) AS rn
  FROM gabby.people.employment_history_static eh
  INNER JOIN gabby.people.salary_history_static s
    ON s.employee_number = eh.employee_number
   AND s.regular_pay_effective_date BETWEEN DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1, 7, 1)
                                        AND DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 6, 30)
  WHERE eh.business_unit_code = 'KIPP_MIAMI'
)

SELECT c.df_employee_number
      ,c.primary_site
      ,c.preferred_name
      ,c.primary_job
      ,c.annual_salary
      ,c.[status]
      ,c.original_hire_date
      ,CASE
        WHEN c.primary_job IN ('Assistant School Leader', 'Assistant School Leader, SPED',
               'School Leader', 'School Leader in Residence', 'Social Worker', 'Counselor',
               'Dean of Students', 'Head of Schools', 'Executive Director'
             ) THEN 'Instructional Staff'
        WHEN c.primary_job IN (
               'Teacher', 'Teacher In Residence', 'Learning Specialist'
             ) THEN 'Teachers'
        ELSE 'Not Included'
       END AS job_type

      ,l.last_year_job
      ,l.last_year_salary
FROM gabby.people.staff_crosswalk_static c
INNER JOIN last_year l
  ON l.employee_number = c.df_employee_number
 AND l.rn = 1
