USE gabby GO
CREATE OR ALTER VIEW
  adp.wfm_field_monitor AS
WITH
  unpivoted AS (
    SELECT
      associate_id,
      position_id,
      date_modified,
      row_hash AS new_value,
      LAG(row_hash, 1) OVER (
        PARTITION BY
          position_id
        ORDER BY
          date_modified
      ) AS prev_value
    FROM
      (
        SELECT
          associate_id,
          position_id,
          _modified AS date_modified,
          HASHBYTES(
            'SHA2_512',
            CONCAT(
              business_unit_description,
              '_',
              location_description,
              '_',
              home_department_description,
              '_',
              job_title_description,
              '_',
              reports_to_associate_id,
              '_',
              annual_salary,
              '_',
              flsa_description,
              '_',
              wfmgr_pay_rule,
              '_',
              wfmgr_accrual_profile,
              '_',
              wfmgr_ee_type,
              '_',
              wfmgr_badge_number
            )
          ) AS row_hash
        FROM
          gabby.adp.employees_archive
        WHERE
          position_id IS NOT NULL
          AND position_status != 'Terminated'
          AND CAST(
              COALESCE(rehire_date, hire_date) AS DATE
          ) <= CAST(CURRENT_TIMESTAMP AS DATE)
      ) AS sub
  )

SELECT
  unpivoted.associate_id,
  unpivoted.position_id,
  unpivoted.date_modified,
  unpivoted.prev_value,
  unpivoted.new_value,
  gabby.adp.workers_clean_static.associate_oid
FROM
  unpivoted
  INNER JOIN
      gabby.adp.workers_clean_static ON
          unpivoted.associate_id = gabby.adp.workers_clean_static.worker_id
WHERE
  (unpivoted.new_value != unpivoted.prev_value)
  OR unpivoted.prev_value IS NULL
  OR unpivoted.new_value IS NULL
