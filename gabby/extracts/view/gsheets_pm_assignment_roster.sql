CREATE OR ALTER VIEW
  extracts.gsheets_pm_assignment_roster AS
WITH
  elementary_grade AS (
    SELECT
      employee_number,
      MAX(student_grade_level) AS student_grade_level
    FROM
      pm.teacher_grade_levels
    WHERE
      academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
      AND (
        student_grade_level BETWEEN 0 AND 4
      )
    GROUP BY
      employee_number
  )
  /*active staff info*/
SELECT
  s.df_employee_number,
  CONCAT(
    s.preferred_name,
    ' - ',
    s.primary_site
  ) AS preferred_name,
  s.primary_job,
  s.google_email,
  s.userprincipalname AS user_email,
  s.primary_site,
  s.legal_entity_name,
  s.manager_df_employee_number,
  s.manager_name,
  x.region,
  COALESCE(c.campus_name, s.primary_site) AS site_campus,
  m.userprincipalname AS manager_email,
  m.google_email AS manager_google,
  /*default TNTP assignments based on title/location*/
  CASE
    WHEN s.primary_site IN (
      'Room 9 - 60 Park Pl',
      'Room 10 - 121 Market St',
      'Room 11 - 1951 NW 7th Ave'
    ) THEN 'Regional Staff'
    WHEN s.primary_job IN (
      'Teacher',
      'Teacher in Residence',
      'Learning Specialist',
      'Learning Specialist Coordinator',
      'Teacher, ESL',
      'Teacher ESL'
    ) THEN 'Teacher'
    WHEN (
      s.primary_on_site_department = 'School Leadership'
    ) THEN 'School Leadership Team'
    ELSE 'Non-teaching school based staff'
  END AS tntp_assignment,
  /* default Engagement & Support Survey assignments based on title/location */
  CASE
    WHEN s.primary_job = 'Head of Schools' THEN 'Head of Schools'
    WHEN s.primary_job = 'Assistant Superintendent' THEN 'Head of Schools'
    WHEN s.primary_job IN (
      'Teacher',
      'Teacher in Residence',
      'Learning Specialist',
      'Learning Specialist Coordinator',
      'Teacher, ESL',
      'Teacher ESL'
    ) THEN 'Teacher'
    WHEN s.primary_job = 'Executive Director' THEN 'Executive Director'
    WHEN s.primary_job = 'Associate Director of School Operations' THEN 'ADSO'
    WHEN s.primary_job = 'School Operations Manager' THEN 'SOM'
    WHEN s.primary_job IN (
      'Director Campus Operations',
      'Director School Operations',
      'Director of Campus Operations',
      'Fellow School Operations Director'
    ) THEN 'DSO'
    WHEN s.primary_job = 'Managing Director of Operations' THEN 'MDO'
    WHEN s.primary_job = 'Managing Director of School Operations' THEN 'MDSO'
    WHEN s.primary_job = 'School Leader' THEN 'School Leader'
    WHEN s.primary_job IN (
      'Assistant School Leader',
      'Assistant School Leader, SPED',
      'School Leader in Residence'
    ) THEN 'AP'
    ELSE 'Other'
  END AS engagement_survey_assignment,
  CASE
    WHEN e.student_grade_level = 0 THEN 'Grade K'
    WHEN (
      e.student_grade_level BETWEEN 1 AND 4
    ) THEN CONCAT('Grade ', e.student_grade_level)
    ELSE s.primary_on_site_department
  END AS department_grade,
  /* default School Based assignments based on legal entity/location */
  CASE
    WHEN (
      s.legal_entity_name != 'KIPP TEAM and Family Schools Inc.'
      AND s.primary_site NOT IN (
        'Room 9 - 60 Park Pl',
        'Room 10 - 121 Market St',
        'Room 11 - 1951 NW 7th Ave'
      )
    ) THEN 'school-based'
  END AS school_based,
  CASE
    WHEN s.primary_job IN (
      'Head of Schools',
      'School Leader',
      'School Leader in Residence',
      'Assistant School Leader',
      'Assistant School Leader, SPED',
      'Managing Director of School Operations',
      'Managing Director of Operations',
      'Managing Director of Growth',
      'Director School Operations',
      'Director Campus Operations'
    ) THEN 'Leadership'
    WHEN s.primary_job = 'Teacher in Residence' THEN 'Teacher Development'
  END AS feedback_group
FROM
  people.staff_crosswalk_static AS m
  LEFT JOIN people.staff_crosswalk_static AS s ON (
    m.df_employee_number = s.manager_df_employee_number
  )
  LEFT JOIN elementary_grade AS e ON (
    s.df_employee_number = e.employee_number
  )
  LEFT JOIN people.school_crosswalk AS x ON (s.primary_site = x.site_name)
  LEFT JOIN people.campus_crosswalk AS c ON (s.primary_site = c.site_name)
WHERE
  s.[status] != 'TERMINATED'
  AND s.primary_job != 'Intern'
  AND s.primary_job NOT LIKE '%Temp%'
