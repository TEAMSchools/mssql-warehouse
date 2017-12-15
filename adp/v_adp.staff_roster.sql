USE gabby
GO
 
CREATE OR ALTER VIEW adp.staff_roster AS

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
      
      ,mgr.displayname AS manager_name
      ,mgr.samaccountname AS manager_username
FROM gabby.adp.export_people_details adp
LEFT OUTER JOIN gabby.adsi.user_attributes mgr
  ON adp.manager_custom_assoc_id = mgr.idautopersonalternateid