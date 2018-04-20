USE gabby
GO
 
CREATE OR ALTER VIEW dayforce.staff_roster AS

WITH clean_people AS (
  SELECT CONVERT(INT,e.df_employee_number) AS df_employee_number /* new */
        ,CONVERT(VARCHAR(25),e.adp_associate_id) AS adp_associate_id /* new */
        ,CONVERT(VARCHAR(25),e.salesforce_id) AS salesforce_id /* new */
        ,CONVERT(VARCHAR(25),e.first_name) AS first_name
        ,CONVERT(VARCHAR(25),e.last_name) AS last_name        
        ,CONVERT(VARCHAR(125),e.address) AS address /* new */
        ,CONVERT(VARCHAR(125),e.city) AS city
        ,CONVERT(VARCHAR(5),e.state) AS state
        ,CONVERT(VARCHAR(25),e.postal_code) AS postal_code
        ,CONVERT(VARCHAR(25),e.status) AS status
        ,CONVERT(VARCHAR(25),e.status_reason) AS status_reason
        ,CONVERT(VARCHAR(5),e.is_manager) AS is_manager        
        ,CONVERT(VARCHAR(125),e.primary_job) AS primary_job
        ,CONVERT(VARCHAR(125),e.primary_on_site_department) AS primary_on_site_department
        ,CONVERT(VARCHAR(125),e.legal_entity_name) AS legal_entity_name /* different */
        ,CONVERT(VARCHAR(25),e.job_family) AS job_family /* different */        
        ,CONVERT(INT,e.employee_s_manager_s_df_emp_number_id) AS manager_df_employee_number
        ,CONVERT(VARCHAR(5),e.payclass) AS payclass /* different */
        ,CONVERT(VARCHAR(25),e.paytype) AS paytype /* new */
        ,CONVERT(VARCHAR(25),e.jobs_and_positions_flsa_status) AS flsa_status /* new */                        
        ,e.birth_date
        ,e.original_hire_date
        ,e.termination_date
        ,e.rehire_date
        ,e.position_effective_from_date
        ,e.annual_salary /* new */
        ,NULL AS grades_taught /* no data in export */
        ,NULL AS subjects_taught /* no data in export */
        ,NULL AS leadership_role /* no data in export */
        ,NULL AS position_effective_to_date /* no data in export */

        ,CONVERT(VARCHAR(1),UPPER(e.gender)) AS gender
        ,CONVERT(VARCHAR(25),COALESCE(e.common_name, e.first_name)) AS preferred_first_name
        ,CONVERT(VARCHAR(25),COALESCE(e.preferred_last_name , e.last_name)) AS preferred_last_name
        ,CONVERT(VARCHAR(125),REPLACE(e.primary_site, ' - Regional', '')) AS primary_site
        ,CONVERT(VARCHAR(125),RTRIM(LEFT(e.ethnicity, CHARINDEX(' (', e.ethnicity)))) AS primary_ethnicity        
        ,CONVERT(VARCHAR(25),gabby.utilities.STRIP_CHARACTERS(mobile_number, '^0-9')) AS mobile_number
        ,CASE WHEN e.ethnicity LIKE '%(Hispanic%' THEN 1 ELSE 0 END AS is_hispanic
        ,CASE WHEN e.primary_site LIKE ' - Regional' THEN 1 ELSE 0 END AS is_regional_staff        
        ,CASE
          WHEN e.legal_entity_name = 'TEAM Academy Charter Schools' THEN 'YHD'
          WHEN e.legal_entity_name = 'KIPP New Jersey' THEN 'D30'
          WHEN e.legal_entity_name = 'KIPP Cooper Norcross Academy' THEN 'D3Z'          
         END AS payroll_company_code        

        ,CONVERT(VARCHAR(125),position_title) AS position_title /* new -- redundant combined field */
        ,CONVERT(VARCHAR(125),primary_on_site_department_entity_) AS primary_on_site_department_entity /* new -- redundant combined field */
        ,CONVERT(VARCHAR(125),primary_site_entity_) AS primary_site_entity /* new -- redundant combined field */
  FROM gabby.dayforce.employees e
 )

SELECT c.df_employee_number
      ,c.adp_associate_id
      ,c.salesforce_id
      ,c.first_name
      ,c.last_name
      ,c.gender
      ,c.primary_ethnicity
      ,c.is_hispanic      
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
      ,c.is_regional_staff
      ,c.legal_entity_name
      ,c.job_family
      ,c.position_effective_from_date
      ,c.position_effective_to_date
      ,c.manager_df_employee_number
      ,c.payroll_company_code
      ,c.payclass
      ,c.paytype
      ,c.flsa_status
      ,c.annual_salary
      ,c.grades_taught
      ,c.subjects_taught
      ,c.position_title
      ,c.primary_on_site_department_entity
      ,c.primary_site_entity
      ,c.preferred_last_name + ', ' + c.preferred_first_name AS preferred_name
      ,SUBSTRING(c.mobile_number, 1, 3) + '-' 
         + SUBSTRING(c.mobile_number, 4, 3) + '-' 
         + SUBSTRING(c.mobile_number, 7, 4) AS mobile_number
      ,CASE
        WHEN c.primary_site = '18th Ave Campus' THEN 0
        WHEN c.primary_site = 'Room 9 - 60 Park Pl' THEN 0
        WHEN c.primary_site = 'Room 10 - 740 Chestnut St' THEN 0
        WHEN c.primary_site = 'Room 11 - 6745 NW 23rd Ave' THEN 0
        WHEN c.primary_site = 'KIPP BOLD Academy' THEN 73258
        WHEN c.primary_site = 'KIPP Lanning Sq Campus' THEN 0
        WHEN c.primary_site = 'KIPP Lanning Square Middle' THEN 179902
        WHEN c.primary_site = 'KIPP Lanning Square Primary' THEN 179901
        WHEN c.primary_site = 'KIPP Life Academy' THEN 73257
        WHEN c.primary_site = 'KIPP Newark Collegiate Academy' THEN 73253
        WHEN c.primary_site = 'KIPP Pathways at 18th Ave' THEN 73258
        WHEN c.primary_site = 'KIPP Pathways at Bragaw' THEN 73257
        WHEN c.primary_site = 'KIPP Rise Academy' THEN 73252        
        WHEN c.primary_site = 'KIPP Seek Academy' THEN 73256
        WHEN c.primary_site = 'KIPP SPARK Academy' THEN 73254
        WHEN c.primary_site = 'KIPP TEAM Academy' THEN 133570965
        WHEN c.primary_site = 'KIPP THRIVE Academy' THEN 73255
        WHEN c.primary_site = 'KIPP Whittier Middle' THEN 179903
       END AS primary_site_schoolid
      ,CASE        
        WHEN c.primary_site = 'Room 9 - 60 Park Pl' THEN 0
        WHEN c.primary_site = 'Room 10 - 740 Chestnut St' THEN 0
        WHEN c.primary_site = 'Room 11 - 6745 NW 23rd Ave' THEN 0        
        WHEN c.primary_site = 'KIPP Lanning Sq Campus' THEN 0
        WHEN c.primary_site = '18th Ave Campus' THEN 0
        WHEN c.primary_site = 'KIPP BOLD Academy' THEN 73258        
        WHEN c.primary_site = 'KIPP Lanning Square Middle' THEN 179902
        WHEN c.primary_site = 'KIPP Lanning Square Primary' THEN 179901
        WHEN c.primary_site = 'KIPP Life Academy' THEN 73257
        WHEN c.primary_site = 'KIPP Newark Collegiate Academy' THEN 73253
        WHEN c.primary_site = 'KIPP Pathways at 18th Ave' THEN 732585074
        WHEN c.primary_site = 'KIPP Pathways at Bragaw' THEN 732574573
        WHEN c.primary_site = 'KIPP Rise Academy' THEN 73252                
        WHEN c.primary_site = 'KIPP Seek Academy' THEN 73256
        WHEN c.primary_site = 'KIPP SPARK Academy' THEN 73254
        WHEN c.primary_site = 'KIPP TEAM Academy' THEN 133570965
        WHEN c.primary_site = 'KIPP THRIVE Academy' THEN 73255
        WHEN c.primary_site = 'KIPP Whittier Middle' THEN 179903
       END AS primary_site_reporting_schoolid
      ,CASE        
        WHEN c.primary_site IN ('KIPP Lanning Square Primary','KIPP Life Academy','KIPP Pathways at Bragaw','KIPP Seek Academy','KIPP SPARK Academy','KIPP THRIVE Academy') THEN 'ES'
        WHEN c.primary_site IN ('KIPP BOLD Academy','KIPP Lanning Square Middle','KIPP Pathways at 18th Ave','KIPP Rise Academy','KIPP TEAM Academy','KIPP Whittier Middle') THEN 'MS'
        WHEN c.primary_site = 'KIPP Newark Collegiate Academy' THEN 'HS'
       END AS primary_site_school_level

      ,m.adp_associate_id AS manager_adp_associate_id
      ,m.preferred_first_name AS manager_preferred_first_name
      ,m.preferred_last_name AS manager_preferred_last_name
      ,m.preferred_last_name + ', ' + m.preferred_first_name AS manager_name
FROM clean_people c
LEFT JOIN clean_people m
  ON c.manager_df_employee_number = m.df_employee_number