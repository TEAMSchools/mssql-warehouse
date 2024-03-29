CREATE OR ALTER VIEW
  tableau.staff_tracker AS
WITH
  emp_att AS (
    SELECT
      p.employee_number,
      p.pay_date,
      [absent],
      [late],
      [early out] AS early_out,
      [partial day] AS partial_day
    FROM
      (
        SELECT
          employee_number,
          pay_date,
          excused_status,
          absence_type
        FROM
          gabby.dayforce.employee_attendance
      ) AS sub PIVOT (
        MAX(excused_status) FOR absence_type IN (
          [absent],
          [late],
          [early out],
          [partial day]
        )
      ) AS p
  ),
  tafw AS (
    SELECT
      sub.df_employee_number,
      CAST(sub.tafw_start_date AS DATE) AS tafw_start_date,
      CAST(sub.tafw_end_date AS DATE) AS tafw_end_date,
      CASE
        WHEN DATEDIFF(
          HOUR,
          sub.tafw_start_date,
          sub.tafw_end_date
        ) > 9 THEN 9.5
        ELSE DATEDIFF(
          HOUR,
          sub.tafw_start_date,
          sub.tafw_end_date
        )
      END AS tafw_hours
    FROM
      (
        SELECT
          t.reference_code AS df_employee_number,
          DATEADD(
            MINUTE,
            DATEPART(TZOFFSET, t.start_date_time),
            CAST(t.start_date_time AS DATETIME2)
          ) AS tafw_start_date,
          DATEADD(
            MINUTE,
            DATEPART(TZOFFSET, t.end_date_time),
            CAST(t.end_date_time AS DATETIME2)
          ) AS tafw_end_date
        FROM
          gabby.dayforce.tafw_requests AS t
        WHERE
          t.tafw_status IN (
            'Approved',
            'Pending',
            'Cancellation Pending'
          )
      ) AS sub
  ),
  leave AS (
    SELECT
      s.number AS df_employee_number,
      s.[status],
      CAST(s.effective_start AS DATE) AS effective_start,
      COALESCE(
        CAST(s.effective_end AS DATE),
        CAST(CURRENT_TIMESTAMP AS DATE)
      ) AS effective_end
    FROM
      gabby.dayforce.employee_status AS s
    WHERE
      s.[status] IN (
        'Administrative Leave',
        'Medical Leave of Absence',
        'Personal Leave of Absence'
      )
  )
SELECT
  df.df_employee_number,
  df.preferred_name AS preferred_lastfirst,
  df.legal_entity_name,
  df.primary_site_school_level,
  df.primary_site_schoolid AS schoolid,
  df.primary_site AS [location],
  df.primary_job AS job_title,
  df.manager_name AS manager,
  df.[status] AS position_status,
  df.position_effective_from_date AS academic_year_start_date,
  COALESCE(
    df.termination_date,
    CAST(CURRENT_TIMESTAMP AS DATE)
  ) AS academic_year_end_date,
  df.userprincipalname AS email_address,
  LOWER(df.samaccountname) AS staff_username_short,
  LOWER(df.manager_samaccountname) AS mgr_username_short,
  was.position_status AS cal_position_status,
  was.business_unit AS cal_legal_entity,
  was.location AS cal_location,
  was.home_department AS cal_department_name,
  was.job_title AS cal_job_title,
  cal.date_value,
  CASE
    WHEN was.position_status IN (
      'Terminated',
      'Pre-Start',
      'Administrative Leave',
      'Medical Leave of Absence',
      'Personal Leave of Absence'
    ) THEN 0
    ELSE cal.insession
  END AS insession,
  gabby.utilities.DATE_TO_SY (cal.date_value) AS academic_year,
  CAST(dt.alt_name AS VARCHAR(5)) AS term,
  COALESCE(
    CASE
      WHEN t.tafw_hours = 9.5 THEN 'PTO'
      WHEN a.sick_day = 1 THEN 'SICK'
      WHEN a.personal_day = 1 THEN 'PERSONAL'
      WHEN a.absent_other = 1 THEN 'OTHER'
      ELSE NULL
    END,
    pt.[absent]
  ) AS [absent],
  COALESCE(
    CASE
      WHEN a.late_tardy = 1
      AND a.approved = 1 THEN 'L-In OK'
      WHEN a.late_tardy = 1
      AND a.approved = 0 THEN 'L-In'
      ELSE NULL
    END,
    pt.late
  ) AS late,
  COALESCE(
    CASE
      WHEN a.left_early = 1
      AND a.approved = 1 THEN 'E-Out OK'
      WHEN a.left_early = 1
      AND a.approved = 0 THEN 'E-Out'
      ELSE NULL
    END,
    pt.early_out
  ) AS early_out,
  COALESCE(
    CASE
      WHEN t.tafw_hours < 9.5 THEN 'PTO'
      ELSE NULL
    END,
    pt.partial_day
  ) AS partial_day,
  a.attendance_status AS gsheet_status,
  a.submitted_by AS gsheets_submitted_by,
  a.additional_notes AS gsheets_additional_notes,
  CASE
    WHEN a.attendance_status = 'Sick Day - COVID Related' THEN 1
    ELSE 0
  END AS covid_related,
  CASE
    WHEN (
      a.approved = 1
      OR t.tafw_hours > 0
    ) THEN 1
    ELSE NULL
  END AS approved,
  CASE
    WHEN was.position_status IN ('Terminated', 'Pre-Start') THEN was.position_status
    ELSE COALESCE(
      CASE
        WHEN t.tafw_hours = 9.5 THEN 'PTO'
        WHEN t.tafw_hours < 9.5 THEN 'PARTIAL'
        ELSE NULL
      END,
      a.attendance_status,
      pt.[absent],
      CASE
        WHEN l.[status] = '' THEN NULL
        ELSE l.[status]
      END,
      CASE
        WHEN cal.[type] = '' THEN NULL
        ELSE cal.[type]
      END,
      'IN'
    )
  END
COLLATE Latin1_General_BIN AS day_status,
CASE
  WHEN cal.[type] IN ('HOL', 'VAC') THEN 0
  WHEN l.[status] IS NOT NULL THEN 0
  WHEN was.position_status IN ('Terminated', 'Pre-Start') THEN 0
  ELSE 9.5 - ISNULL(t.tafw_hours, 0)
END AS hours_worked
FROM
  gabby.people.staff_crosswalk_static AS df
  INNER JOIN gabby.powerschool.calendar_day AS cal ON df.primary_site_schoolid = cal.schoolid
  AND df.[db_name] = cal.[db_name]
  AND (
    cal.insession = 1
    OR cal.[type] = 'PD'
  )
  AND (
    cal.date_value BETWEEN DATEFROMPARTS(
      gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1,
      7,
      1
    ) AND CURRENT_TIMESTAMP
  )
  INNER JOIN gabby.reporting.reporting_terms AS dt ON cal.schoolid = dt.schoolid
  AND (
    cal.date_value BETWEEN dt.[start_date] AND dt.end_date
  )
  AND dt.identifier = 'RT'
  AND dt._fivetran_deleted = 0
  INNER JOIN gabby.people.employment_history AS was ON df.df_employee_number = was.employee_number
  AND (
    cal.date_value BETWEEN was.effective_start_date AND was.effective_end_date
  )
  LEFT JOIN emp_att AS pt ON df.df_employee_number = pt.employee_number
  AND cal.date_value = pt.pay_date
  LEFT JOIN tafw AS t ON df.df_employee_number = t.df_employee_number
  AND (
    cal.date_value BETWEEN t.tafw_start_date AND t.tafw_end_date
  )
  LEFT JOIN gabby.people.staff_attendance_clean_static AS a ON df.df_employee_number = a.df_number
  AND cal.date_value = a.attendance_date
  AND a.rn_curr = 1
  LEFT JOIN leave AS l ON df.df_employee_number = l.df_employee_number
  AND (
    cal.date_value BETWEEN l.effective_start AND l.effective_end
  )
WHERE
  COALESCE(
    df.termination_date,
    CURRENT_TIMESTAMP
  ) >= DATEFROMPARTS(
    gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
    7,
    1
  )
