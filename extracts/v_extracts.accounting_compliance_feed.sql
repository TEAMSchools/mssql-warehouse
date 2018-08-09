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

,b AS
(SELECT TOP 100 *
      ,ROW_NUMBER() OVER
        (PARTITION BY employee_number, category
         ORDER BY ben_plan_option_effective_start) AS rn_curr 
FROM 
     (SELECT *
             ,CASE WHEN ben_plan_name = 'Aetna HDHP' OR ben_plan_option_name = 'Waive Medical' THEN 'Medical'
                   WHEN ben_plan_name IN ('Aetna PPO High', 'Aetna PPO Low') OR ben_plan_option_name = 'Waive Denatl' THEN 'Dental'
                   WHEN ben_plan_name = 'Aetna Vision' OR ben_plan_option_name = 'Waive Vision' THEN 'Vision'
                   WHEN ben_plan_name = 'Alerus 403b' OR ben_plan_option_name LIKE 'Waive 403b%' THEN '403b'
                   WHEN ben_plan_option_name IN ('Flexible Spending Account - Dependent Care',  'Waive Flexible Spending Account - Dependent Care') THEN 'FSA-Dep'
                   WHEN ben_plan_option_name IN ('Flexible Spending Account - Health Care', 'Waive Flexible Spending Account - Health Care') THEN 'FSA-HC'
                   WHEN ben_plan_name = 'Health Savings Account' OR ben_plan_option_name = 'Waive Health Savings Account' THEN 'HSA'
                   WHEN ben_plan_name = 'Imputed Income - Life Insurance' THEN 'Imputed Income - Life Insurance'
                   WHEN ben_plan_option_name IN ('Basic Supplemental AD&D (Employer)' ,'Basic Supplemental Life (Employer)' ,'Supplemental Employee Life & AD&D Insurance' ,'Waive Supplemental Employee Life and AD&D Insurance') THEN 'Life & AD&D supplemental'
                   WHEN ben_plan_name = 'Voluntary Accident Coverage' OR ben_plan_option_name = 'Waive Voluntary Accident Coverage' THEN 'Voluntary Accident Coverage'
                   WHEN ben_plan_name = 'Voluntary Hospital Indemnity' OR ben_plan_option_name = 'Waive Hospital Indemnity' THEN 'Voluntary Hospital Indemnity'
                   ELSE ben_plan_name
                   
                   END AS category
      FROM dayforce.employee_benefits_options) sub
(


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
--     LEFT OUTER JOIN b
--          r.df_employee_number = b.employee_number