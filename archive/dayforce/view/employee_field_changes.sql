CREATE OR ALTER VIEW
  dayforce.employee_field_changes AS
WITH
  data_long AS (
    SELECT
      u.df_employee_number,
      u.preferred_name,
      u._modified,
      u.field,
      u.[value] AS new_value,
      LAG(u.[value], 1, u.[value]) OVER (
        PARTITION BY
          u.df_employee_number,
          field
        ORDER BY
          u._modified
      ) AS previous_value
    FROM
      (
        SELECT
          _modified,
          df_employee_number,
          CONCAT(
            COALESCE(common_name, first_name),
            ' ',
            COALESCE(preferred_last_name, last_name)
          ) AS preferred_name,
          CAST(preferred_last_name AS VARCHAR(MAX)) AS preferred_last_name,
          CAST(common_name AS VARCHAR(MAX)) AS common_name,
          CAST(last_name AS VARCHAR(MAX)) AS last_name,
          CAST(first_name AS VARCHAR(MAX)) AS first_name,
          CAST(birth_date AS VARCHAR(MAX)) AS birth_date,
          CAST(ethnicity AS VARCHAR(MAX)) AS ethnicity,
          CAST(gender AS VARCHAR(MAX)) AS gender,
          CAST(original_hire_date AS VARCHAR(MAX)) AS original_hire_date,
          CAST(
            primary_on_site_department_entity_ AS VARCHAR(MAX)
          ) AS primary_on_site_department_entity_,
          CAST(primary_on_site_department AS VARCHAR(MAX)) AS primary_on_site_department,
          CAST(primary_site_entity_ AS VARCHAR(MAX)) AS primary_site_entity_,
          CAST(primary_site AS VARCHAR(MAX)) AS primary_site,
          CAST(legal_entity_name AS VARCHAR(MAX)) AS legal_entity_name,
          CAST(primary_job AS VARCHAR(MAX)) AS primary_job,
          CAST(position_title AS VARCHAR(MAX)) AS position_title,
          CAST(
            position_effective_from_date AS VARCHAR(MAX)
          ) AS position_effective_from_date,
          CAST([status] AS VARCHAR(MAX)) AS [status],
          CAST(rehire_date AS VARCHAR(MAX)) AS rehire_date,
          CAST(termination_date AS VARCHAR(MAX)) AS termination_date,
          CAST(status_reason AS VARCHAR(MAX)) AS status_reason,
          CAST(mobile_number AS VARCHAR(MAX)) AS mobile_number,
          CAST([address] AS VARCHAR(MAX)) AS [address],
          CAST(city AS VARCHAR(MAX)) AS [city],
          CAST([state] AS VARCHAR(MAX)) AS [state],
          CAST(postal_code AS VARCHAR(MAX)) AS postal_code,
          CAST(paytype AS VARCHAR(MAX)) AS paytype,
          CAST(payclass AS VARCHAR(MAX)) AS payclass,
          CAST(
            jobs_and_positions_flsa_status AS VARCHAR(MAX)
          ) AS jobs_and_positions_flsa_status,
          CAST(is_manager AS VARCHAR(MAX)) AS is_manager,
          CAST(
            employee_s_manager_s_df_emp_number_id AS VARCHAR(MAX)
          ) AS employee_s_manager_s_df_emp_number_id,
          CAST(salesforce_id AS VARCHAR(MAX)) AS salesforce_id,
          CAST(adp_associate_id AS VARCHAR(MAX)) AS adp_associate_id,
          CAST(grades_taught AS VARCHAR(MAX)) AS grades_taught,
          CAST(job_family AS VARCHAR(MAX)) AS job_family,
          CAST(annual_salary AS VARCHAR(MAX)) AS annual_salary,
          CAST(position_effective_to_date AS VARCHAR(MAX)) AS position_effective_to_date,
          CAST(subjects_taught AS VARCHAR(MAX)) AS subjects_taught
        FROM
          gabby.dayforce.employees_archive
      ) AS sub UNPIVOT (
        [value] FOR field IN (
          sub.preferred_last_name,
          sub.common_name,
          sub.last_name,
          sub.first_name,
          sub.birth_date,
          sub.ethnicity,
          sub.gender,
          sub.original_hire_date,
          sub.primary_on_site_department_entity_,
          sub.primary_on_site_department,
          sub.primary_site_entity_,
          sub.primary_site,
          sub.legal_entity_name,
          sub.primary_job,
          sub.position_title,
          sub.position_effective_from_date,
          sub.[status],
          sub.rehire_date,
          sub.termination_date,
          sub.status_reason,
          sub.mobile_number,
          sub.[address],
          sub.city,
          sub.[state],
          sub.postal_code,
          sub.paytype,
          sub.payclass,
          sub.jobs_and_positions_flsa_status,
          sub.is_manager,
          sub.employee_s_manager_s_df_emp_number_id,
          sub.salesforce_id,
          sub.adp_associate_id,
          sub.grades_taught,
          sub.job_family,
          sub.annual_salary,
          sub.position_effective_to_date,
          sub.subjects_taught
        )
      ) AS u
  )
SELECT
  df.df_employee_number,
  df.preferred_name,
  df._modified,
  df.field,
  df.new_value,
  df.previous_value
FROM
  data_long AS df
WHERE
  df.new_value != df.previous_value
