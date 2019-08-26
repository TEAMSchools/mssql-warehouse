USE gabby
GO

CREATE OR ALTER VIEW dayforce.staff_roster AS

WITH clean_people AS (
  SELECT sub.df_employee_number
        ,sub.adp_associate_id
        ,sub.salesforce_id
        ,sub.first_name
        ,sub.last_name
        ,sub.address
        ,sub.city
        ,sub.state
        ,sub.postal_code
        ,sub.status
        ,sub.status_reason
        ,sub.is_manager
        ,sub.primary_job
        ,sub.primary_on_site_department
        ,sub.legal_entity_name
        ,sub.job_family
        ,sub.payclass
        ,sub.paytype
        ,sub.flsa_status
        ,sub.grades_taught
        ,sub.subjects_taught
        ,sub.ethnicity
        ,sub.manager_df_employee_number
        ,sub.birth_date
        ,sub.original_hire_date
        ,sub.termination_date
        ,sub.rehire_date
        ,sub.position_effective_from_date
        ,sub.position_effective_to_date
        ,sub.annual_salary
        ,sub.leadership_role
        ,sub.position_title
        ,sub.primary_on_site_department_entity
        ,sub.primary_site_entity
        ,sub.gender
        ,sub.is_hispanic

        ,CONVERT(VARCHAR(125),REPLACE(sub.primary_site_clean, ' - Regional', '')) AS primary_site
        ,CONVERT(VARCHAR(25),COALESCE(sub.common_name, sub.first_name)) AS preferred_first_name
        ,CONVERT(VARCHAR(25),COALESCE(sub.preferred_last_name , sub.last_name)) AS preferred_last_name
        ,CASE
          WHEN sub.ethnicity = 'Hispanic or Latino' THEN 'Hispanic or Latino'
          WHEN sub.ethnicity = 'Decline to Answer' THEN NULL
          ELSE CONVERT(VARCHAR(125),
                 RTRIM(LEFT(sub.ethnicity, CHARINDEX(' (', sub.ethnicity)))
                ) 
         END AS primary_ethnicity
        ,CONVERT(VARCHAR(25),gabby.utilities.STRIP_CHARACTERS(sub.mobile_number, '^0-9')) AS mobile_number
        ,CASE WHEN sub.primary_site_clean LIKE '% - Regional%' THEN 1 ELSE 0 END AS is_regional_staff
  FROM
      (
       SELECT CONVERT(INT,e.df_employee_number) AS df_employee_number
             ,CASE WHEN e.adp_associate_id_clean != '' THEN CONVERT(VARCHAR(25),e.adp_associate_id_clean) END AS adp_associate_id
             ,CASE WHEN e.salesforce_id != '' THEN CONVERT(VARCHAR(25),e.salesforce_id) END AS salesforce_id
             ,CASE WHEN e.first_name != '' THEN CONVERT(VARCHAR(25),e.first_name) END AS first_name
             ,CASE WHEN e.last_name != '' THEN CONVERT(VARCHAR(25),e.last_name) END AS last_name
             ,CASE WHEN e.common_name != '' THEN CONVERT(VARCHAR(25),e.common_name) END AS common_name
             ,CASE WHEN e.preferred_last_name != '' THEN CONVERT(VARCHAR(25),e.preferred_last_name) END AS preferred_last_name
             ,CASE WHEN e.[address] != '' THEN CONVERT(VARCHAR(125),e.[address]) END AS [address]
             ,CASE WHEN e.city != '' THEN CONVERT(VARCHAR(125),e.city) END AS city
             ,CASE WHEN e.[state] != '' THEN CONVERT(VARCHAR(5),e.[state]) END AS [state]
             ,CASE WHEN e.postal_code != '' THEN CONVERT(VARCHAR(25),e.postal_code) END AS postal_code
             ,CASE WHEN e.[status] != '' THEN CONVERT(VARCHAR(25),e.[status]) END AS [status]
             ,CASE WHEN e.status_reason != '' THEN CONVERT(VARCHAR(125),e.status_reason) END AS status_reason
             ,CASE WHEN e.is_manager != '' THEN CONVERT(VARCHAR(5),e.is_manager) END AS is_manager
             ,CASE WHEN e.primary_job != '' THEN CONVERT(VARCHAR(125),e.primary_job) END AS primary_job
             ,CASE WHEN e.primary_on_site_department_clean != '' THEN CONVERT(VARCHAR(125),e.primary_on_site_department_clean) END AS primary_on_site_department
             ,CASE WHEN e.legal_entity_name_clean != '' THEN CONVERT(VARCHAR(125),e.legal_entity_name_clean) END AS legal_entity_name
             ,CASE WHEN e.job_family != '' THEN CONVERT(VARCHAR(25),e.job_family) END AS job_family
             ,CASE WHEN e.payclass != '' THEN CONVERT(VARCHAR(5),e.payclass) END AS payclass
             ,CASE WHEN e.paytype != '' THEN CONVERT(VARCHAR(25),e.paytype) END AS paytype
             ,CASE WHEN e.jobs_and_positions_flsa_status != '' THEN CONVERT(VARCHAR(25),e.jobs_and_positions_flsa_status) END AS flsa_status
             ,CASE WHEN e.grades_taught != '' THEN CONVERT(VARCHAR(125),e.grades_taught) END AS grades_taught
             ,CASE WHEN e.subjects_taught != '' THEN e.subjects_taught END AS subjects_taught
             ,CASE WHEN e.primary_site_clean != '' THEN e.primary_site_clean END AS primary_site_clean
             ,CASE WHEN e.mobile_number != '' THEN e.mobile_number END AS mobile_number
             ,CASE WHEN e.ethnicity != '' THEN e.ethnicity END AS ethnicity
             ,CONVERT(INT,e.employee_s_manager_s_df_emp_number_id) AS manager_df_employee_number
             ,e.birth_date
             ,e.original_hire_date
             ,e.termination_date
             ,e.rehire_date
             ,e.position_effective_from_date
             ,e.position_effective_to_date
             ,e.annual_salary
             ,NULL AS leadership_role /* no data in export */
             /* redundant combined fields */
             ,CONVERT(VARCHAR(125),position_title) AS position_title 
             ,CONVERT(VARCHAR(125),primary_on_site_department_entity_) AS primary_on_site_department_entity
             ,CONVERT(VARCHAR(125),primary_site_entity_) AS primary_site_entity
             ,CONVERT(VARCHAR(1),UPPER(e.gender)) AS gender
             ,CASE WHEN e.ethnicity LIKE '%Hispanic%' THEN 1 ELSE 0 END AS is_hispanic
       FROM gabby.dayforce.employees e
      ) sub
 )

SELECT c.df_employee_number
      ,c.adp_associate_id
      ,c.salesforce_id
      ,c.first_name
      ,c.last_name
      ,c.gender
      ,c.primary_ethnicity
      ,c.is_hispanic      
      ,c.[address]
      ,c.city
      ,c.[state]
      ,c.postal_code
      ,c.birth_date
      ,c.original_hire_date
      ,c.termination_date
      ,c.rehire_date
      ,c.[status]
      ,c.status_reason
      ,c.is_manager
      ,c.leadership_role
      ,c.preferred_first_name
      ,c.preferred_last_name
      ,c.primary_job
      ,c.primary_on_site_department
      ,c.primary_site      
      ,c.is_regional_staff
      ,c.legal_entity_name
      ,c.job_family
      ,c.position_effective_from_date
      ,c.position_effective_to_date
      ,c.manager_df_employee_number
      ,c.payclass
      ,c.paytype
      ,c.flsa_status
      ,c.annual_salary
      ,c.grades_taught
      ,c.subjects_taught
      ,c.position_title
      ,c.primary_on_site_department_entity
      ,c.primary_site_entity
      ,c.preferred_last_name + ', ' + c.preferred_first_name AS preferred_name
      ,SUBSTRING(c.mobile_number, 1, 3) + '-'
         + SUBSTRING(c.mobile_number, 4, 3) + '-'
         + SUBSTRING(c.mobile_number, 7, 4) AS mobile_number
      ,CASE
        WHEN c.legal_entity_name = 'TEAM Academy Charter Schools' THEN 'YHD'
        WHEN c.legal_entity_name = 'KIPP New Jersey' THEN 'D30'
        WHEN c.legal_entity_name = 'KIPP Cooper Norcross Academy' THEN 'D3Z'
       END AS payroll_company_code
      ,CASE
        WHEN c.legal_entity_name = 'TEAM Academy Charter Schools' THEN 'kippnewark'
        WHEN c.legal_entity_name = 'KIPP Cooper Norcross Academy' THEN 'kippcamden'
        WHEN c.legal_entity_name = 'KIPP Miami' THEN 'kippmiami'
       END AS [db_name]
      ,CASE WHEN c.[status] NOT IN ('TERMINATED', 'PRESTART') THEN 1 ELSE 0 END AS is_active
      
      ,s.ps_school_id AS primary_site_schoolid
      ,s.reporting_school_id AS primary_site_reporting_schoolid
      ,s.school_level AS primary_site_school_level
      ,s.is_campus AS is_campus_staff

      ,m.adp_associate_id AS manager_adp_associate_id
      ,m.preferred_first_name AS manager_preferred_first_name
      ,m.preferred_last_name AS manager_preferred_last_name
      ,m.preferred_last_name + ', ' + m.preferred_first_name AS manager_name
FROM clean_people c
LEFT JOIN gabby.people.school_crosswalk s
  ON c.primary_site = s.site_name
 AND s._fivetran_deleted = 0
LEFT JOIN clean_people m
  ON c.manager_df_employee_number = m.df_employee_number