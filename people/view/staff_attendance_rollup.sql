CREATE OR ALTER VIEW
  people.staff_attendance_rollup AS
WITH
  attendance_pivot AS (
    SELECT
      df_number,
      academic_year,
      SUM(
        CASE
          WHEN approved = 1 THEN sick_day
          ELSE 0
        END
      ) + SUM(
        CASE
          WHEN approved = 1 THEN personal_day
          ELSE 0
        END
      ) + SUM(
        CASE
          WHEN approved = 1 THEN absent_other
          ELSE 0
        END
      ) AS absenses_approved,
      SUM(
        CASE
          WHEN approved = 0 THEN sick_day
          ELSE 0
        END
      ) + SUM(
        CASE
          WHEN approved = 0 THEN personal_day
          ELSE 0
        END
      ) + SUM(
        CASE
          WHEN approved = 0 THEN absent_other
          ELSE 0
        END
      ) AS absenses_unapproved,
      SUM(
        CASE
          WHEN approved = 1 THEN late_tardy
          ELSE 0
        END
      ) AS late_tardy_approved,
      SUM(
        CASE
          WHEN approved = 0 THEN late_tardy
          ELSE 0
        END
      ) AS late_tardy_unapproved,
      SUM(
        CASE
          WHEN approved = 1 THEN left_early
          ELSE 0
        END
      ) AS left_early_approved,
      SUM(
        CASE
          WHEN approved = 0 THEN left_early
          ELSE 0
        END
      ) AS left_early_unapproved
    FROM
      gabby.people.staff_attendance_clean_static
    WHERE
      rn_curr = 1
    GROUP BY
      df_number,
      academic_year
  )
SELECT
  r.df_employee_number,
  r.adp_associate_id,
  r.first_name,
  r.last_name,
  r.gender,
  r.primary_ethnicity,
  r.original_hire_date,
  r.[status],
  r.legal_entity_name,
  r.primary_site,
  r.primary_on_site_department,
  r.primary_job,
  y.n AS academic_year,
  COALESCE(a.absenses_approved, 0) AS absenses_approved,
  COALESCE(a.absenses_unapproved, 0) AS absenses_unapproved,
  COALESCE(a.late_tardy_approved, 0) AS late_tardy_approved,
  COALESCE(a.late_tardy_unapproved, 0) AS late_tardy_unapproved,
  COALESCE(a.left_early_approved, 0) AS left_early_approved,
  COALESCE(a.left_early_unapproved, 0) AS left_early_unapproved
FROM
  gabby.people.staff_crosswalk_static AS r
  LEFT JOIN gabby.utilities.row_generator_smallint AS y ON (
    gabby.utilities.DATE_TO_SY (r.original_hire_date) < y.n
    AND (
      y.n BETWEEN 2020 AND (
        gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
      )
    )
  )
  LEFT JOIN attendance_pivot AS a ON (
    r.df_employee_number = a.df_number
    AND y.n = a.academic_year
  )
