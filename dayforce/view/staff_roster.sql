USE gabby GO
CREATE OR ALTER VIEW
  dayforce.staff_roster AS
WITH
  clean_people AS (
    SELECT
      sub.df_employee_number,
      sub.adp_associate_id,
      sub.salesforce_id,
      sub.first_name,
      sub.last_name,
      sub.[address],
      sub.city,
      sub.[state],
      sub.postal_code,
      sub.[status],
      sub.status_reason,
      sub.is_manager,
      sub.primary_job,
      sub.primary_on_site_department,
      sub.legal_entity_name,
      sub.job_family,
      sub.payclass,
      sub.paytype,
      sub.flsa_status,
      sub.grades_taught,
      sub.subjects_taught,
      sub.ethnicity,
      sub.manager_df_employee_number,
      sub.birth_date,
      sub.original_hire_date,
      sub.termination_date,
      sub.rehire_date,
      sub.position_effective_from_date,
      sub.position_effective_to_date,
      sub.annual_salary,
      sub.leadership_role,
      sub.position_title,
      sub.primary_on_site_department_entity,
      sub.primary_site_entity,
      sub.gender,
      sub.is_hispanic,
      CAST(
        REPLACE(sub.primary_site_clean, ' - Regional', '') AS VARCHAR(125)
      ) AS primary_site,
      CAST(
        COALESCE(sub.common_name, sub.first_name) AS VARCHAR(25)
      ) AS preferred_first_name,
      CAST(
        COALESCE(sub.preferred_last_name, sub.last_name) AS VARCHAR(25)
      ) AS preferred_last_name,
      CASE
        WHEN sub.ethnicity = 'Hispanic or Latino' THEN 'Hispanic or Latino'
        WHEN sub.ethnicity = 'Decline to Answer' THEN NULL
        ELSE CAST(
          RTRIM(
            LEFT(
              sub.ethnicity,
              CHARINDEX(' (', sub.ethnicity)
            )
          ) AS VARCHAR(125)
        )
      END AS primary_ethnicity,
      CAST(
        gabby.utilities.STRIP_CHARACTERS (sub.mobile_number, '^0-9') AS VARCHAR(25)
      ) AS mobile_number,
      CASE
        WHEN sub.primary_site_clean LIKE '% - Regional%' THEN 1
        ELSE 0
      END AS is_regional_staff
    FROM
      (
        SELECT
          CAST(e.df_employee_number AS INT) AS df_employee_number,
          CASE
            WHEN e.adp_associate_id_clean <> '' THEN CAST(e.adp_associate_id_clean AS VARCHAR(25))
          END AS adp_associate_id,
          CASE
            WHEN e.salesforce_id <> '' THEN CAST(e.salesforce_id AS VARCHAR(25))
          END AS salesforce_id,
          CASE
            WHEN e.first_name <> '' THEN CAST(e.first_name AS VARCHAR(25))
          END AS first_name,
          CASE
            WHEN e.last_name <> '' THEN CAST(e.last_name AS VARCHAR(25))
          END AS last_name,
          CASE
            WHEN e.common_name <> '' THEN CAST(e.common_name AS VARCHAR(25))
          END AS common_name,
          CASE
            WHEN e.preferred_last_name <> '' THEN CAST(e.preferred_last_name AS VARCHAR(25))
          END AS preferred_last_name,
          CASE
            WHEN e.[address] <> '' THEN CAST(e.[address] AS VARCHAR(125))
          END AS [address],
          CASE
            WHEN e.city <> '' THEN CAST(e.city AS VARCHAR(125))
          END AS city,
          CASE
            WHEN e.[state] <> '' THEN CAST(e.[state] AS VARCHAR(5))
          END AS [state],
          CASE
            WHEN e.postal_code <> '' THEN CAST(e.postal_code AS VARCHAR(25))
          END AS postal_code,
          CASE
            WHEN e.[status] <> '' THEN CAST(e.[status] AS VARCHAR(25))
          END AS [status],
          CASE
            WHEN e.status_reason <> '' THEN CAST(e.status_reason AS VARCHAR(125))
          END AS status_reason,
          CASE
            WHEN e.is_manager <> '' THEN CAST(e.is_manager AS VARCHAR(5))
          END AS is_manager,
          CASE
            WHEN e.primary_job <> '' THEN CAST(e.primary_job AS VARCHAR(125))
          END AS primary_job,
          CASE
            WHEN e.primary_on_site_department_clean <> '' THEN CAST(
              e.primary_on_site_department_clean AS VARCHAR(125)
            )
          END AS primary_on_site_department,
          CASE
            WHEN e.legal_entity_name_clean <> '' THEN CAST(e.legal_entity_name_clean AS VARCHAR(125))
          END AS legal_entity_name,
          CASE
            WHEN e.job_family <> '' THEN CAST(e.job_family AS VARCHAR(25))
          END AS job_family,
          CASE
            WHEN e.payclass <> '' THEN CAST(e.payclass AS VARCHAR(5))
          END AS payclass,
          CASE
            WHEN e.paytype <> '' THEN CAST(e.paytype AS VARCHAR(25))
          END AS paytype,
          CASE
            WHEN e.jobs_and_positions_flsa_status <> '' THEN CAST(
              e.jobs_and_positions_flsa_status AS VARCHAR(25)
            )
          END AS flsa_status,
          CASE
            WHEN e.grades_taught <> '' THEN CAST(e.grades_taught AS VARCHAR(125))
          END AS grades_taught,
          CASE
            WHEN e.subjects_taught <> '' THEN e.subjects_taught
          END AS subjects_taught,
          CASE
            WHEN e.primary_site_clean <> '' THEN e.primary_site_clean
          END AS primary_site_clean,
          CASE
            WHEN e.mobile_number <> '' THEN e.mobile_number
          END AS mobile_number,
          CASE
            WHEN e.ethnicity <> '' THEN e.ethnicity
          END AS ethnicity,
          CAST(
            e.employee_s_manager_s_df_emp_number_id AS INT
          ) AS manager_df_employee_number,
          e.birth_date,
          e.original_hire_date,
          e.termination_date,
          e.rehire_date,
          e.position_effective_from_date,
          e.position_effective_to_date,
          e.annual_salary,
          NULL AS leadership_role /* no data in export */
          /* redundant combined fields */
,
          CAST(position_title AS VARCHAR(125)) AS position_title,
          CAST(
            primary_on_site_department_entity_ AS VARCHAR(125)
          ) AS primary_on_site_department_entity,
          CAST(primary_site_entity_ AS VARCHAR(125)) AS primary_site_entity,
          CAST(UPPER(e.gender) AS VARCHAR(1)) AS gender,
          CASE
            WHEN e.ethnicity LIKE '%Hispanic%' THEN 1
            ELSE 0
          END AS is_hispanic
        FROM
          gabby.dayforce.employees AS e
      ) sub
  )
SELECT
  c.df_employee_number,
  c.adp_associate_id,
  c.salesforce_id,
  c.first_name,
  c.last_name,
  c.gender,
  c.primary_ethnicity,
  c.is_hispanic,
  c.[address],
  c.city,
  c.[state],
  c.postal_code,
  c.birth_date,
  c.original_hire_date,
  c.termination_date,
  c.rehire_date,
  c.[status],
  c.status_reason,
  c.is_manager,
  c.leadership_role,
  c.preferred_first_name,
  c.preferred_last_name,
  c.primary_job,
  c.primary_on_site_department,
  c.primary_site,
  c.is_regional_staff,
  c.legal_entity_name,
  c.job_family,
  c.position_effective_from_date,
  c.position_effective_to_date,
  c.manager_df_employee_number,
  c.payclass,
  c.paytype,
  c.flsa_status,
  c.annual_salary,
  c.grades_taught,
  c.subjects_taught,
  c.position_title,
  c.primary_on_site_department_entity,
  c.primary_site_entity,
  CAST(
    c.preferred_last_name + ', ' + c.preferred_first_name AS VARCHAR(125)
  ) AS preferred_name,
  SUBSTRING(c.mobile_number, 1, 3) + '-' + SUBSTRING(c.mobile_number, 4, 3) + '-' + SUBSTRING(c.mobile_number, 7, 4) AS mobile_number,
  CASE
    WHEN c.legal_entity_name = 'TEAM Academy Charter Schools' THEN 'YHD'
    WHEN c.legal_entity_name = 'KIPP New Jersey' THEN 'D30'
    WHEN c.legal_entity_name = 'KIPP Cooper Norcross Academy' THEN 'D3Z'
  END AS payroll_company_code,
  CASE
    WHEN c.legal_entity_name = 'TEAM Academy Charter Schools' THEN 'kippnewark'
    WHEN c.legal_entity_name = 'KIPP Cooper Norcross Academy' THEN 'kippcamden'
    WHEN c.legal_entity_name = 'KIPP Miami' THEN 'kippmiami'
  END AS [db_name],
  CASE
    WHEN c.[status] NOT IN ('TERMINATED', 'PRESTART') THEN 1
    ELSE 0
  END AS is_active,
  s.ps_school_id AS primary_site_schoolid,
  s.reporting_school_id AS primary_site_reporting_schoolid,
  s.school_level AS primary_site_school_level,
  s.is_campus AS is_campus_staff,
  m.adp_associate_id AS manager_adp_associate_id,
  m.preferred_first_name AS manager_preferred_first_name,
  m.preferred_last_name AS manager_preferred_last_name,
  CAST(
    m.preferred_last_name + ', ' + m.preferred_first_name AS VARCHAR(125)
  ) AS manager_name
FROM
  clean_people AS c
  LEFT JOIN gabby.people.school_crosswalk AS s ON c.primary_site = s.site_name
  AND s._fivetran_deleted = 0
  LEFT JOIN clean_people AS m ON c.manager_df_employee_number = m.df_employee_number
