USE gabby
GO
 
CREATE OR ALTER VIEW adp.staff_roster AS

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
      ,sub.manager_preferred_first
      ,sub.manager_preferred_last
      ,sub.manager_preferred_last + ', ' + sub.manager_preferred_first AS manager_name
FROM
    (
     SELECT adp.associate_id
           ,adp.first_name
           ,adp.last_name
           ,adp.preferred_name
           ,adp.maiden_name      
           ,adp.eeo_ethnic_code
           ,adp.eeo_ethnic_description
           ,adp.gender
           ,adp.primary_address_city
           ,adp.primary_address_state_territory_code
           ,adp.primary_address_zip_postal_code
           ,adp.personal_contact_personal_mobile
           ,adp.subject_dept_custom
           ,adp.manager_secondary_custom
           ,adp.grades_taught_custom
           --,education_level_code
           --,education_level_description
           ,CONVERT(DATE,adp.birth_date) AS birth_date
           ,CONVERT(DATE,adp.hire_date) AS hire_date
           ,CONVERT(DATE,adp.rehire_date) AS rehire_date
           ,adp.position_id
           ,adp.salesforce_job_position_name_custom
           ,adp.job_title_description
           ,adp.job_title_custom
           ,adp.position_status
           ,adp.location_code
           ,adp.location_description
           ,adp.location_custom
           ,adp.home_department_code
           ,adp.home_department_description
           ,adp.reports_to_position_id
           ,adp.reports_to_name      
           ,adp.years_of_service            
           ,adp.termination_reason_code
           ,adp.termination_reason_description
           ,adp.spun_off_merged_employee      
           ,adp.worker_category_code
           ,adp.worker_category_description
           ,adp.benefits_eligibility_class_description
           ,adp.payroll_company_code
           ,adp.flsa_code
           ,adp.flsa_description
           ,adp.this_is_a_management_position      
           ,adp.manager_custom_assoc_id
           ,CONVERT(DATE,adp.position_start_date) AS position_start_date      
           ,CONVERT(DATE,adp.termination_date) AS termination_date                  
           ,CONVERT(DATE,adp.spin_off_merge_date) AS spin_off_merge_date
           ,CASE 
             WHEN adp.this_is_a_management_position = 'Yes' THEN 1
             WHEN adp.this_is_a_management_position = 'No' THEN 0
            END AS is_management
           ,CASE 
             WHEN adp.spun_off_merged_employee = 'Yes' THEN 1 
             WHEN adp.spun_off_merged_employee = 'No' THEN 0
            END AS is_merged      
           ,COALESCE(
              LTRIM(RTRIM(CASE
                           WHEN CHARINDEX(',',adp.preferred_name) = 0 AND CHARINDEX(' ',adp.preferred_name) = 0 THEN SUBSTRING(adp.preferred_name, 1, LEN(adp.preferred_name))
                           WHEN CHARINDEX(',',adp.preferred_name) = 0 AND CHARINDEX(' ',adp.preferred_name) > 0 THEN SUBSTRING(adp.preferred_name, 1, CHARINDEX(' ',adp.preferred_name))
                           WHEN CHARINDEX(',',adp.preferred_name) > 0 THEN SUBSTRING(adp.preferred_name, CHARINDEX(',',adp.preferred_name) + 1, LEN(adp.preferred_name))
                          END)) 
             ,adp.first_name) AS preferred_first
           ,COALESCE(
              LTRIM(RTRIM(CASE
                           WHEN CHARINDEX(',',adp.preferred_name) = 0 AND CHARINDEX(' ',adp.preferred_name) = 0 THEN NULL
                           WHEN CHARINDEX(',',adp.preferred_name) = 0 AND CHARINDEX(' ',adp.preferred_name) > 0 THEN SUBSTRING(adp.preferred_name, CHARINDEX(' ',adp.preferred_name) + 1, LEN(adp.preferred_name))
                           WHEN CHARINDEX(',',adp.preferred_name) > 0 THEN SUBSTRING(adp.preferred_name, 1, CHARINDEX(',',adp.preferred_name) - 1)
                          END))
             ,adp.last_name) AS preferred_last
      
           ,ROW_NUMBER() OVER(
              PARTITION BY adp.associate_id
                ORDER BY adp.position_status ASC
                        ,CONVERT(DATE,adp.position_start_date) DESC
                        ,CONVERT(DATE,adp.termination_date) DESC) AS rn_curr
           ,ROW_NUMBER() OVER(
              PARTITION BY adp.associate_id
                ORDER BY adp.position_status DESC
                        ,CONVERT(DATE,adp.position_start_date) ASC
                        ,CONVERT(DATE,adp.termination_date) ASC) AS rn_base      
      
           ,COALESCE(
              LTRIM(RTRIM(CASE
                           WHEN CHARINDEX(',',m.preferred_name) = 0 AND CHARINDEX(' ',m.preferred_name) = 0 THEN SUBSTRING(m.preferred_name, 1, LEN(m.preferred_name))
                           WHEN CHARINDEX(',',m.preferred_name) = 0 AND CHARINDEX(' ',m.preferred_name) > 0 THEN SUBSTRING(m.preferred_name, 1, CHARINDEX(' ',m.preferred_name))
                           WHEN CHARINDEX(',',m.preferred_name) > 0 THEN SUBSTRING(m.preferred_name, CHARINDEX(',',m.preferred_name) + 1, LEN(m.preferred_name))
                          END)) 
             ,m.first_name) AS manager_preferred_first
           ,COALESCE(
              LTRIM(RTRIM(CASE
                           WHEN CHARINDEX(',',m.preferred_name) = 0 AND CHARINDEX(' ',m.preferred_name) = 0 THEN NULL
                           WHEN CHARINDEX(',',m.preferred_name) = 0 AND CHARINDEX(' ',m.preferred_name) > 0 THEN SUBSTRING(m.preferred_name, CHARINDEX(' ',m.preferred_name) + 1, LEN(m.preferred_name))
                           WHEN CHARINDEX(',',m.preferred_name) > 0 THEN SUBSTRING(m.preferred_name, 1, CHARINDEX(',',m.preferred_name) - 1)
                          END))
             ,m.last_name) AS manager_preferred_last
     FROM gabby.adp.export_people_details AS adp
     LEFT OUTER JOIN gabby.adp.export_people_details AS m
       ON adp.manager_custom_assoc_id = m.associate_id
    ) sub