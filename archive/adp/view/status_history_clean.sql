CREATE OR ALTER VIEW
  adp.status_history_clean AS
SELECT
  sub.employee_number,
  sub.associate_id,
  sub.position_id,
  sub.position_status,
  sub.termination_reason_description,
  sub.leave_reason_description,
  sub.paid_leave_of_absence,
  sub.status_effective_date,
  COALESCE(
    sub.status_effective_end_date,
    DATEADD(
      DAY,
      -1,
      LEAD(sub.status_effective_date, 1) OVER (
        PARTITION BY
          sub.position_id
        ORDER BY
          sub.status_effective_date
      )
    )
  ) AS status_effective_end_date,
  COALESCE(
    sub.status_effective_end_date,
    DATEADD(
      DAY,
      -1,
      LEAD(sub.status_effective_date, 1) OVER (
        PARTITION BY
          sub.position_id
        ORDER BY
          sub.status_effective_date
      )
    ),
    DATEFROMPARTS(
      CASE
        WHEN DATEPART(YEAR, sub.status_effective_date) > gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
        AND DATEPART(MONTH, sub.status_effective_date) >= 7 THEN DATEPART(YEAR, sub.status_effective_date) + 1
        ELSE gabby.utilities.GLOBAL_ACADEMIC_YEAR () + 1
      END,
      6,
      30
    )
  ) AS status_effective_end_date_eoy
FROM
  (
    SELECT
      sh.associate_id,
      sh.position_id,
      sh.position_status,
      CAST(sh.status_effective_date AS DATE) AS status_effective_date,
      CAST(sh.status_effective_end_date AS DATE) AS status_effective_end_date,
      sh.termination_reason_description,
      sh.leave_reason_description,
      sh.paid_leave_of_absence,
      sr.file_number AS employee_number
    FROM
      gabby.adp.status_history AS sh
      INNER JOIN gabby.adp.employees_all AS sr ON sh.associate_id = sr.associate_id
    WHERE
      CAST(sh.status_effective_date AS DATE) < CAST(sh.status_effective_end_date AS DATE)
      OR sh.status_effective_end_date IS NULL
  ) AS sub
