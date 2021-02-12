USE gabby
GO

CREATE OR ALTER VIEW people.staff_roster AS

WITH all_staff AS (
  /* current */
  SELECT eh.employee_number
        ,eh.associate_id
        ,eh.position_id
        ,eh.termination_reason
        ,eh.job_title
        ,eh.home_department
        ,eh.reports_to_associate_id
        ,eh.position_status
        ,eh.business_unit
        ,eh.[location]
        ,eh.position_effective_start_date
        ,eh.position_effective_end_date
        ,eh.annual_salary
        ,eh.original_hire_date
        ,eh.effective_start_date
  FROM gabby.people.employment_history eh
  WHERE CONVERT(DATE, GETDATE()) BETWEEN eh.effective_start_date AND eh.effective_end_date

  UNION ALL

  /* prestart */
  SELECT ps.employee_number
        ,ps.associate_id
        ,ps.position_id
        ,ps.termination_reason
        ,ps.job_title
        ,ps.home_department
        ,ps.reports_to_associate_id
        ,'Prestart' AS position_status
        ,ps.business_unit
        ,ps.[location]
        ,ps.position_effective_start_date
        ,ps.position_effective_end_date
        ,ps.annual_salary
        ,ps.original_hire_date
        ,ps.effective_start_date
  FROM gabby.people.employment_history ps
  WHERE ps.status_effective_start_date > CONVERT(DATE, GETDATE())
    AND ps.position_status = 'Active'
    AND (ps.position_status_prev IS NULL OR ps.position_status_prev = 'Terminated')
 )

,clean_staff AS (
  SELECT sub.employee_number
        ,sub.associate_id
        ,sub.position_id
        ,sub.first_name
        ,sub.last_name
        ,sub.position_status
        ,sub.business_unit
        ,sub.[location]
        ,sub.home_department
        ,sub.job_title
        ,sub.is_manager
        ,sub.reports_to_associate_id
        ,sub.annual_salary
        ,sub.position_effective_start_date
        ,sub.position_effective_end_date
        ,sub.original_hire_date
        ,sub.rehire_date
        ,sub.termination_date
        ,sub.termination_reason
        ,sub.job_family
        ,sub.address_street
        ,sub.address_city
        ,sub.address_state
        ,sub.address_zip
        ,sub.race
        ,sub.ethnicity
        ,sub.is_hispanic
        ,sub.gender
        ,sub.preferred_gender
        ,sub.birth_date
        ,sub.personal_email
        ,sub.personal_mobile
        ,sub.wfmgr_pay_rule
        ,sub.worker_category
        ,sub.flsa
        ,sub.associate_id_legacy
        ,sub.legal_entity_name
        ,sub.legal_entity_abbreviation
        ,sub.primary_site_clean
        ,REPLACE(sub.primary_site_clean, ' - Regional', '') AS primary_site
        ,COALESCE(sub.preferred_first_name, sub.first_name) AS preferred_first_name
        ,COALESCE(sub.preferred_last_name , sub.last_name) AS preferred_last_name
        ,CASE WHEN sub.primary_site_clean LIKE '% - Regional%' THEN 1 ELSE 0 END AS is_regional_staff
        ,CASE
          WHEN sub.race = 'Hispanic or Latino' THEN 'Hispanic or Latino'
          WHEN sub.race = 'Decline to Answer' THEN NULL
          ELSE CONVERT(VARCHAR(125), RTRIM(LEFT(sub.race, CHARINDEX(' (', sub.race))))
         END AS primary_ethnicity
        ,CASE
          WHEN sub.position_status = 'Leave' THEN 'INACTIVE'
          ELSE UPPER(sub.position_status)
         END AS [status]
        /* redundant combined fields */
        ,CONCAT(sub.home_department, ' - ', sub.job_title) AS position_title
        ,sub.primary_site_clean + ' (' + sub.legal_entity_abbreviation + ') - ' + sub.home_department AS primary_on_site_department_entity
        ,sub.primary_site_clean + ' (' + sub.legal_entity_abbreviation + ')' AS primary_site_entity
  FROM
      (
       SELECT eh.employee_number
             ,eh.associate_id
             ,eh.position_id
             ,eh.termination_reason
             ,eh.job_title
             ,eh.home_department
             ,eh.reports_to_associate_id
             ,eh.position_status
             ,eh.business_unit
             ,eh.[location]
             ,eh.position_effective_start_date
             ,eh.position_effective_end_date
             ,eh.annual_salary
             ,eh.original_hire_date
             ,CONVERT(NVARCHAR(256), NULL) AS job_family -- on the way
             ,CASE 
               WHEN eh.associate_id IN (SELECT reports_to_associate_id
                                        FROM gabby.people.manager_history
                                        WHERE CONVERT(DATE, GETDATE()) BETWEEN reports_to_effective_date 
                                                                           AND reports_to_effective_end_date_eoy) THEN 1
               ELSE 0
              END AS is_manager
             /* dedupe positions */
             ,ROW_NUMBER() OVER(
                PARTITION BY eh.associate_id
                  ORDER BY CONVERT(DATE, eh.effective_start_date) DESC) AS rn

             /* transformations to match DF conventions */
             ,CASE
               WHEN eh.business_unit = 'TEAM Academy Charter' THEN 'TEAM Academy Charter Schools'
               WHEN eh.business_unit = 'KIPP TEAM and Family Schools Inc.' THEN 'KIPP New Jersey'
               ELSE eh.business_unit
              END AS legal_entity_name
             ,CASE
               WHEN eh.business_unit = 'TEAM Academy Charter' THEN 'TEAM'
               WHEN eh.business_unit = 'KIPP TEAM and Family Schools Inc.' THEN 'KNJ'
               WHEN eh.business_unit = 'KIPP Cooper Norcross Academy' THEN 'KCNA'
               WHEN eh.business_unit = 'KIPP Miami' THEN 'MIA'
              END AS legal_entity_abbreviation
             ,CASE 
               WHEN eh.[location] = 'Norfolk St. Campus' THEN 'Norfolk St Campus'
               WHEN eh.[location] = 'KIPP Lanning Square Campus' THEN 'KIPP Lanning Sq Campus'
               ELSE eh.[location]
              END AS primary_site_clean

             ,ea.first_name
             ,ea.last_name
             ,ea.preferred_name AS preferred_first_name
             ,ea.primary_address_city AS address_city
             ,ea.primary_address_state_territory_code AS address_state
             ,ea.primary_address_zip_postal_code AS address_zip
             ,ea.race_description AS race
             ,ea.personal_contact_personal_email AS personal_email
             ,ea.ethnicity
             ,ea.preferred_gender
             /* transformations */
             ,CONVERT(DATE, ea.birth_date) AS birth_date
             ,LEFT(UPPER(ea.gender), 1) AS gender
             ,CASE 
               WHEN ea.primary_address_address_line_1 IS NOT NULL 
                    THEN CONCAT(ea.primary_address_address_line_1, ', ' + ea.primary_address_address_line_2)
              END AS address_street
             ,CONVERT(NVARCHAR(256), gabby.utilities.STRIP_CHARACTERS(ea.personal_contact_personal_mobile, '^0-9')) AS personal_mobile
             ,CASE
               WHEN ea.ethnicity = 'Hispanic or Latino' THEN 1
               WHEN ea.ethnicity = 'Not Hispanic or Latino' THEN 0
              END AS is_hispanic

             ,p.wfmgr_pay_rule
             ,p.worker_category_description AS worker_category
             ,p.flsa_description AS flsa
             ,CONVERT(DATE, p.rehire_date) AS rehire_date
             ,CONVERT(DATE, p.termination_date) AS termination_date

             ,df.preferred_last_name -- use DF until ADP available

             ,cw.adp_associate_id AS associate_id_legacy
       FROM all_staff eh
       JOIN gabby.adp.employees_all ea
         ON eh.associate_id = ea.associate_id
       LEFT JOIN gabby.adp.employees p
         ON eh.position_id = p.position_id
       LEFT JOIN gabby.dayforce.employees df /* temporary for preferred last name */
         ON eh.employee_number= df.df_employee_number
       LEFT JOIN gabby.people.id_crosswalk_adp cw
         ON eh.employee_number = cw.df_employee_number
        AND cw.rn_curr = 1
       WHERE eh.employee_number IS NOT NULL
      ) sub
  WHERE rn = 1
 )

SELECT c.employee_number
      ,c.associate_id
      ,c.position_id
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
      ,c.original_hire_date
      ,c.rehire_date
      ,c.termination_date
      ,c.termination_reason
      ,c.job_family
      ,c.address_street
      ,c.address_city
      ,c.address_state
      ,c.address_zip
      ,c.race
      ,c.ethnicity
      ,c.is_hispanic
      ,c.gender
      ,c.preferred_gender
      ,c.birth_date
      ,c.personal_email
      ,c.wfmgr_pay_rule
      ,c.worker_category
      ,c.flsa
      ,c.associate_id_legacy
      ,c.preferred_first_name
      ,c.preferred_last_name
      ,c.legal_entity_name
      ,c.legal_entity_abbreviation
      ,c.primary_site_clean
      ,c.primary_site
      ,c.is_regional_staff
      ,c.primary_ethnicity
      ,c.[status]
      ,c.position_title
      ,c.primary_on_site_department_entity
      ,c.primary_site_entity
      ,c.preferred_last_name + ', ' + c.preferred_first_name AS preferred_name
      ,SUBSTRING(c.personal_mobile, 1, 3) + '-'
         + SUBSTRING(c.personal_mobile, 4, 3) + '-'
         + SUBSTRING(c.personal_mobile, 7, 4) AS personal_mobile
      ,CASE
        WHEN c.business_unit = 'KIPP TEAM and Family Schools Inc.' THEN '9AM'
        WHEN c.business_unit = 'TEAM Academy Charter' THEN '2Z3'
        WHEN c.business_unit = 'KIPP Cooper Norcross Academy' THEN '3LE'
        WHEN c.business_unit = 'KIPP Miami' THEN '47S'
       END AS payroll_company_code
      ,CASE
        WHEN c.business_unit = 'TEAM Academy Charter' THEN 'kippnewark'
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
