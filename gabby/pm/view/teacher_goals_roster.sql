CREATE OR ALTER VIEW
  pm.teacher_goals_roster AS
WITH
  academic_years AS (
    SELECT
      n AS academic_year
    FROM
      utilities.row_generator_smallint
    WHERE
      /* 2018 = first year of Teacher Goals */
      n BETWEEN 2018 AND (
        utilities.GLOBAL_ACADEMIC_YEAR ()
      )
  ),
  work_assignment AS (
    SELECT
      df_employee_number,
      job_name,
      is_sped_teacher,
      site_name_clean,
      ps_school_id,
      department_name,
      legal_entity_name,
      work_assignment_effective_end,
      (
        utilities.DATE_TO_SY (work_assignment_effective_start)
      ) AS start_academic_year,
      utilities.DATE_TO_SY (work_assignment_effective_end) AS end_academic_year
    FROM
      (
        SELECT
          wa.employee_number AS df_employee_number,
          wa.job_title AS job_name,
          wa.home_department AS department_name,
          wa.business_unit AS legal_entity_name,
          CASE
            WHEN (
              wa.job_title IN (
                'Learning Specialist',
                'Learning Specialist Coordinator'
              )
              OR wa.home_department = 'Special Education'
            ) THEN 1
            ELSE 0
          END AS is_sped_teacher,
          CAST(wa.effective_start_date AS DATE) AS work_assignment_effective_start,
          CAST(
            COALESCE(
              wa.effective_end_date,
              DATEFROMPARTS(
                utilities.GLOBAL_ACADEMIC_YEAR () + 1,
                6,
                30
              )
            ) AS DATE
          ) AS work_assignment_effective_end,
          sc.ps_school_id,
          sc.site_name_clean
        FROM
          people.employment_history_static AS wa
          LEFT JOIN people.school_crosswalk AS sc ON (
            wa.[location] = sc.site_name
            AND sc._fivetran_deleted = 0
          )
        WHERE
          wa.job_title IN (
            'Teacher',
            'Teacher Fellow',
            'Teacher in Residence',
            'Co-Teacher',
            'Learning Specialist',
            'Learning Specialist Coordinator',
            'Teacher, ESL',
            'Teacher ESL'
          )
          AND wa.position_status NOT IN ('Terminated', 'Pre-Start')
      ) AS sub
  ),
  current_work_assignment AS (
    SELECT
      wa.df_employee_number,
      wa.job_name,
      wa.site_name_clean,
      wa.department_name,
      wa.legal_entity_name,
      wa.ps_school_id,
      wa.is_sped_teacher,
      ay.academic_year,
      ROW_NUMBER() OVER (
        PARTITION BY
          wa.df_employee_number,
          ay.academic_year
        ORDER BY
          wa.work_assignment_effective_end DESC
      ) AS rn_emp_yr
    FROM
      work_assignment AS wa
      INNER JOIN academic_years AS ay ON (
        ay.academic_year BETWEEN wa.start_academic_year AND wa.end_academic_year
      )
  )
SELECT
  cwa.df_employee_number,
  cwa.academic_year,
  cwa.job_name AS primary_job,
  cwa.site_name_clean AS primary_site,
  cwa.department_name AS primary_on_site_department,
  cwa.legal_entity_name,
  cwa.ps_school_id AS primary_site_schoolid,
  cwa.is_sped_teacher,
  sr.ps_teachernumber,
  sr.preferred_name,
  sr.userprincipalname AS staff_username,
  sr.is_active,
  sr.[db_name],
  sr.manager_df_employee_number,
  sr.manager_name,
  sr.manager_userprincipalname AS manager_username,
  sr.grades_taught
FROM
  current_work_assignment AS cwa
  INNER JOIN people.staff_crosswalk_static AS sr ON (
    cwa.df_employee_number = sr.df_employee_number
  )
WHERE
  cwa.rn_emp_yr = 1
