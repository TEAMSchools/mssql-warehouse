CREATE OR ALTER VIEW
  people.work_assignment_history AS
WITH
  work_assignment_union AS (
    /* ADP */
    SELECT
      wah.associate_id,
      wah.position_id,
      wah.file_number,
      wah.business_unit_code,
      wah.business_unit_description,
      wah.home_department_description,
      wah.location_description,
      wah.job_title_code,
      wah.job_title_description,
      wah.job_change_reason_code,
      wah.job_change_reason_description,
      wah.primary_position,
      CASE
        WHEN CAST(
          wah.position_effective_date AS DATE
        ) > '2021-01-01' THEN CAST(
          wah.position_effective_date AS DATE
        )
        ELSE '2021-01-01'
      END AS position_effective_date,
      CAST(
        wah.position_effective_end_date AS DATE
      ) AS position_effective_end_date,
      sr.employee_number,
      'ADP' AS source_system
    FROM
      gabby.adp.work_assignment_history AS wah
      INNER JOIN gabby.people.employee_numbers AS sr ON wah.associate_id = sr.associate_id
      AND sr.is_active = 1
    WHERE
      '2021-01-01' BETWEEN CAST(
        wah.position_effective_date AS DATE
      ) AND COALESCE(
        CAST(
          wah.position_effective_end_date AS DATE
        ),
        CURRENT_TIMESTAMP
      )
      OR CAST(
        wah.position_effective_date AS DATE
      ) > '2021-01-01'
    UNION ALL
    /* DF */
    SELECT
      sr.associate_id,
      dwa.position_id,
      dwa.employee_reference_code AS file_number,
      dwa.legal_entity_code AS business_unit_code,
      dwa.legal_entity_name AS business_unit_description,
      dwa.department_name AS home_department_description,
      dwa.physical_location_name AS location_description,
      NULL AS job_title_code,
      dwa.job_name AS job_title_description,
      NULL job_change_reason_code,
      NULL job_change_reason_description,
      'Yes' AS primary_position,
      dwa.work_assignment_effective_start AS position_effective_date,
      CASE
        WHEN dwa.work_assignment_effective_end < '2020-12-31' THEN dwa.work_assignment_effective_end
        ELSE '2020-12-31'
      END AS position_effective_end_date,
      dwa.employee_reference_code AS employee_number,
      'DF' AS source_system
    FROM
      gabby.dayforce.employee_work_assignment_clean AS dwa
      INNER JOIN gabby.people.employee_numbers AS sr ON dwa.employee_reference_code = sr.employee_number
      AND sr.is_active = 1
    WHERE
      dwa.work_assignment_effective_start <= '2020-12-31'
  )
SELECT
  employee_number,
  associate_id,
  position_id,
  file_number,
  business_unit_code,
  business_unit_description,
  location_description,
  home_department_description,
  job_title_code,
  job_title_description,
  job_change_reason_code,
  job_change_reason_description,
  primary_position,
  position_effective_date,
  source_system,
  COALESCE(
    position_effective_end_date,
    DATEADD(
      DAY,
      -1,
      LEAD(position_effective_date, 1) OVER (
        PARTITION BY
          position_id
        ORDER BY
          position_effective_date
      )
    )
  ) AS position_effective_end_date,
  COALESCE(
    position_effective_end_date,
    DATEADD(
      DAY,
      -1,
      LEAD(position_effective_date, 1) OVER (
        PARTITION BY
          position_id
        ORDER BY
          position_effective_date
      )
    ),
    DATEFROMPARTS(
      CASE
        WHEN DATEPART(YEAR, position_effective_date) > gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
        AND DATEPART(MONTH, position_effective_date) >= 7 THEN DATEPART(YEAR, position_effective_date) + 1
        WHEN DATEPART(YEAR, CURRENT_TIMESTAMP) = gabby.utilities.GLOBAL_ACADEMIC_YEAR () + 1
        AND DATEPART(MONTH, CURRENT_TIMESTAMP) >= 7 THEN gabby.utilities.GLOBAL_ACADEMIC_YEAR () + 2
        ELSE gabby.utilities.GLOBAL_ACADEMIC_YEAR () + 1
      END,
      6,
      30
    )
  ) AS position_effective_end_date_eoy
FROM
  work_assignment_union
