CREATE OR ALTER VIEW
  dayforce.employee_work_assignment_clean AS
SELECT
  sub.employee_reference_code,
  sub.job_name,
  sub.legal_entity_code,
  sub.legal_entity_name,
  sub.physical_location_name,
  sub.department_name,
  sub.flsa_status_name,
  sub.job_family_name,
  sub.pay_class_name,
  sub.pay_type_name,
  sub.position_id,
  sub.work_assignment_effective_start,
  DATEADD(
    DAY,
    -1,
    sub.work_assignment_effective_start_next
  ) AS work_assignment_effective_end
FROM
  (
    SELECT
      ewa.employee_reference_code,
      ewa.job_name,
      ewa.legal_entity_name AS legal_entity_code,
      e.legal_entity_name,
      ewa.physical_location_name,
      ewa.department_name,
      ewa.flsa_status_name,
      ewa.job_family_name,
      ewa.pay_class_name,
      ewa.pay_type_name,
      CONCAT(
        CASE
          WHEN e.legal_entity_name = 'KIPP New Jersey' THEN '9AM'
          WHEN e.legal_entity_name = 'TEAM Academy Charter Schools' THEN '2Z3'
          WHEN e.legal_entity_name = 'KIPP Cooper Norcross Academy' THEN '3LE'
          WHEN e.legal_entity_name = 'KIPP Miami' THEN '47S'
        END,
        ewa.employee_reference_code
      ) AS position_id,
      (
        CAST(
          ewa.work_assignment_effective_start AS DATE
        )
      ) AS work_assignment_effective_start,
      LEAD(
        CAST(
          ewa.work_assignment_effective_start AS DATE
        ),
        1
      ) OVER (
        PARTITION BY
          ewa.employee_reference_code
        ORDER BY
          CAST(
            ewa.work_assignment_effective_start AS DATE
          )
      ) AS work_assignment_effective_start_next
    FROM
      gabby.dayforce.employee_work_assignment AS ewa
      INNER JOIN gabby.dayforce.employees AS e ON (
        ewa.employee_reference_code = e.df_employee_number
      )
    WHERE
      ewa.primary_work_assignment = 1
  ) AS sub
