CREATE OR ALTER VIEW
  people.staff_attendance_clean AS
SELECT
  a.df_number,
  a.staff_name,
  a.attendance_location,
  a.staff_info_string,
  a.submitted_by,
  a.attendance_date,
  a.attendance_status,
  a.sick_day,
  a.personal_day,
  a.late_tardy,
  a.left_early,
  a.absent_other,
  a.at_work,
  a.approved,
  a.additional_notes,
  a.submitted_on,
  utilities.DATE_TO_SY (a.attendance_date) AS academic_year,
  c.manager_name,
  c.primary_site AS current_location,
  c.legal_entity_name AS current_legal_entity,
  LOWER(c.manager_samaccountname) AS manager_samaccountname,
  LOWER(c.samaccountname) AS samaccountname,
  ROW_NUMBER() OVER (
    PARTITION BY
      a.df_number,
      a.attendance_date
    ORDER BY
      CAST(a.submitted_on AS DATETIME) DESC
  ) AS rn_curr
FROM
  (
    SELECT
      SUBSTRING(
        staff_member,
        CHARINDEX('(', staff_member) + 1,
        6
      ) AS df_number,
      LEFT(
        staff_member,
        CHARINDEX('(', staff_member) - 2
      ) AS staff_name,
      RIGHT(
        staff_member,
        LEN(staff_member) - CHARINDEX('-', staff_member)
      ) AS attendance_location,
      staff_member AS staff_info_string,
      submitter_apps_account AS submitted_by,
      attendance_status,
      additional_notes,
      CAST(attendance_date AS DATE) AS attendance_date,
      CAST([timestamp] AS DATETIME) AS submitted_on,
      CASE
        WHEN attendance_status LIKE '%Sick Day%' THEN 1
        ELSE 0
      END AS sick_day,
      CASE
        WHEN attendance_status LIKE '%Personal Day%' THEN 1
        ELSE 0
      END AS personal_day,
      CASE
        WHEN attendance_status LIKE '%Late/Tardy%' THEN 1
        ELSE 0
      END AS late_tardy,
      CASE
        WHEN attendance_status LIKE '%Left Early%' THEN 1
        ELSE 0
      END AS left_early,
      CASE
        WHEN attendance_status LIKE '%Other%' THEN 1
        ELSE 0
      END AS absent_other,
      CASE
        WHEN attendance_status LIKE '%Override%' THEN 1
        ELSE 0
      END AS at_work,
      CASE
        WHEN attendance_status LIKE '%Unapproved%' THEN 0
        ELSE 1
      END AS approved
    FROM
      people.staff_attendance
  ) AS a
  INNER JOIN people.staff_crosswalk_static AS c ON (
    a.df_number = c.df_employee_number
  )
