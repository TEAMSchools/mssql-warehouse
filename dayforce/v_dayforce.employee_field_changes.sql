USE gabby
GO

CREATE OR ALTER VIEW dayforce.employee_field_changes AS

WITH data_long AS (
  SELECT u.df_employee_number
        ,u.preferred_name
        ,u._modified
        ,u.field
        ,u.value AS new_value
        ,LAG(u.value, 1, u.value) OVER(PARTITION BY u.df_employee_number, field ORDER BY u._modified) AS previous_value
  FROM
      (
       SELECT _modified
             ,df_employee_number
             ,CONCAT(COALESCE(common_name, first_name), ' ', COALESCE(preferred_last_name, last_name)) AS preferred_name
             ,CONVERT(VARCHAR(MAX),preferred_last_name) AS preferred_last_name
             ,CONVERT(VARCHAR(MAX),common_name) AS common_name
             ,CONVERT(VARCHAR(MAX),last_name) AS last_name
             ,CONVERT(VARCHAR(MAX),first_name) AS first_name
             ,CONVERT(VARCHAR(MAX),birth_date) AS birth_date
             ,CONVERT(VARCHAR(MAX),ethnicity) AS ethnicity
             ,CONVERT(VARCHAR(MAX),gender) AS gender
             ,CONVERT(VARCHAR(MAX),original_hire_date) AS original_hire_date
             ,CONVERT(VARCHAR(MAX),primary_on_site_department_entity_) AS primary_on_site_department_entity_
             ,CONVERT(VARCHAR(MAX),primary_on_site_department) AS primary_on_site_department
             ,CONVERT(VARCHAR(MAX),primary_site_entity_) AS primary_site_entity_
             ,CONVERT(VARCHAR(MAX),primary_site) AS primary_site
             ,CONVERT(VARCHAR(MAX),legal_entity_name) AS legal_entity_name
             ,CONVERT(VARCHAR(MAX),primary_job) AS primary_job
             ,CONVERT(VARCHAR(MAX),position_title) AS position_title
             ,CONVERT(VARCHAR(MAX),position_effective_from_date) AS position_effective_from_date
             ,CONVERT(VARCHAR(MAX),status) AS status
             ,CONVERT(VARCHAR(MAX),rehire_date) AS rehire_date
             ,CONVERT(VARCHAR(MAX),termination_date) AS termination_date
             ,CONVERT(VARCHAR(MAX),status_reason) AS status_reason
             ,CONVERT(VARCHAR(MAX),mobile_number) AS mobile_number
             ,CONVERT(VARCHAR(MAX),address) AS address
             ,CONVERT(VARCHAR(MAX),city) AS city
             ,CONVERT(VARCHAR(MAX),state) AS state
             ,CONVERT(VARCHAR(MAX),postal_code) AS postal_code
             ,CONVERT(VARCHAR(MAX),paytype) AS paytype
             ,CONVERT(VARCHAR(MAX),payclass) AS payclass
             ,CONVERT(VARCHAR(MAX),jobs_and_positions_flsa_status) AS jobs_and_positions_flsa_status
             ,CONVERT(VARCHAR(MAX),is_manager) AS is_manager
             ,CONVERT(VARCHAR(MAX),employee_s_manager_s_df_emp_number_id) AS employee_s_manager_s_df_emp_number_id
             ,CONVERT(VARCHAR(MAX),salesforce_id) AS salesforce_id
             ,CONVERT(VARCHAR(MAX),adp_associate_id) AS adp_associate_id
             ,CONVERT(VARCHAR(MAX),grades_taught) AS grades_taught
             ,CONVERT(VARCHAR(MAX),job_family) AS job_family
             ,CONVERT(VARCHAR(MAX),annual_salary) AS annual_salary      
             ,CONVERT(VARCHAR(MAX),position_effective_to_date) AS position_effective_to_date
             ,CONVERT(VARCHAR(MAX),subjects_taught) AS subjects_taught
       FROM gabby.dayforce.employees_archive
      ) sub
  UNPIVOT(
    value
    FOR field IN (sub.preferred_last_name
                 ,sub.common_name
                 ,sub.last_name
                 ,sub.first_name
                 ,sub.birth_date
                 ,sub.ethnicity
                 ,sub.gender
                 ,sub.original_hire_date
                 ,sub.primary_on_site_department_entity_
                 ,sub.primary_on_site_department
                 ,sub.primary_site_entity_
                 ,sub.primary_site
                 ,sub.legal_entity_name
                 ,sub.primary_job
                 ,sub.position_title
                 ,sub.position_effective_from_date
                 ,sub.status
                 ,sub.rehire_date
                 ,sub.termination_date
                 ,sub.status_reason
                 ,sub.mobile_number
                 ,sub.address
                 ,sub.city
                 ,sub.state
                 ,sub.postal_code
                 ,sub.paytype
                 ,sub.payclass
                 ,sub.jobs_and_positions_flsa_status
                 ,sub.is_manager
                 ,sub.employee_s_manager_s_df_emp_number_id
                 ,sub.salesforce_id
                 ,sub.adp_associate_id
                 ,sub.grades_taught
                 ,sub.job_family
                 ,sub.annual_salary
                 ,sub.position_effective_to_date
                 ,sub.subjects_taught)
   ) u
 )

SELECT df.df_employee_number
      ,df.preferred_name
      ,df._modified
      ,df.field
      ,df.new_value
      ,df.previous_value
FROM data_long df
WHERE df.new_value != df.previous_value