USE gabby
GO

CREATE OR ALTER VIEW tableau.staff_roster AS

SELECT df.df_employee_number
      ,df.adp_associate_id AS associate_id      
      ,df.first_name
      ,df.last_name
      ,df.preferred_first_name AS preferred_first
      ,df.preferred_last_name AS preferred_last
      ,df.preferred_name
      ,NULL AS maiden_name      
      
      ,NULL AS eeo_ethnic_code
      ,df.primary_ethnicity AS eeo_ethnic_description
      ,df.is_hispanic
      ,df.gender
      ,CONVERT(DATE,df.birth_date) AS birth_date

      ,df.address
      ,df.city AS primary_address_city
      ,df.state AS primary_address_state_territory_code
      ,df.postal_code AS primary_address_zip_postal_code
      ,df.mobile_number AS personal_contact_personal_mobile      
      
      ,df.primary_on_site_department AS subject_dept_custom      
      ,df.grades_taught AS grades_taught_custom      
      ,CONVERT(DATE,df.original_hire_date) AS hire_date
      ,CONVERT(DATE,df.rehire_date) AS rehire_date                  
      ,df.primary_job AS job_title_description
      ,df.primary_job AS job_title_custom
      ,df.payroll_company_code
      ,df.legal_entity_name
      ,df.is_regional_staff
      ,df.status AS position_status      
      ,df.primary_site AS location_description
      ,df.primary_site AS location_custom      
      ,df.primary_on_site_department AS home_department_description            
      ,df.status_reason AS termination_reason_description      
      ,df.payclass AS worker_category_description
      ,df.job_family AS benefits_eligibility_class_description      
      ,df.flsa_status AS flsa_description      
      ,df.is_manager AS this_is_a_management_position
      ,df.is_manager AS is_management
      ,df.salesforce_id AS salesforce_job_position_name_custom
        
      ,df.manager_name AS reports_to_name      
      ,df.manager_df_employee_number
      ,df.manager_adp_associate_id AS manager_custom_assoc_id
      ,df.manager_name AS manager_name
      ,CONVERT(DATE,df.position_effective_from_date) AS position_start_date      
      ,CONVERT(DATE,df.termination_date) AS termination_date

      ,ad.mail
FROM gabby.dayforce.staff_roster df
LEFT JOIN gabby.adsi.user_attributes_static ad
  ON COALESCE(df.adp_associate_id, CONVERT(VARCHAR(25),df.df_employee_number)) = ad.idautopersonalternateid