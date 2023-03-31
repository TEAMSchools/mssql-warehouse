CREATE OR ALTER VIEW
  people.manager_history AS
WITH
  manager_union AS (
    /* ADP */
    SELECT
      mh.associate_id,
      mh.position_id,
      mh.file_number,
      mh.reports_to_associate_id,
      CASE
        WHEN CAST(
          mh.reports_to_effective_date AS DATE
        ) > '2021-01-01' THEN CAST(
          mh.reports_to_effective_date AS DATE
        )
        ELSE '2021-01-01'
      END AS reports_to_effective_date,
      CAST(
        mh.reports_to_effective_end_date AS DATE
      ) AS reports_to_effective_end_date,
      sre.employee_number,
      srm.employee_number AS reports_to_employee_number,
      'ADP' AS source_system
    FROM
      adp.manager_history AS mh
      INNER JOIN people.stg_employee_numbers AS sre ON (
        mh.associate_id = sre.associate_id
        AND sre.is_active = 1
      )
      INNER JOIN people.stg_employee_numbers AS srm ON (
        mh.reports_to_associate_id = srm.associate_id
        AND srm.is_active = 1
      )
    WHERE
      '2021-01-01' BETWEEN CAST(
        mh.reports_to_effective_date AS DATE
      ) AND COALESCE(
        CAST(
          mh.reports_to_effective_end_date AS DATE
        ),
        CURRENT_TIMESTAMP
      )
      OR CAST(
        mh.reports_to_effective_date AS DATE
      ) > '2021-01-01'
    UNION ALL
    /* DF */
    SELECT
      sre.associate_id AS associate_id,
      dm.position_id,
      dm.employee_reference_code AS file_number,
      srm.associate_id AS reports_to_associate_id,
      dm.manager_effective_start AS reports_to_effective_date,
      CASE
        WHEN dm.manager_effective_end < '2020-12-31' THEN dm.manager_effective_end
        ELSE '2020-12-31'
      END AS reports_to_effective_end_date,
      dm.employee_reference_code AS employee_number,
      dm.manager_employee_number AS reports_to_employee_number,
      'DF' AS source_system
    FROM
      dayforce.employee_manager_clean AS dm
      INNER JOIN people.stg_employee_numbers AS sre ON (
        dm.employee_reference_code = sre.employee_number
        AND sre.is_active = 1
      )
      INNER JOIN people.stg_employee_numbers AS srm ON (
        dm.manager_employee_number = srm.employee_number
        AND srm.is_active = 1
      )
    WHERE
      CAST(
        dm.manager_effective_start AS DATE
      ) <= '2020-12-31'
  )
SELECT
  employee_number,
  associate_id,
  position_id,
  file_number,
  reports_to_associate_id,
  reports_to_employee_number,
  reports_to_effective_date,
  source_system,
  COALESCE(
    reports_to_effective_end_date,
    DATEADD(
      DAY,
      -1,
      LEAD(reports_to_effective_date, 1) OVER (
        PARTITION BY
          position_id
        ORDER BY
          reports_to_effective_date
      )
    )
  ) AS reports_to_effective_end_date,
  COALESCE(
    reports_to_effective_end_date,
    DATEADD(
      DAY,
      -1,
      LEAD(reports_to_effective_date, 1) OVER (
        PARTITION BY
          position_id
        ORDER BY
          reports_to_effective_date
      )
    ),
    DATEFROMPARTS(
      CASE
        WHEN (
          (
            DATEPART(YEAR, reports_to_effective_date)
          ) > utilities.GLOBAL_ACADEMIC_YEAR ()
          AND DATEPART(MONTH, reports_to_effective_date) >= 7
        ) THEN DATEPART(YEAR, reports_to_effective_date) + 1
        WHEN (
          (
            DATEPART(YEAR, CURRENT_TIMESTAMP)
          ) = utilities.GLOBAL_ACADEMIC_YEAR () + 1
          AND DATEPART(MONTH, CURRENT_TIMESTAMP) >= 7
        ) THEN utilities.GLOBAL_ACADEMIC_YEAR () + 2
        ELSE utilities.GLOBAL_ACADEMIC_YEAR () + 1
      END,
      6,
      30
    )
  ) AS reports_to_effective_end_date_eoy
FROM
  manager_union
