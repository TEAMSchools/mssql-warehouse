USE gabby
GO

CREATE OR ALTER VIEW dayforce.staff_roster AS

WITH clean_people AS (
  SELECT CONVERT(INT,e.df_employee_number) AS df_employee_number 
        ,CONVERT(VARCHAR(25),e.adp_associate_id_clean) AS adp_associate_id 
        ,CONVERT(VARCHAR(25),e.salesforce_id) AS salesforce_id 
        ,CONVERT(VARCHAR(25),e.first_name) AS first_name
        ,CONVERT(VARCHAR(25),e.last_name) AS last_name        
        ,CONVERT(VARCHAR(125),e.[address]) AS [address]
        ,CONVERT(VARCHAR(125),e.city) AS city
        ,CONVERT(VARCHAR(5),e.[state]) AS [state]
        ,CONVERT(VARCHAR(25),e.postal_code) AS postal_code
        ,CONVERT(VARCHAR(25),e.[status]) AS [status]
        ,CONVERT(VARCHAR(125),e.status_reason) AS status_reason
        ,CONVERT(VARCHAR(5),e.is_manager) AS is_manager
        ,CONVERT(VARCHAR(125),e.primary_job) AS primary_job
        ,CONVERT(VARCHAR(125),e.primary_on_site_department_clean) AS primary_on_site_department
        ,CONVERT(VARCHAR(125),e.legal_entity_name_clean) AS legal_entity_name
        ,CONVERT(VARCHAR(25),e.job_family) AS job_family
        ,CONVERT(INT,e.employee_s_manager_s_df_emp_number_id) AS manager_df_employee_number
        ,CONVERT(VARCHAR(5),e.payclass) AS payclass
        ,CONVERT(VARCHAR(25),e.paytype) AS paytype
        ,CONVERT(VARCHAR(25),e.jobs_and_positions_flsa_status) AS flsa_status
        ,e.birth_date
        ,e.original_hire_date
        ,e.termination_date
        ,e.rehire_date
        ,e.position_effective_from_date
        ,e.annual_salary
        ,CONVERT(VARCHAR(125),e.grades_taught) AS grades_taught
        ,e.subjects_taught
        ,e.position_effective_to_date
        ,NULL AS leadership_role /* no data in export */

        ,CONVERT(VARCHAR(1),UPPER(e.gender)) AS gender
        ,CONVERT(VARCHAR(25),COALESCE(e.common_name, e.first_name)) AS preferred_first_name
        ,CONVERT(VARCHAR(25),COALESCE(e.preferred_last_name , e.last_name)) AS preferred_last_name
        ,CONVERT(VARCHAR(125),REPLACE(e.primary_site_clean, ' - Regional', '')) AS primary_site
        ,CONVERT(VARCHAR(125),RTRIM(LEFT(e.ethnicity, CHARINDEX(' (', e.ethnicity)))) AS primary_ethnicity
        ,CONVERT(VARCHAR(25),gabby.utilities.STRIP_CHARACTERS(mobile_number, '^0-9')) AS mobile_number
        ,CASE WHEN e.ethnicity LIKE '%(Hispanic%' THEN 1 ELSE 0 END AS is_hispanic
        ,CASE WHEN e.primary_site_clean LIKE '% - Regional%' THEN 1 ELSE 0 END AS is_regional_staff

        /* redundant combined fields */
        ,CONVERT(VARCHAR(125),position_title) AS position_title 
        ,CONVERT(VARCHAR(125),primary_on_site_department_entity_) AS primary_on_site_department_entity
        ,CONVERT(VARCHAR(125),primary_site_entity_) AS primary_site_entity
  FROM gabby.dayforce.employees e
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