CREATE OR ALTER VIEW
  people.salary_history AS
WITH
  salary_union AS (
    /* ADP */
    SELECT
      sh.associate_id,
      sh.position_id,
      sh.file_number,
      CASE
        WHEN CAST(
          sh.regular_pay_effective_date AS DATE
        ) > '2021-01-01' THEN CAST(
          sh.regular_pay_effective_date AS DATE
        )
        ELSE '2021-01-01'
      END AS regular_pay_effective_date,
      CAST(
        sh.regular_pay_effective_end_date AS DATE
      ) AS regular_pay_effective_end_date,
      CAST(sh.annual_salary AS MONEY) AS annual_salary,
      CAST(
        sh.regular_pay_rate_amount AS MONEY
      ) AS regular_pay_rate_amount,
      sh.compensation_change_reason_description,
      sr.employee_number,
      'ADP' AS source_system
    FROM
      adp.salary_history AS sh
      INNER JOIN people.employee_numbers AS sr ON (
        sh.associate_id = sr.associate_id
        AND sr.is_active = 1
      )
    WHERE
      (
        CAST(
          sh.regular_pay_effective_date AS DATE
        ) < CAST(
          sh.regular_pay_effective_end_date AS DATE
        )
        OR sh.regular_pay_effective_end_date IS NULL
      )
      AND (
        (
          '2021-01-01' BETWEEN CAST(
            sh.regular_pay_effective_date AS DATE
          ) AND COALESCE(
            CAST(
              sh.regular_pay_effective_end_date AS DATE
            ),
            CURRENT_TIMESTAMP
          )
        )
        OR CAST(
          sh.regular_pay_effective_date AS DATE
        ) > '2021-01-01'
      )
    UNION ALL
    /* DF */
    SELECT
      sr.associate_id,
      ds.position_id,
      ds.number AS file_number,
      ds.effective_start AS regular_pay_effective_date,
      CASE
        WHEN ds.effective_end < '2020-12-31' THEN ds.effective_end
        ELSE '2020-12-31'
      END AS regular_pay_effective_end_date,
      ds.base_salary AS annual_salary,
      NULL AS regular_pay_rate_amount,
      ds.status_reason_description AS compensation_change_reason_description,
      ds.number AS employee_number,
      'DF' AS source_system
    FROM
      dayforce.employee_status_clean AS ds
      INNER JOIN people.employee_numbers AS sr ON (
        ds.number = sr.employee_number
        AND sr.is_active = 1
      )
    WHERE
      CAST(ds.effective_start AS DATE) <= '2020-12-31'
  )
SELECT
  employee_number,
  associate_id,
  position_id,
  file_number,
  annual_salary,
  regular_pay_rate_amount,
  compensation_change_reason_description,
  regular_pay_effective_date,
  source_system,
  COALESCE(
    regular_pay_effective_end_date,
    DATEADD(
      DAY,
      -1,
      LEAD(regular_pay_effective_date, 1) OVER (
        PARTITION BY
          position_id
        ORDER BY
          regular_pay_effective_date
      )
    )
  ) AS regular_pay_effective_end_date,
  COALESCE(
    regular_pay_effective_end_date,
    DATEADD(
      DAY,
      -1,
      LEAD(regular_pay_effective_date, 1) OVER (
        PARTITION BY
          position_id
        ORDER BY
          regular_pay_effective_date
      )
    ),
    DATEFROMPARTS(
      CASE
        WHEN (
          DATEPART(YEAR, regular_pay_effective_date) > (
            utilities.GLOBAL_ACADEMIC_YEAR ()
          )
          AND DATEPART(
            MONTH,
            regular_pay_effective_date
          ) >= 7
        ) THEN DATEPART(YEAR, regular_pay_effective_date) + 1
        WHEN (
          DATEPART(YEAR, CURRENT_TIMESTAMP) = (
            utilities.GLOBAL_ACADEMIC_YEAR () + 1
          )
          AND DATEPART(MONTH, CURRENT_TIMESTAMP) >= 7
        ) THEN utilities.GLOBAL_ACADEMIC_YEAR () + 2
        ELSE utilities.GLOBAL_ACADEMIC_YEAR () + 1
      END,
      6,
      30
    )
  ) AS regular_pay_effective_end_date_eoy
FROM
  salary_union
WHERE
  annual_salary > 0
