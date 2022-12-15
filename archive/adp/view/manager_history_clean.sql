USE gabby GO
CREATE OR ALTER VIEW
  adp.manager_history_clean AS
SELECT
  sub.employee_number,
  sub.associate_id,
  sub.position_id,
  sub.reports_to_associate_id,
  sub.reports_to_effective_date,
  COALESCE(
    sub.reports_to_effective_end_date,
    DATEADD(
      DAY,
      -1,
      LEAD(sub.reports_to_effective_date, 1) OVER (
        PARTITION BY
          sub.associate_id
        ORDER BY
          sub.reports_to_effective_date
      )
    )
  ) AS reports_to_effective_end_date,
  COALESCE(
    sub.reports_to_effective_end_date,
    DATEADD(
      DAY,
      -1,
      LEAD(sub.reports_to_effective_date, 1) OVER (
        PARTITION BY
          sub.associate_id
        ORDER BY
          sub.reports_to_effective_date
      )
    ),
    DATEFROMPARTS(
      CASE
        WHEN DATEPART(YEAR, sub.reports_to_effective_date) > gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
        AND DATEPART(MONTH, sub.reports_to_effective_date) >= 7 THEN DATEPART(YEAR, sub.reports_to_effective_date) + 1
        ELSE gabby.utilities.GLOBAL_ACADEMIC_YEAR () + 1
      END,
      6,
      30
    )
  ) AS reports_to_effective_end_date_eoy
FROM
  (
    SELECT
      mh.associate_id,
      mh.position_id,
      mh.reports_to_associate_id,
      CAST(mh.reports_to_effective_date AS DATE) AS reports_to_effective_date,
      CAST(mh.reports_to_effective_end_date AS DATE) AS reports_to_effective_end_date,
      sr.file_number AS employee_number
    FROM
      gabby.adp.manager_history mh
      JOIN gabby.adp.employees_all sr ON mh.associate_id = sr.associate_id
    WHERE
      mh.reports_to_associate_id IS NOT NULL
  ) sub
