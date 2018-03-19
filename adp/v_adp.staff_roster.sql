USE gabby
GO
 
CREATE OR ALTER VIEW adp.staff_roster AS

WITH clean_people AS (
  SELECT sub.associate_id
        ,sub.first_name
        ,sub.last_name
        ,sub.preferred_name
        ,sub.maiden_name
        ,sub.eeo_ethnic_code
        ,sub.eeo_ethnic_description
        ,sub.gender
        ,sub.primary_address_city
        ,sub.primary_address_state_territory_code
        ,sub.primary_address_zip_postal_code
        ,sub.personal_contact_personal_mobile
        ,sub.subject_dept_custom
        ,sub.manager_secondary_custom
        ,sub.grades_taught_custom
        ,sub.birth_date
        ,sub.hire_date
        ,sub.rehire_date
        ,sub.position_id
        ,sub.salesforce_job_position_name_custom
        ,sub.job_title_description
        ,sub.job_title_custom
        ,sub.position_status
        ,sub.location_code
        ,sub.location_description
        ,sub.location_custom
        ,sub.home_department_code
        ,sub.home_department_description
        ,sub.reports_to_position_id
        ,sub.reports_to_name
        ,sub.years_of_service
        ,sub.termination_reason_code
        ,sub.termination_reason_description
        ,sub.spun_off_merged_employee
        ,sub.worker_category_code
        ,sub.worker_category_description
        ,sub.benefits_eligibility_class_description
        ,sub.payroll_company_code
        ,sub.flsa_code
        ,sub.flsa_description
        ,sub.this_is_a_management_position
        ,sub.manager_custom_assoc_id
        ,sub.position_start_date
        ,sub.termination_date
        ,sub.spin_off_merge_date
        ,sub.is_management
        ,sub.is_merged
        ,COALESCE(
           LTRIM(RTRIM(CASE
                        WHEN CHARINDEX(',',sub.preferred_name) = 0 AND CHARINDEX(' ',sub.preferred_name) = 0 THEN SUBSTRING(sub.preferred_name, 1, LEN(sub.preferred_name))
                        WHEN CHARINDEX(',',sub.preferred_name) = 0 AND CHARINDEX(' ',sub.preferred_name) > 0 THEN SUBSTRING(sub.preferred_name, 1, CHARINDEX(' ',sub.preferred_name))
                        WHEN CHARINDEX(',',sub.preferred_name) > 0 THEN SUBSTRING(sub.preferred_name, CHARINDEX(',',sub.preferred_name) + 1, LEN(sub.preferred_name))
                       END)) 
          ,sub.first_name) AS preferred_first
        ,COALESCE(
           LTRIM(RTRIM(CASE
                        WHEN CHARINDEX(',',sub.preferred_name) = 0 AND CHARINDEX(' ',sub.preferred_name) = 0 THEN NULL
                        WHEN CHARINDEX(',',sub.preferred_name) = 0 AND CHARINDEX(' ',sub.preferred_name) > 0 THEN SUBSTRING(sub.preferred_name, CHARINDEX(' ',sub.preferred_name) + 1, LEN(sub.preferred_name))
                        WHEN CHARINDEX(',',sub.preferred_name) > 0 THEN SUBSTRING(sub.preferred_name, 1, CHARINDEX(',',sub.preferred_name) - 1)
                       END))
          ,sub.last_name) AS preferred_last

        ,ROW_NUMBER() OVER(
           PARTITION BY sub.associate_id
             ORDER BY sub.position_status ASC
                     ,sub.position_start_date DESC
                     ,sub.termination_date DESC) AS rn_curr
        ,ROW_NUMBER() OVER(
           PARTITION BY sub.associate_id
             ORDER BY sub.position_status DESC
                     ,sub.position_start_date ASC
                     ,sub.termination_date ASC) AS rn_base     
  FROM
      (
       SELECT CONVERT(VARCHAR(125),associate_id) AS associate_id
             ,CONVERT(VARCHAR(125),first_name) AS first_name
             ,CONVERT(VARCHAR(125),last_name) AS last_name
             ,CONVERT(VARCHAR(125),preferred_name) AS preferred_name
             ,CONVERT(VARCHAR(125),maiden_name) AS maiden_name
             ,CONVERT(INT,eeo_ethnic_code) AS eeo_ethnic_code
             ,CONVERT(VARCHAR(125),eeo_ethnic_description) AS eeo_ethnic_description
             ,CONVERT(VARCHAR(125),gender) AS gender
             ,CONVERT(VARCHAR(125),primary_address_city) AS primary_address_city
             ,CONVERT(VARCHAR(125),primary_address_state_territory_code) AS primary_address_state_territory_code
             ,CONVERT(VARCHAR(125),primary_address_zip_postal_code) AS primary_address_zip_postal_code
             ,CONVERT(VARCHAR(125),personal_contact_personal_mobile) AS personal_contact_personal_mobile
             ,CONVERT(VARCHAR(125),subject_dept_custom) AS subject_dept_custom
             ,CONVERT(VARCHAR(125),manager_secondary_custom) AS manager_secondary_custom
             ,CONVERT(VARCHAR(125),grades_taught_custom) AS grades_taught_custom
             ,CONVERT(VARCHAR(125),position_id) AS position_id
             ,CONVERT(VARCHAR(125),salesforce_job_position_name_custom) AS salesforce_job_position_name_custom
             ,CONVERT(VARCHAR(125),job_title_description) AS job_title_description
             ,CONVERT(VARCHAR(125),job_title_custom) AS job_title_custom
             ,CONVERT(VARCHAR(125),position_status) AS position_status
             ,CONVERT(VARCHAR(125),location_code) AS location_code
             ,CONVERT(VARCHAR(125),location_description) AS location_description
             ,CONVERT(VARCHAR(125),location_custom) AS location_custom
             ,CONVERT(VARCHAR(125),home_department_code) AS home_department_code
             ,CONVERT(VARCHAR(125),home_department_description) AS home_department_description
             ,CONVERT(VARCHAR(125),reports_to_position_id) AS reports_to_position_id
             ,CONVERT(VARCHAR(125),reports_to_name) AS reports_to_name
             ,CONVERT(VARCHAR(125),years_of_service) AS years_of_service
             ,CONVERT(VARCHAR(125),termination_reason_code) AS termination_reason_code
             ,CONVERT(VARCHAR(125),termination_reason_description) AS termination_reason_description
             ,CONVERT(VARCHAR(125),spun_off_merged_employee) AS spun_off_merged_employee
             ,CONVERT(VARCHAR(125),worker_category_code) AS worker_category_code
             ,CONVERT(VARCHAR(125),worker_category_description) AS worker_category_description
             ,CONVERT(VARCHAR(125),benefits_eligibility_class_description) AS benefits_eligibility_class_description
             ,CONVERT(VARCHAR(125),payroll_company_code) AS payroll_company_code
             ,CONVERT(VARCHAR(125),flsa_code) AS flsa_code
             ,CONVERT(VARCHAR(125),flsa_description) AS flsa_description
             ,CONVERT(VARCHAR(125),this_is_a_management_position) AS this_is_a_management_position
             ,CONVERT(VARCHAR(125),manager_custom_assoc_id) AS manager_custom_assoc_id    
             ,CONVERT(DATE,adp.birth_date) AS birth_date
             ,CONVERT(DATE,adp.hire_date) AS hire_date
             ,CONVERT(DATE,adp.rehire_date) AS rehire_date
             ,CONVERT(DATE,adp.position_start_date) AS position_start_date      
             ,CONVERT(DATE,adp.termination_date) AS termination_date                  
             ,CONVERT(DATE,adp.spin_off_merge_date) AS spin_off_merge_date
             --,education_level_code
             --,education_level_description        
             ,CASE 
               WHEN adp.this_is_a_management_position = 'Yes' THEN 1
               WHEN adp.this_is_a_management_position = 'No' THEN 0
              END AS is_management
             ,CASE 
               WHEN adp.spun_off_merged_employee = 'Yes' THEN 1 
               WHEN adp.spun_off_merged_employee = 'No' THEN 0
              END AS is_merged                   
       FROM gabby.adp.export_people_details adp WITH(NOLOCK)
      ) sub
 )

SELECT sub.associate_id
      ,sub.first_name
      ,sub.last_name
      ,sub.preferred_name
      ,sub.maiden_name
      ,sub.eeo_ethnic_code
      ,sub.eeo_ethnic_description
      ,sub.gender
      ,sub.primary_address_city
      ,sub.primary_address_state_territory_code
      ,sub.primary_address_zip_postal_code
      ,sub.personal_contact_personal_mobile
      ,sub.subject_dept_custom
      ,sub.manager_secondary_custom
      ,sub.grades_taught_custom
      ,sub.birth_date
      ,sub.hire_date
      ,sub.rehire_date
      ,sub.position_id
      ,sub.salesforce_job_position_name_custom
      ,sub.job_title_description
      ,sub.job_title_custom
      ,sub.position_status
      ,sub.location_code
      ,sub.location_description
      ,sub.location_custom
      ,sub.home_department_code
      ,sub.home_department_description
      ,sub.reports_to_position_id
      ,sub.reports_to_name
      ,sub.years_of_service
      ,sub.termination_reason_code
      ,sub.termination_reason_description
      ,sub.spun_off_merged_employee
      ,sub.worker_category_code
      ,sub.worker_category_description
      ,sub.benefits_eligibility_class_description
      ,sub.payroll_company_code
      ,sub.flsa_code
      ,sub.flsa_description
      ,sub.this_is_a_management_position
      ,sub.manager_custom_assoc_id
      ,sub.position_start_date
      ,sub.termination_date
      ,sub.spin_off_merge_date
      ,sub.is_management
      ,sub.is_merged
      ,sub.preferred_first
      ,sub.preferred_last
      ,sub.rn_curr
      ,sub.rn_base

      ,m.preferred_first AS manager_preferred_first
      ,m.preferred_last AS manager_preferred_last
      ,m.preferred_last + ', ' + m.preferred_first AS manager_name
FROM clean_people sub
LEFT OUTER JOIN clean_people m
  ON sub.manager_custom_assoc_id = m.associate_id
 AND m.rn_curr = 1