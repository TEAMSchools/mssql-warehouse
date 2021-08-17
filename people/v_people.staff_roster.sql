USE gabby
GO

CREATE OR ALTER VIEW people.staff_roster AS

WITH all_staff AS (
  /* current */
  SELECT eh.employee_number
        ,eh.associate_id
        ,eh.position_id
        ,eh.file_number
        ,eh.termination_reason
        ,eh.job_title
        ,eh.home_department
        ,eh.reports_to_associate_id
        ,eh.reports_to_employee_number
        ,eh.position_status
        ,eh.business_unit_code
        ,eh.business_unit
        ,eh.[location]
        ,eh.position_effective_start_date
        ,eh.position_effective_end_date
        ,eh.annual_salary
        ,eh.effective_start_date
        ,eh.status_effective_start_date
  FROM gabby.people.employment_history eh
  WHERE CONVERT(DATE, GETDATE()) BETWEEN eh.effective_start_date AND eh.effective_end_date

  UNION ALL

  /* prestart */
  SELECT ps.employee_number
        ,ps.associate_id
        ,ps.position_id
        ,ps.file_number
        ,ps.termination_reason
        ,ps.job_title
        ,ps.home_department
        ,ps.reports_to_associate_id
        ,ps.reports_to_employee_number
        ,'Prestart' AS position_status
        ,ps.business_unit_code
        ,ps.business_unit
        ,ps.[location]
        ,ps.position_effective_start_date
        ,ps.position_effective_end_date
        ,ps.annual_salary
        ,ps.effective_start_date
        ,ps.status_effective_start_date
  FROM gabby.people.employment_history ps
  WHERE ps.status_effective_start_date > CONVERT(DATE, GETDATE())
    AND ps.position_status = 'Active'
    AND (ps.position_status_cur IS NULL OR ps.position_status_cur = 'Terminated')
 )

,clean_staff AS (
  SELECT sub.employee_number
        ,sub.associate_id
        ,sub.associate_oid
        ,sub.position_id
        ,sub.file_number
        ,sub.first_name
        ,sub.last_name
        ,sub.position_status
        ,sub.business_unit_code
        ,sub.business_unit
        ,sub.[location]
        ,sub.home_department
        ,sub.job_title
        ,sub.is_manager
        ,sub.reports_to_associate_id
        ,sub.annual_salary
        ,sub.position_effective_start_date
        ,sub.position_effective_end_date
        ,sub.hire_date
        ,sub.rehire_date
        ,sub.termination_date
        ,sub.termination_reason
        ,sub.job_family
        ,sub.address_street
        ,sub.address_city
        ,sub.address_state
        ,sub.address_zip
        ,sub.birth_date
        ,sub.personal_email
        ,sub.personal_mobile
        ,sub.wfmgr_pay_rule
        ,sub.worker_category
        ,sub.flsa
        ,sub.associate_id_legacy
        ,sub.sex
        ,sub.preferred_gender
        ,sub.gender_reporting
        ,sub.preferred_race_ethnicity
        ,sub.ethnicity
        ,sub.race
        ,sub.race_reporting
        ,sub.is_race_asian
        ,sub.is_race_black
        ,sub.is_race_decline
        ,sub.is_race_mideast
        ,sub.is_race_multi
        ,sub.is_race_nhpi
        ,sub.is_race_other
        ,sub.is_race_white
        ,COALESCE(sub.preferred_first_name, sub.first_name) AS preferred_first_name
        ,COALESCE(sub.preferred_last_name , sub.last_name) AS preferred_last_name
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
  FROM
      (
       SELECT eh.employee_number
             ,eh.associate_id
             ,eh.position_id
             ,eh.file_number
             ,eh.termination_reason
             ,eh.job_title
             ,eh.home_department
             ,eh.reports_to_associate_id
             ,eh.position_status
             ,eh.business_unit_code
             ,eh.business_unit
             ,eh.[location]
             ,eh.position_effective_start_date
             ,eh.position_effective_end_date
             ,eh.annual_salary
             ,CONVERT(NVARCHAR(256), NULL) AS job_family -- on the way
             ,CASE 
               WHEN eh.associate_id IN (SELECT reports_to_associate_id
                                        FROM gabby.people.manager_history_static
                                        WHERE CONVERT(DATE, GETDATE()) BETWEEN reports_to_effective_date 
                                                                           AND reports_to_effective_end_date_eoy) THEN 1
               ELSE 0
              END AS is_manager
             /* dedupe positions */
             ,ROW_NUMBER() OVER(
                PARTITION BY eh.associate_id
                  ORDER BY eh.status_effective_start_date DESC
                          ,CASE WHEN eh.position_status = 'Terminated' THEN 0 ELSE 1 END DESC
                          ,eh.effective_start_date DESC) AS rn

             ,ea.first_name
             ,ea.last_name
             ,ea.primary_address_city AS address_city
             ,ea.primary_address_state_territory_code AS address_state
             ,ea.primary_address_zip_postal_code AS address_zip
             ,ea.personal_contact_personal_email AS personal_email
             ,ea.preferred_gender
             ,ea.race_description AS race
             ,ea.preferred_race_ethnicity
             /* transformations */
             ,CONVERT(DATE, ea.birth_date) AS birth_date
             ,LEFT(UPPER(ea.gender_for_insurance_coverage), 1) AS sex
             ,CASE 
               WHEN ea.primary_address_address_line_1 IS NOT NULL 
                    THEN CONCAT(ea.primary_address_address_line_1, ', ' + ea.primary_address_address_line_2)
              END AS address_street
             ,CONVERT(NVARCHAR(256), gabby.utilities.STRIP_CHARACTERS(ea.personal_contact_personal_mobile, '^0-9')) AS personal_mobile
             ,COALESCE(ea.preferred_gender
                      ,CASE
                        WHEN ea.gender_for_insurance_coverage = 'Male' THEN 'Man'
                        WHEN ea.gender_for_insurance_coverage = 'Female' THEN 'Woman'
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

             ,w.preferred_name_given AS preferred_first_name
             ,w.preferred_name_family AS preferred_last_name
             ,w.associate_oid

             ,p.wfmgr_pay_rule
             ,p.worker_category_description AS worker_category
             ,p.flsa_description AS flsa
             ,CONVERT(DATE, p.rehire_date) AS rehire_date
             ,CASE 
               WHEN eh.position_status = 'Prestart' THEN NULL
               ELSE CONVERT(DATE, p.termination_date) 
              END AS termination_date
             ,CASE
               WHEN eh.position_status = 'Prestart' THEN eh.position_effective_start_date
               ELSE CONVERT(DATE, p.hire_date)
              END AS hire_date

             ,cw.adp_associate_id AS associate_id_legacy
       FROM all_staff eh
       JOIN gabby.adp.employees_all ea
         ON eh.associate_id = ea.associate_id
       LEFT JOIN gabby.adp.workers_clean_static w
         ON eh.associate_id = w.worker_id
       LEFT JOIN gabby.adp.employees p
         ON eh.position_id = p.position_id
       LEFT JOIN gabby.people.id_crosswalk_adp cw
         ON eh.employee_number = cw.df_employee_number
        AND cw.rn_curr = 1
       WHERE eh.employee_number IS NOT NULL
      ) sub
  WHERE rn = 1
 )

SELECT c.employee_number
      ,c.associate_id
      ,c.associate_oid
      ,c.position_id
      ,c.file_number
      ,c.first_name
      ,c.last_name
      ,c.position_status
      ,c.business_unit
      ,c.[location]
      ,c.home_department
      ,c.job_title
      ,c.is_manager
      ,c.reports_to_associate_id
      ,c.annual_salary
      ,c.position_effective_start_date
      ,c.position_effective_end_date
      ,c.hire_date AS original_hire_date
      ,c.rehire_date
      ,c.termination_date
      ,c.termination_reason
      ,c.job_family
      ,c.address_street
      ,c.address_city
      ,c.address_state
      ,c.address_zip
      ,c.birth_date
      ,c.personal_email
      ,c.wfmgr_pay_rule
      ,c.worker_category
      ,c.flsa
      ,c.associate_id_legacy
      ,c.preferred_first_name
      ,c.preferred_last_name
      ,c.business_unit_code
      ,c.sex
      ,c.preferred_gender
      ,c.gender_reporting
      ,c.race
      ,c.preferred_race_ethnicity
      ,c.ethnicity
      ,c.is_hispanic
      ,c.race_reporting
      ,c.is_race_asian
      ,c.is_race_black
      ,c.is_race_decline
      ,c.is_race_mideast
      ,c.is_race_multi
      ,c.is_race_nhpi
      ,c.is_race_other
      ,c.is_race_white
      ,c.race_ethnicity_reporting
      ,c.preferred_last_name + ', ' + c.preferred_first_name AS preferred_name
      ,SUBSTRING(c.personal_mobile, 1, 3) + '-'
         + SUBSTRING(c.personal_mobile, 4, 3) + '-'
         + SUBSTRING(c.personal_mobile, 7, 4) AS personal_mobile
      ,CASE
        WHEN c.business_unit = 'KIPP TEAM and Family Schools Inc.' THEN '9AM'
        WHEN c.business_unit = 'TEAM Academy Charter School' THEN '2Z3'
        WHEN c.business_unit = 'KIPP Cooper Norcross Academy' THEN '3LE'
        WHEN c.business_unit = 'KIPP Miami' THEN '47S'
       END AS payroll_company_code
      ,CASE
        WHEN c.business_unit = 'TEAM Academy Charter School' THEN 'kippnewark'
        WHEN c.business_unit = 'KIPP Cooper Norcross Academy' THEN 'kippcamden'
        WHEN c.business_unit = 'KIPP Miami' THEN 'kippmiami'
       END AS [db_name]
      ,CASE WHEN c.position_status NOT IN ('Terminated', 'Prestart') THEN 1 ELSE 0 END AS is_active

      ,s.ps_school_id AS primary_site_schoolid
      ,s.reporting_school_id AS primary_site_reporting_schoolid
      ,s.school_level AS primary_site_school_level
      ,s.is_campus AS is_campus_staff

      ,m.employee_number AS manager_employee_number
      ,m.associate_id AS manager_associate_id
      ,m.preferred_first_name AS manager_preferred_first_name
      ,m.preferred_last_name AS manager_preferred_last_name
      ,m.preferred_last_name + ', ' + m.preferred_first_name AS manager_name
FROM clean_staff c
LEFT JOIN gabby.people.school_crosswalk s
  ON c.[location] = s.site_name
 AND s._fivetran_deleted = 0
LEFT JOIN clean_staff m
  ON c.reports_to_associate_id = m.associate_id
