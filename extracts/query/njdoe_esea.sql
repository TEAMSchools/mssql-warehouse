WITH
  scaffold AS (
    SELECT
      t.df_employee_number,
      t.preferred_lastfirst,
      t.legal_entity_name,
      t.location,
      t.job_title,
      t.email_address,
      t.academic_year,
      YEAR(t.date_value) AS calendar_year,
      DATENAME(MONTH, t.date_value) AS month_text,
      MONTH(t.date_value) AS month_num,
      SUM(hours_worked) AS month_hours_worked,
      COUNT(t.date_value) * 9.5 AS month_possible_hours
    FROM
      gabby.tableau.staff_tracker AS t
    GROUP BY
      t.df_employee_number,
      t.preferred_lastfirst,
      t.legal_entity_name,
      t.location,
      t.job_title,
      t.email_address,
      t.academic_year,
      YEAR(t.date_value),
      MONTH(t.date_value),
      DATENAME(MONTH, t.date_value)
  ),
  days_table AS (
    SELECT
      p.df_employee_number,
      p.academic_year,
      p.month_num,
      p.month_max_days,
      COALESCE([1], 0) AS day_1,
      COALESCE([2], 0) AS day_2,
      COALESCE([3], 0) AS day_3,
      COALESCE([4], 0) AS day_4,
      COALESCE([5], 0) AS day_5,
      COALESCE([6], 0) AS day_6,
      COALESCE([7], 0) AS day_7,
      COALESCE([8], 0) AS day_8,
      COALESCE([9], 0) AS day_9,
      COALESCE([10], 0) AS day_10,
      COALESCE([11], 0) AS day_11,
      COALESCE([12], 0) AS day_12,
      COALESCE([13], 0) AS day_13,
      COALESCE([14], 0) AS day_14,
      COALESCE([15], 0) AS day_15,
      COALESCE([16], 0) AS day_16,
      COALESCE([17], 0) AS day_17,
      COALESCE([18], 0) AS day_18,
      COALESCE([19], 0) AS day_19,
      COALESCE([20], 0) AS day_20,
      COALESCE([21], 0) AS day_21,
      COALESCE([22], 0) AS day_22,
      COALESCE([23], 0) AS day_23,
      COALESCE([24], 0) AS day_24,
      COALESCE([25], 0) AS day_25,
      COALESCE([26], 0) AS day_26,
      COALESCE([27], 0) AS day_27,
      COALESCE([28], 0) AS day_28,
      CASE
        WHEN month_max_days >= 29 THEN COALESCE([29], 0)
      END AS day_29,
      CASE
        WHEN month_max_days >= 30 THEN COALESCE([30], 0)
      END AS day_30,
      CASE
        WHEN month_max_days = 31 THEN COALESCE([31], 0)
      END AS day_31
    FROM
      (
        SELECT
          df_employee_number,
          academic_year,
          hours_worked,
          MONTH(date_value) AS month_num,
          DAY(date_value) AS day_num,
          DAY(EOMONTH(date_value)) AS month_max_days
        FROM
          gabby.tableau.staff_tracker
      ) sub PIVOT (
        SUM(hours_worked) FOR day_num IN (
          [1],
          [2],
          [3],
          [4],
          [5],
          [6],
          [7],
          [8],
          [9],
          [10],
          [11],
          [12],
          [13],
          [14],
          [15],
          [16],
          [17],
          [18],
          [19],
          [20],
          [21],
          [22],
          [23],
          [24],
          [25],
          [26],
          [27],
          [28],
          [29],
          [30],
          [31]
        )
      ) p
  )
SELECT
  s.df_employee_number,
  s.preferred_lastfirst,
  s.legal_entity_name,
  s.location,
  s.job_title,
  s.email_address,
  s.academic_year,
  s.month_num,
  s.month_text,
  s.calendar_year,
  s.month_hours_worked,
  s.month_possible_hours,
  s.month_possible_hours - s.month_hours_worked AS month_hours_not_worked,
  CAST(
    ROUND(
      (
        s.month_hours_worked / s.month_possible_hours
      ) * 100,
      0
    ) AS INT
  ) AS month_percent_worked,
  CAST(
    ROUND(
      (
        (
          s.month_possible_hours - s.month_hours_worked
        ) / s.month_possible_hours
      ) * 100,
      0
    ) AS INT
  ) AS month_percent_not_worked,
  d.month_max_days,
  d.day_1,
  d.day_2,
  d.day_3,
  d.day_4,
  d.day_5,
  d.day_6,
  d.day_7,
  d.day_8,
  d.day_9,
  d.day_10,
  d.day_11,
  d.day_12,
  d.day_13,
  d.day_14,
  d.day_15,
  d.day_16,
  d.day_17,
  d.day_18,
  d.day_19,
  d.day_20,
  d.day_21,
  d.day_22,
  d.day_23,
  d.day_24,
  d.day_25,
  d.day_26,
  d.day_27,
  d.day_28,
  d.day_29,
  d.day_30,
  d.day_31
FROM
  scaffold AS s
  LEFT JOIN days_table AS d ON s.df_employee_number = d.df_employee_number
  AND s.academic_year = d.academic_year
  AND s.month_num = d.month_num
