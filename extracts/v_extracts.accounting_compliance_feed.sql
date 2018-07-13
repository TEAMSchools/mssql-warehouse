USE gabby
GO

--CREATE OR ALTER VIEW extracts.accounting_compliance_feed AS

WITH s AS
(
SELECT *
FROM
(
SELECT number
       ,effective_start AS last_status_or_salary_change
       ,base_salary AS base_salary_curr
       ,status AS status_curr
       ,LAG(base_salary,1,0) OVER(partition by number ORDER BY effective_start) AS base_salary_prev
      ,LAG(status,1,0) OVER(partition by number ORDER BY effective_start) AS status_prev
       ,ROW_NUMBER() OVER(partition by number ORDER BY effective_start DESC) AS rn_curr
FROM dayforce.employee_status
) sub

WHERE rn_curr = 1
)

,p AS
(
SELECT employee_reference_code
      ,employee_property_value_effective_start AS pension_start_date
      ,RIGHT(employee_property_value_name,4) AS pension_type
      ,property_value AS pension_number
      ,rn_curr
FROM (
     SELECT *
           ,ROW_NUMBER() OVER( 
                PARTITION BY employee_reference_code, employee_property_value_name order by employee_property_value_effective_start) AS rn_curr
     FROM dayforce.employee_properties
     ) sub
WHERE rn_curr = 1
  AND employee_property_value_name IN 
              ('Pension Number - DCRP'
              ,'Pension Number - PERS'
              ,'Pension Number - TPAF')
)

SELECT r.df_employee_number
      ,r.first_name
      ,r.last_name
      ,r.original_hire_date
      ,r.rehire_date
      ,r.status
      ,r.status_reason
      ,r.legal_entity_name
      ,r.primary_site
      ,r.primary_on_site_department
      ,r.primary_job
      ,r.job_family
      ,r.payclass

      ,s.last_status_or_salary_change
      ,s.base_salary_curr
      ,s.base_salary_prev
      ,s.status_curr
      ,s.status_prev
      
      --employee_benefits_options queries will go here
      
FROM dayforce.staff_roster r LEFT OUTER JOIN s ON
          r.df_employee_number = s.number
     LEFT OUTER JOIN p ON
          r.df_employee_number = p.employee_reference_code
--     LEFT OUTER JOIN dayforce.employee_benefits_options b
--          r.df_employee_number = b.employee_number