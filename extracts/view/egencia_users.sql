CREATE OR ALTER VIEW
  extracts.egencia_users AS
SELECT
  sub.[Email],
  sub.[Single Sign On ID],
  sub.employee_number AS [Employee ID],
  sub.[First name],
  sub.[Last name],
  sub.[location],
  sub.home_department,
  sub.job_title,
  CONCAT(sub.employee_number, '@kippnj.org') AS [Username],
  CASE
    WHEN sub.position_status = 'Terminated' THEN 'Disabled'
    ELSE 'Active'
  END AS [Status],
  CASE
    WHEN sub.employee_number IN (100219, 100412, 100566, 102298) THEN 'Travel Manager'
    ELSE 'Traveler'
  END AS [Role],
  /* cascading match on location/dept/job */
  COALESCE(
    tg.egencia_traveler_group,
    tg2.egencia_traveler_group,
    tg3.egencia_traveler_group,
    'General Traveler Group'
  ) AS [Traveler Group]
FROM
  (
    SELECT
      scw.employee_number,
      /* legal name */
      scw.first_name AS [First name],
      /* legal name */
      scw.last_name AS [Last name],
      scw.position_status,
      scw.termination_date,
      scw.[location],
      scw.home_department,
      scw.job_title,
      ad.mail AS [Email],
      ad.userprincipalname AS [Single Sign On ID],
      COALESCE(scw.rehire_date, scw.original_hire_date) AS hire_date
    FROM
      gabby.people.staff_roster AS scw
      INNER JOIN gabby.adsi.user_attributes_static AS ad ON scw.employee_number = ad.employeenumber /* trunk-ignore(sqlfluff/L016) */
      AND ISNUMERIC(ad.employeenumber) = 1
    WHERE
      (
        scw.worker_category NOT IN ('Intern', 'Part Time')
        OR scw.worker_category IS NULL
      )
      AND COALESCE(scw.termination_date, CURRENT_TIMESTAMP) >= DATEFROMPARTS(
        gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
        7,
        1
      )
  ) AS sub
  LEFT JOIN gabby.egencia.traveler_groups AS tg ON sub.[location] = tg.[location]
  AND sub.home_department = tg.home_department
  AND sub.job_title = tg.job_title
  LEFT JOIN gabby.egencia.traveler_groups AS tg2 ON sub.[location] = tg2.[location]
  AND sub.home_department = tg2.home_department
  AND tg2.job_title = 'Default'
  LEFT JOIN gabby.egencia.traveler_groups AS tg3 ON sub.[location] = tg3.[location]
  AND tg3.home_department = 'Default'
  AND tg3.job_title = 'Default'
