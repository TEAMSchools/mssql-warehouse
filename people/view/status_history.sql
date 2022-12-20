CREATE OR ALTER VIEW
  people.status_history AS
WITH
  status_union AS (
    /* ADP */
    SELECT
      sh.associate_id,
      sh.position_id,
      sh.file_number,
      sh.position_status,
      CASE
        WHEN CAST(status_effective_date AS DATE) >= '2021-01-01' THEN CAST(status_effective_date AS DATE)
        ELSE '2021-01-01'
      END AS status_effective_date,
      CAST(
        sh.status_effective_end_date AS DATE
      ) AS status_effective_end_date,
      sh.termination_reason_description,
      sh.leave_reason_description,
      sh.paid_leave_of_absence,
      sr.employee_number,
      'ADP' AS source_system
    FROM
      gabby.adp.status_history AS sh
      INNER JOIN gabby.people.employee_numbers AS sr ON sh.associate_id = sr.associate_id
      AND sr.is_active = 1
    WHERE
      CAST(sh.status_effective_date AS DATE) >= '2021-01-01'
      OR COALESCE(
        CAST(
          sh.status_effective_end_date AS DATE
        ),
        CURRENT_TIMESTAMP
      ) >= '2021-01-01'
    UNION ALL
    /* DF */
    SELECT
      sr.associate_id,
      ds.position_id,
      ds.number AS file_number,
      ds.[status] AS position_status,
      ds.effective_start AS status_effective_date,
      CASE
        WHEN ds.effective_end <= '2020-12-31' THEN ds.effective_end
        ELSE '2020-12-31'
      END AS status_effective_end_date,
      CASE
        WHEN ds.[status] = 'Terminated' THEN ds.status_reason_description
      END AS termination_reason_description,
      CASE
        WHEN ds.[status] IN (
          'Administrative Leave',
          'Medical Leave of Absence',
          'Personal Leave of Absence'
        ) THEN ds.status_reason_description
      END AS leave_reason_description,
      NULL AS paid_leave_of_absence,
      ds.number AS employee_number,
      'DF' AS source_system
    FROM
      gabby.dayforce.employee_status_clean AS ds
      INNER JOIN gabby.people.employee_numbers AS sr ON ds.number = sr.employee_number
      AND sr.is_active = 1
    WHERE
      ds.effective_start <= '2020-12-31'
  ),
  status_dates AS (
    SELECT
      employee_number,
      associate_id,
      position_id,
      file_number,
      position_status,
      leave_reason_description,
      paid_leave_of_absence,
      source_system,
      CAST(status_effective_date AS DATE) AS status_effective_date,
      CASE
        WHEN termination_reason_description = 'Importcreated Action' THEN LAG(
          termination_reason_description,
          1
        ) OVER (
          PARTITION BY
            associate_id
          ORDER BY
            status_effective_date
        )
        ELSE termination_reason_description
      END AS termination_reason_description /* cover ADP Import status with terminal DF reason */,
      COALESCE(
        status_effective_end_date,
        DATEADD(
          DAY,
          -1,
          LEAD(status_effective_date, 1) OVER (
            PARTITION BY
              position_id
            ORDER BY
              status_effective_date
          )
        )
      ) AS status_effective_end_date
    FROM
      status_union
  ),
  status_clean AS (
    SELECT
      employee_number,
      associate_id,
      position_id,
      file_number,
      status_effective_date,
      status_effective_end_date,
      position_status,
      termination_reason_description,
      paid_leave_of_absence,
      leave_reason_description,
      source_system,
      position_status_prev,
      COALESCE(
        CASE
          WHEN ROW_NUMBER() OVER (
            PARTITION BY
              position_id
            ORDER BY
              status_effective_date DESC
          ) = 1 THEN eoy_date
        END,
        CAST(
          status_effective_end_date AS DATE
        ),
        DATEADD(
          DAY,
          -1,
          LEAD(status_effective_date, 1) OVER (
            PARTITION BY
              position_id
            ORDER BY
              status_effective_date
          )
        ),
        eoy_date
      ) AS status_effective_end_date_eoy
    FROM
      (
        SELECT
          employee_number,
          associate_id,
          position_id,
          file_number,
          status_effective_date,
          status_effective_end_date,
          position_status,
          termination_reason_description,
          paid_leave_of_absence,
          leave_reason_description,
          source_system,
          DATEFROMPARTS(
            CASE
              WHEN DATEPART(YEAR, status_effective_date) > gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
              AND DATEPART(MONTH, status_effective_date) >= 7 THEN DATEPART(YEAR, status_effective_date) + 1
              WHEN DATEPART(YEAR, CURRENT_TIMESTAMP) = gabby.utilities.GLOBAL_ACADEMIC_YEAR () + 1
              AND DATEPART(MONTH, CURRENT_TIMESTAMP) >= 7 THEN gabby.utilities.GLOBAL_ACADEMIC_YEAR () + 2
              ELSE gabby.utilities.GLOBAL_ACADEMIC_YEAR () + 1
            END,
            6,
            30
          ) AS eoy_date,
          LAG(position_status, 1) OVER (
            PARTITION BY
              position_id
            ORDER BY
              status_effective_date
          ) AS position_status_prev
        FROM
          status_dates
      ) AS sub
    WHERE
      CONCAT(
        position_status,
        position_status_prev
      ) != 'TerminatedTerminated'
  )
SELECT
  employee_number,
  associate_id,
  position_id,
  file_number,
  status_effective_date,
  status_effective_end_date,
  status_effective_end_date_eoy,
  position_status,
  position_status_prev,
  termination_reason_description,
  paid_leave_of_absence,
  leave_reason_description,
  source_system,
  MIN(
    CASE
      WHEN (
        CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN status_effective_date AND status_effective_end_date_eoy
      ) THEN position_status
    END
  ) OVER (
    PARTITION BY
      associate_id
  ) AS position_status_cur
FROM
  status_clean
