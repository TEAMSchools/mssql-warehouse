USE gabby
GO

CREATE OR ALTER VIEW adp.staff_roster AS

WITH clean_people AS (
  SELECT sub.df_employee_number
        ,sub.adp_associate_id
        ,sub.first_name
        ,sub.last_name
        ,sub.[address]
        ,sub.city
        ,sub.[state]
        ,sub.postal_code
        ,sub.status_reason
        ,sub.primary_job
        ,sub.primary_on_site_department
        ,sub.legal_entity_name
        ,sub.job_family
        ,sub.payclass
        ,sub.paytype
        ,sub.flsa_status
        ,sub.ethnicity
        ,sub.birth_date
        ,sub.original_hire_date
        ,sub.termination_date
        ,sub.rehire_date
        ,sub.position_effective_from_date
        ,sub.position_effective_to_date
        ,sub.annual_salary
        ,sub.gender
        ,sub.is_hispanic
        ,sub.is_manager
        ,sub.reports_to_associate_id
        ,sub.adp_associate_id_legacy
        ,REPLACE(sub.primary_site_clean, ' - Regional', '') AS primary_site
        ,COALESCE(sub.common_name, sub.first_name) AS preferred_first_name
        ,COALESCE(sub.preferred_last_name , sub.last_name) AS preferred_last_name
        ,gabby.utilities.STRIP_CHARACTERS(sub.mobile_number, '^0-9') AS mobile_number
        ,CASE WHEN sub.primary_site_clean LIKE '% - Regional%' THEN 1 ELSE 0 END AS is_regional_staff
        ,CASE
          WHEN sub.ethnicity = 'Hispanic or Latino' THEN 'Hispanic or Latino'
          WHEN sub.ethnicity = 'Decline to Answer' THEN NULL
          ELSE CONVERT(VARCHAR(125), RTRIM(LEFT(sub.ethnicity, CHARINDEX(' (', sub.ethnicity))))
         END AS primary_ethnicity
        ,CASE
          WHEN COALESCE(sub.rehire_date, sub.original_hire_date) > GETDATE() OR sub.[status] IS NULL THEN 'PRESTART'
          WHEN sub.[status] = 'Leave' THEN 'INACTIVE'
          ELSE UPPER(sub.[status])
         END AS [status]
        /* redundant combined fields */
        ,CONCAT(sub.primary_on_site_department, ' - ', sub.primary_job) AS position_title
        ,sub.primary_site_clean + ' (' + sub.legal_entity_abbreviation + ') ' + '- ' + sub.primary_on_site_department AS primary_on_site_department_entity
        ,sub.primary_site_clean + ' (' + sub.legal_entity_abbreviation + ') ' AS primary_site_entity
  FROM
      (
       SELECT adp.file_number AS df_employee_number
             ,adp.associate_id AS adp_associate_id
             ,adp.first_name
             ,adp.last_name
             ,adp.preferred_name AS common_name
             ,adp.primary_address_city AS city
             ,adp.primary_address_state_territory_code AS [state]
             ,adp.primary_address_zip_postal_code AS postal_code
             ,adp.termination_reason_description AS status_reason
             ,adp.job_title_description AS primary_job
             ,adp.home_department_description AS primary_on_site_department
             ,adp.personal_contact_personal_mobile AS mobile_number
             ,adp.race_description AS ethnicity
             ,adp.reports_to_associate_id
             ,adp.position_status AS [status]
             ,adp.worker_category_description AS payclass
             ,adp.wfmgr_pay_rule AS paytype
             ,NULL AS job_family -- on the way
             /* transformations */
             ,CONVERT(DATE, adp.birth_date) AS birth_date
             ,CONVERT(DATE, adp.hire_date) AS original_hire_date
             ,CONVERT(DATE, adp.termination_date) AS termination_date
             ,CONVERT(DATE, adp.rehire_date) AS rehire_date
             ,CONVERT(DATE, adp.position_start_date) AS position_effective_from_date
             ,CONVERT(DATE, adp.termination_date) AS position_effective_to_date -- missing position_effective_end_date?
             ,CONVERT(MONEY, adp.annual_salary) AS annual_salary
             ,CONCAT(adp.primary_address_address_line_1, ', ' + adp.primary_address_address_line_2) AS [address]
             ,UPPER(adp.flsa_description) AS flsa_status
             ,LEFT(UPPER(adp.gender), 1) AS gender
             ,CASE
               WHEN adp.business_unit_description = 'TEAM Academy Charter' THEN 'TEAM Academy Charter Schools'
               WHEN adp.business_unit_description = 'KIPP TEAM and Family Schools Inc.' THEN 'KIPP New Jersey'
               WHEN adp.business_unit_description = 'KIPP Cooper Norcross' THEN 'KIPP Cooper Norcross Academy'
               ELSE adp.business_unit_description
              END AS legal_entity_name
             ,CASE
               WHEN adp.business_unit_description = 'TEAM Academy Charter' THEN 'TEAM'
               WHEN adp.business_unit_description = 'KIPP TEAM and Family Schools Inc.' THEN 'KNJ'
               WHEN adp.business_unit_description = 'KIPP Cooper Norcross' THEN 'KCNA'
               WHEN adp.business_unit_description = 'KIPP Miami' THEN 'MIA'
              END AS legal_entity_abbreviation
             ,CASE 
               WHEN adp.location_description = 'Norfolk St. Campus' THEN 'Norfolk St Campus'
               WHEN adp.location_description = 'KIPP Lanning Square Campus' THEN 'KIPP Lanning Sq Campus'
               ELSE adp.location_description
              END AS primary_site_clean -- temporary fix for changed names
             ,CASE
               WHEN adp.race_description LIKE '%Hispanic%' THEN 1
               WHEN adp.race_description NOT LIKE '%Hispanic%' THEN 1
              END AS is_hispanic
             ,CASE 
               WHEN adp.associate_id IN (SELECT reports_to_associate_id 
                                         FROM gabby.adp.employees 
                                         WHERE position_status <> 'TERMINATED') THEN 'Yes'
               ELSE 'No'
              END AS is_manager
             ,ROW_NUMBER() OVER(
                PARTITION BY adp.associate_id 
                  ORDER BY CONVERT(DATE, adp.position_start_date) DESC) AS rn

             ,df.preferred_last_name -- use DF until fixed

             ,cw.adp_associate_id AS adp_associate_id_legacy -- replace with new crosswalk
       FROM gabby.adp.employees adp
       LEFT JOIN gabby.dayforce.employees df
         ON adp.file_number = df.df_employee_number
       LEFT JOIN gabby.people.id_crosswalk_adp cw
         ON adp.file_number = cw.df_employee_number
        AND cw.rn_curr = 1
      ) sub
  WHERE sub.rn = 1
 )

SELECT c.df_employee_number
      ,c.adp_associate_id
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
      ,c.reports_to_associate_id
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
      ,c.payclass
      ,c.paytype
      ,c.flsa_status
      ,c.annual_salary
      ,c.position_title
      ,c.primary_on_site_department_entity
      ,c.primary_site_entity
      ,c.adp_associate_id_legacy
      ,NULL AS salesforce_id
      ,NULL AS grades_taught
      ,NULL AS subjects_taught
      ,NULL AS leadership_role
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

      ,m.df_employee_number AS manager_df_employee_number
      ,m.adp_associate_id AS manager_adp_associate_id
      ,m.preferred_first_name AS manager_preferred_first_name
      ,m.preferred_last_name AS manager_preferred_last_name
      ,m.preferred_last_name + ', ' + m.preferred_first_name AS manager_name
FROM clean_people c
LEFT JOIN gabby.people.school_crosswalk s
  ON c.primary_site = s.site_name
 AND s._fivetran_deleted = 0
LEFT JOIN clean_people m
  ON c.reports_to_associate_id = m.adp_associate_id
