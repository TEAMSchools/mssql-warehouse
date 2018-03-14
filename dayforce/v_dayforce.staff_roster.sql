USE gabby
GO
 
CREATE OR ALTER VIEW dayforce.staff_roster AS

WITH clean_people AS (
  SELECT CONVERT(INT,e.df_employee_number) AS df_employee_number /* new */
        ,CONVERT(VARCHAR(25),e.employee_property_xref_code_5) AS adp_associate_id /* new */
        ,NULL AS salesforce_id /* no data in export */
        ,CONVERT(VARCHAR(25),e.first_name) AS first_name
        ,CONVERT(VARCHAR(25),e.last_name) AS last_name                
        ,CONVERT(VARCHAR(1),UPPER(gender)) AS gender
        ,CONVERT(VARCHAR(125),e.ethinicity) AS ethinicity                          
        ,e.mobile_number
        ,CONVERT(VARCHAR(125),e.address) AS address /* new */
        ,CONVERT(VARCHAR(125),e.city) AS city
        ,CONVERT(VARCHAR(5),e.state) AS state
        ,CONVERT(VARCHAR(25),e.postal_code) AS postal_code            
        ,e.birth_date
        ,e.original_hire_date             
        ,e.termination_date
        ,e.rehire_date             
        ,CONVERT(VARCHAR(25),e.status) AS status
        ,CONVERT(VARCHAR(25),e.status_reason) AS status_reason                                        
        ,CONVERT(VARCHAR(5),is_manager) AS is_manager
        ,NULL AS leadership_role /* no data in export */          
        ,COALESCE(CONVERT(VARCHAR(25),e.common_name), CONVERT(VARCHAR(25),e.first_name)) AS preferred_first_name
        ,COALESCE(e.preferred_last_name , CONVERT(VARCHAR(25),e.last_name)) AS preferred_last_name
             
        ,CONVERT(VARCHAR(125),e.primary_job) AS primary_job             
        ,CONVERT(VARCHAR(125),e.primary_on_site_department) AS primary_on_site_department             
        ,CONVERT(VARCHAR(125),e.primary_site) AS primary_site             
        ,CONVERT(VARCHAR(125),e.legal_entity_name) AS legal_entity_name /* different */                                       
        ,CONVERT(VARCHAR(25),e.job_family) AS job_family /* different */                      
        ,e.position_effective_from_date
        ,NULL AS position_effective_to_date /* no data in export */
        ,CONVERT(INT,e.employee_s_manager_s_df_emp_number_id) AS manager_df_employee_number             
        ,CONVERT(VARCHAR(5),e.payclass) AS payclass /* different */             
        ,CONVERT(VARCHAR(25),paytype) AS paytype /* new */
        ,NULL AS flsa_status /* no data in export */
        ,e.annual_salary /* new */                                       
        ,e.grades_taught
        ,e.subjects_taught

        --,CONVERT(VARCHAR(125),position_title) AS position_title /* new */
        --,CONVERT(VARCHAR(125),primary_on_site_department_entity_) AS primary_on_site_department_entity /* new */
        --,CONVERT(VARCHAR(125),primary_site_entity_) AS primary_site_entity /* new */             
  FROM gabby.dayforce.employees e
 )

SELECT c.df_employee_number
      ,c.adp_associate_id
      ,c.salesforce_id
      ,c.first_name
      ,c.last_name
      ,c.gender
      ,c.ethinicity
      ,c.mobile_number
      ,c.address
      ,c.city
      ,c.state
      ,c.postal_code
      ,c.birth_date
      ,c.original_hire_date
      ,c.termination_date
      ,c.rehire_date
      ,c.status
      ,c.status_reason
      ,c.is_manager
      ,c.leadership_role
      ,c.preferred_first_name
      ,c.preferred_last_name
      ,c.primary_job
      ,c.primary_on_site_department
      ,c.primary_site
      ,c.legal_entity_name
      ,c.job_family
      ,c.position_effective_from_date
      ,c.position_effective_to_date
      ,c.manager_df_employee_number
      ,c.payclass
      ,c.paytype
      ,c.flsa_status
      ,c.annual_salary
      ,c.grades_taught
      ,c.subjects_taught

      ,m.preferred_first_name AS manager_preferred_first_name
      ,m.preferred_last_name AS manager_preferred_last_name
      ,m.preferred_last_name + ', ' + m.preferred_first_name AS manager_name
FROM clean_people c
LEFT JOIN clean_people m
  ON c.manager_df_employee_number = m.df_employee_number