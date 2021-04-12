USE gabby
GO

CREATE OR ALTER VIEW adp.staff_roster AS

WITH clean_people AS (
  SELECT sub.df_employee_number
        ,sub.adp_associate_id
        ,sub.position_id
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
        ,sub.gender_reporting
        ,sub.is_manager
        ,sub.reports_to_associate_id
        ,sub.adp_associate_id_legacy
        ,sub.mobile_number
        ,sub.personal_email
        ,sub.ethnicity AS primary_ethnicity
        ,sub.race_reporting
        ,sub.is_race_asian
        ,sub.is_race_black
        ,sub.is_race_decline
        ,sub.is_race_mideast
        ,sub.is_race_multi
        ,sub.is_race_nhpi
        ,sub.is_race_other
        ,sub.is_race_white
        ,REPLACE(sub.primary_site_clean, ' - Regional', '') AS primary_site
        ,COALESCE(sub.common_name, sub.first_name) AS preferred_first_name
        ,COALESCE(sub.preferred_last_name , sub.last_name) AS preferred_last_name
        ,CASE WHEN sub.primary_site_clean LIKE '% - Regional%' THEN 1 ELSE 0 END AS is_regional_staff
        ,CASE
          WHEN sub.ethnicity = 'Hispanic or Latino' THEN 1
          WHEN sub.ethnicity = 'Not Hispanic or Latino' THEN 0
         END AS is_hispanic
        ,CASE
          WHEN sub.race_reporting IS NULL AND sub.ethnicity = 'Hispanic or Latino' THEN 'Hispanic or Latino'
          WHEN sub.race_reporting = 'I decline to state my preferred racial/ethnic identity' THEN 'Decline to state'
          WHEN sub.race_reporting = 'My racial/ethnic identity is not listed' THEN 'Not Listed'
          WHEN sub.race_reporting = 'Latinx/Hispanic/Chicana(o)' THEN 'Hispanic or Latino'
          WHEN sub.race_reporting = 'Black or African American' THEN 'Black/African American'
          WHEN sub.race_reporting = 'Two or more races (Not Hispanic or Latino)' THEN 'Bi/Multiracial'
          ELSE sub.race_reporting + (CASE 
                                      WHEN sub.ethnicity = 'Hispanic or Latino' THEN ' - ' + sub.ethnicity
                                      ELSE '' 
                                     END)
         END AS race_ethnicity_reporting
        ,CASE
          WHEN COALESCE(sub.rehire_date, sub.original_hire_date) > GETDATE() OR sub.[status] IS NULL THEN 'PRESTART'
          WHEN sub.[status] = 'Leave' THEN 'INACTIVE'
          WHEN sub.termination_date > GETDATE() THEN 'ACTIVE'
          ELSE UPPER(sub.[status])
         END AS [status]
        /* redundant combined fields */
        ,CONCAT(sub.primary_on_site_department, ' - ', sub.primary_job) AS position_title
        ,sub.primary_site_clean + ' (' + sub.business_unit_code + ') - ' + sub.primary_on_site_department AS primary_on_site_department_entity
        ,sub.primary_site_clean + ' (' + sub.business_unit_code + ')' AS primary_site_entity
  FROM
      (
       SELECT ea.file_number AS df_employee_number
             ,ea.associate_id AS adp_associate_id
             ,ea.first_name
             ,ea.last_name
             ,ea.preferred_name AS common_name
             ,ea.primary_address_city AS city
             ,ea.primary_address_state_territory_code AS [state]
             ,ea.primary_address_zip_postal_code AS postal_code
             ,ea.personal_contact_personal_email AS personal_email
             ,CONVERT(NVARCHAR(256), NULL) AS job_family -- on the way
             /* transformations */
             ,CONVERT(DATE, ea.birth_date) AS birth_date
             ,CONCAT(ea.primary_address_address_line_1, ', ' + ea.primary_address_address_line_2) AS [address]
             ,CONVERT(NVARCHAR(256), gabby.utilities.STRIP_CHARACTERS(ea.personal_contact_personal_mobile, '^0-9')) AS mobile_number
             ,LEFT(UPPER(ea.gender), 1) AS gender
             ,COALESCE(ea.preferred_gender
                      ,CASE
                        WHEN ea.gender = 'Male' THEN 'Man'
                        WHEN ea.gender = 'Female' THEN 'Woman'
                       END) AS gender_reporting
             ,CASE
               WHEN ea.ethnicity IS NULL AND ea.preferred_race_ethnicity IS NULL THEN NULL
               WHEN CHARINDEX('Decline to state', ea.preferred_race_ethnicity) > 0 THEN NULL
               WHEN CHARINDEX('Latinx/Hispanic/Chicana(o)', ea.preferred_race_ethnicity) > 0 THEN 'Hispanic or Latino'
               WHEN ea.ethnicity = 'Hispanic or Latino' THEN 'Hispanic or Latino'
               ELSE 'Not Hispanic or Latino'
              END AS ethnicity
             ,CASE 
               WHEN ea.race_description = 'Black or African American' THEN 1
               WHEN CHARINDEX('Black/African American', ea.preferred_race_ethnicity) > 0 THEN 1
               ELSE 0
              END AS is_race_black
             ,CASE 
               WHEN ea.race_description = 'Asian' THEN 1
               WHEN CHARINDEX('Asian', ea.preferred_race_ethnicity) > 0 THEN 1
               ELSE 0
              END AS is_race_asian
             ,CASE 
               WHEN ea.race_description = 'Native Hawaiian or Other Pacific Islander' THEN 1
               WHEN CHARINDEX('Pacific Islander', ea.preferred_race_ethnicity) > 0 THEN 1
               ELSE 0
              END AS is_race_nhpi
             ,CASE 
               WHEN CHARINDEX('Middle Eastern', ea.preferred_race_ethnicity) > 0 THEN 1
               ELSE 0
              END AS is_race_mideast
             ,CASE 
               WHEN ea.race_description = 'White' THEN 1
               WHEN CHARINDEX('White', ea.preferred_race_ethnicity) > 0 THEN 1
               ELSE 0
              END AS is_race_white
             ,CASE
               WHEN ea.race_description = 'Two or more races (Not Hispanic or Latino)' THEN 1
               WHEN CHARINDEX('Bi/Multiracial', ea.preferred_race_ethnicity) > 0 THEN 1
               WHEN CHARINDEX(';', ea.preferred_race_ethnicity) > 0 THEN 1
               ELSE 0
              END AS is_race_multi
             ,CASE
               WHEN CHARINDEX('My racial/ethnic identity is not listed', ea.preferred_race_ethnicity) > 0 THEN 1
               ELSE 0
              END AS is_race_other
             ,CASE
               WHEN CHARINDEX('Decline to state', ea.preferred_race_ethnicity) > 0 THEN 1
               ELSE 0
              END AS is_race_decline
             ,CASE
               WHEN CHARINDEX(';', ea.preferred_race_ethnicity) > 0 THEN 'Bi/Multiracial'
               ELSE COALESCE(ea.preferred_race_ethnicity, ea.race_description)
              END AS race_reporting
             ,CASE
               WHEN ea.associate_id IN (SELECT reports_to_associate_id
                                         FROM gabby.adp.employees_all
                                         WHERE position_status <> 'TERMINATED')
                    THEN 'Yes'
               ELSE 'No'
              END AS is_manager

             ,e.position_id
             ,e.termination_reason_description AS status_reason
             ,e.job_title_description AS primary_job
             ,e.home_department_description AS primary_on_site_department
             ,e.reports_to_associate_id
             ,e.position_status AS [status]
             ,e.worker_category_description AS payclass
             ,e.wfmgr_pay_rule AS paytype
             ,CONVERT(DATE, e.hire_date) AS original_hire_date
             ,CONVERT(DATE, e.termination_date) AS termination_date
             ,CONVERT(DATE, e.rehire_date) AS rehire_date
             ,CONVERT(DATE, e.position_start_date) AS position_effective_from_date
             ,CONVERT(DATE, e.position_effective_end_date) AS position_effective_to_date
             ,CONVERT(MONEY, e.annual_salary) AS annual_salary
             ,UPPER(e.flsa_description) AS flsa_status
             ,CASE
               WHEN e.business_unit_description = 'TEAM Academy Charter School' THEN 'TEAM Academy Charter Schools'
               WHEN e.business_unit_description = 'KIPP TEAM and Family Schools Inc.' THEN 'KIPP New Jersey'
               ELSE e.business_unit_description
              END AS legal_entity_name
             ,CASE
               WHEN e.business_unit_description = 'TEAM Academy Charter School' THEN 'TEAM'
               WHEN e.business_unit_description = 'KIPP TEAM and Family Schools Inc.' THEN 'KNJ'
               WHEN e.business_unit_description = 'KIPP Cooper Norcross Academy' THEN 'KCNA'
               WHEN e.business_unit_description = 'KIPP Miami' THEN 'MIA'
              END AS business_unit_code
             ,CASE 
               WHEN e.location_description = 'Norfolk St. Campus' THEN 'Norfolk St Campus'
               WHEN e.location_description = 'KIPP Lanning Square Campus' THEN 'KIPP Lanning Sq Campus'
               ELSE e.location_description
              END AS primary_site_clean -- temporary fix for changed names

             ,ROW_NUMBER() OVER(
                PARTITION BY ea.associate_id 
                  ORDER BY CONVERT(DATE, e.position_start_date) DESC) AS rn

              /* use DF until fixed */
             ,df.preferred_last_name

             ,cw.adp_associate_id AS adp_associate_id_legacy
       FROM gabby.adp.employees_all ea
       JOIN gabby.adp.employees e
         ON ea.file_number = e.file_number
       LEFT JOIN gabby.dayforce.employees df
         ON ea.file_number = df.df_employee_number
       LEFT JOIN gabby.people.id_crosswalk_adp cw
         ON ea.file_number = cw.df_employee_number
        AND cw.rn_curr = 1
       WHERE ea.file_number IS NOT NULL
      ) sub
  WHERE sub.rn = 1
 )

SELECT c.df_employee_number
      ,c.adp_associate_id
      ,c.position_id
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
      ,c.personal_email
      ,c.gender_reporting
      ,c.race_reporting
      ,c.race_ethnicity_reporting
      ,c.is_race_asian
      ,c.is_race_black
      ,c.is_race_decline
      ,c.is_race_mideast
      ,c.is_race_multi
      ,c.is_race_nhpi
      ,c.is_race_other
      ,c.is_race_white

      ,c.preferred_last_name + ', ' + c.preferred_first_name AS preferred_name
      ,SUBSTRING(c.mobile_number, 1, 3) + '-'
         + SUBSTRING(c.mobile_number, 4, 3) + '-'
         + SUBSTRING(c.mobile_number, 7, 4) AS mobile_number
      ,CASE
        WHEN c.legal_entity_name = 'KIPP New Jersey' THEN '9AM'
        WHEN c.legal_entity_name = 'TEAM Academy Charter Schools' THEN '2Z3'
        WHEN c.legal_entity_name = 'KIPP Cooper Norcross Academy' THEN '3LE'
        WHEN c.legal_entity_name = 'KIPP Miami' THEN '47S'
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
