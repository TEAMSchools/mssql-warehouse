USE gabby
GO
 
ALTER VIEW adp.staff_roster AS

SELECT associate_id
      ,first_name
      ,last_name
      ,preferred_name
      ,maiden_name      
      ,eeo_ethnic_code
      ,eeo_ethnic_description
      ,gender
      ,primary_address_city
      ,primary_address_state_territory_code
      ,primary_address_zip_postal_code
      ,personal_contact_personal_mobile
      ,subject_dept_custom
      ,manager_secondary_custom
      ,grades_taught_custom
      --,education_level_code
      --,education_level_description
      ,CONVERT(DATE,birth_date) AS birth_date
      ,CONVERT(DATE,hire_date) AS hire_date
      ,CONVERT(DATE,rehire_date) AS rehire_date


      ,position_id
      ,salesforce_job_position_name_custom
      ,job_title_description
      ,job_title_custom
      ,position_status
      ,location_code
      ,location_description
      ,location_custom
      ,home_department_code
      ,home_department_description
      ,reports_to_position_id
      ,reports_to_name      
      ,years_of_service            
      ,termination_reason_code
      ,termination_reason_description
      ,spun_off_merged_employee      
      ,worker_category_code
      ,worker_category_description
      ,benefits_eligibility_class_description
      ,payroll_company_code
      ,flsa_code
      ,flsa_description
      ,this_is_a_management_position      
      ,manager_custom_assoc_id
      ,CONVERT(DATE,position_start_date) AS position_start_date      
      ,CONVERT(DATE,termination_date) AS termination_date                  
      ,CONVERT(DATE,spin_off_merge_date) AS spin_off_merge_date

      ,CASE 
        WHEN this_is_a_management_position = 'Yes' THEN 1
        WHEN this_is_a_management_position = 'No' THEN 0
       END AS is_management
      ,CASE 
        WHEN spun_off_merged_employee = 'Yes' THEN 1 
        WHEN spun_off_merged_employee = 'No' THEN 0
       END AS is_merged      
      
      ,COALESCE(
         LTRIM(RTRIM(CASE
                      WHEN CHARINDEX(',',preferred_name) = 0 AND CHARINDEX(' ',preferred_name) = 0 THEN SUBSTRING(preferred_name, 1, LEN(preferred_name))
                      WHEN CHARINDEX(',',preferred_name) = 0 AND CHARINDEX(' ',preferred_name) > 0 THEN SUBSTRING(preferred_name, 1, CHARINDEX(' ',preferred_name))
                      WHEN CHARINDEX(',',preferred_name) > 0 THEN SUBSTRING(preferred_name, CHARINDEX(',',preferred_name) + 1, LEN(preferred_name))
                     END)) 
        ,first_name) AS preferred_first
      ,COALESCE(
         LTRIM(RTRIM(CASE
                      WHEN CHARINDEX(',',preferred_name) = 0 AND CHARINDEX(' ',preferred_name) = 0 THEN NULL
                      WHEN CHARINDEX(',',preferred_name) = 0 AND CHARINDEX(' ',preferred_name) > 0 THEN SUBSTRING(preferred_name, CHARINDEX(' ',preferred_name) + 1, LEN(preferred_name))
                      WHEN CHARINDEX(',',preferred_name) > 0 THEN SUBSTRING(preferred_name, 1, CHARINDEX(',',preferred_name) - 1)
                     END))
        ,last_name) AS preferred_last
      
      ,ROW_NUMBER() OVER(
         PARTITION BY associate_id
           ORDER BY position_status ASC
                   ,CONVERT(DATE,position_start_date) DESC
                   ,CONVERT(DATE,termination_date) DESC) AS rn_curr
      ,ROW_NUMBER() OVER(
         PARTITION BY associate_id
           ORDER BY position_status DESC
                   ,CONVERT(DATE,position_start_date) ASC
                   ,CONVERT(DATE,termination_date) ASC) AS rn_base
FROM gabby.adp.export_people_details