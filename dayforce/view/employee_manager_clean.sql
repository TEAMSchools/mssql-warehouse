CREATE OR ALTER VIEW
  dayforce.employee_manager_clean AS
SELECT
  sub.employee_reference_code,
  sub.position_id,
  sub.manager_employee_number,
  sub.manager_effective_start,
  DATEADD(
    DAY,
    -1,
    sub.manager_effective_start_next
  ) AS manager_effective_end
FROM
  (
    SELECT
      sub.employee_reference_code,
      sub.position_id,
      sub.manager_employee_number,
      sub.manager_effective_start,
      LEAD(
        sub.manager_effective_start,
        1
      ) OVER (
        PARTITION BY
          sub.employee_reference_code
        ORDER BY
          sub.manager_effective_start ASC
      ) AS manager_effective_start_next
    FROM
      (
        SELECT
          em.employee_reference_code,
          em.manager_employee_number,
          CAST(
            em.manager_effective_start AS DATE
          ) AS manager_effective_start,
          ROW_NUMBER() OVER (
            PARTITION BY
              em.employee_reference_code,
              CAST(
                em.manager_effective_start AS DATE
              )
            ORDER BY
              COALESCE(
                CAST(
                  em.manager_effective_end AS DATE
                ),
                '2020-12-31'
              ) DESC
          ) AS rn_start,
          CONCAT(
            CASE
              WHEN e.legal_entity_name = 'KIPP New Jersey' THEN '9AM'
              WHEN e.legal_entity_name = 'TEAM Academy Charter Schools' THEN '2Z3'
              WHEN e.legal_entity_name = 'KIPP Cooper Norcross Academy' THEN '3LE'
              WHEN e.legal_entity_name = 'KIPP Miami' THEN '47S'
            END,
            em.employee_reference_code
          ) AS position_id
        FROM
          gabby.dayforce.employee_manager AS em
          INNER JOIN gabby.dayforce.employees AS e ON (
            em.employee_reference_code = e.df_employee_number
          )
        WHERE
          em.manager_derived_method = 'Direct Report'
          AND (
            em.manager_effective_start < em.manager_effective_end
            OR em.manager_effective_end IS NULL
          )
      ) AS sub
    WHERE
      sub.rn_start = 1
  ) AS sub
