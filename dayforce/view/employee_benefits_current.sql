CREATE OR ALTER VIEW
  dayforce.employee_benefits_current AS
SELECT
  employee_number,
  [Dental] AS dental,
  [Verizon Wireless] AS verizon_wireless,
  [Basic Life Insurance] AS basic_life,
  [Basic AD&D Insurance] AS basic_add,
  [FSA-Dep] AS fsa_dep,
  [Life & AD&D supplemental] AS life_sup,
  [Imputed Income - Life Insurance] AS imputed_income,
  [403b] AS [403b],
  [HSA] AS hsa,
  [Employee Assistance Program] AS eap,
  [Voluntary Accident Coverage] AS vol_acc,
  [Vision] AS vision,
  [Medical] AS medical,
  [FSA-HC] AS fsa_hc,
  [Voluntary Hospital Indemnity] AS vol_hos
FROM
  (
    SELECT
      sub.employee_number,
      sub.ben_plan_category,
      sub.ben_plan_option_name,
      ROW_NUMBER() OVER (
        PARTITION BY
          sub.employee_number,
          sub.ben_plan_category
        ORDER BY
          sub.ben_plan_option_effective_start
      ) AS rn_curr
    FROM
      (
        SELECT
          employee_number,
          ben_plan_option_name,
          ben_plan_option_effective_start,
          CASE
            WHEN (
              ben_plan_name = 'Aetna HDHP'
              OR ben_plan_option_name = 'Waive Medical'
            ) THEN 'Medical'
            WHEN (
              ben_plan_name IN ('Aetna PPO High', 'Aetna PPO Low')
              OR ben_plan_option_name = 'Waive Dental'
            ) THEN 'Dental'
            WHEN (
              ben_plan_name = 'Aetna Vision'
              OR ben_plan_option_name = 'Waive Vision'
            ) THEN 'Vision'
            WHEN (
              ben_plan_name = 'Alerus 403b'
              OR ben_plan_option_name LIKE 'Waive 403b%'
            ) THEN '403b'
            WHEN ben_plan_option_name IN (
              'Flexible Spending Account - Dependent Care',
              'Waive Flexible Spending Account - Dependent Care'
            ) THEN 'FSA-Dep'
            WHEN ben_plan_option_name IN (
              'Flexible Spending Account - Health Care',
              'Waive Flexible Spending Account - Health Care'
            ) THEN 'FSA-HC'
            WHEN (
              ben_plan_name = 'Health Savings Account'
              OR ben_plan_option_name = 'Waive Health Savings Account'
            ) THEN 'HSA'
            WHEN (
              ben_plan_name = 'Imputed Income - Life Insurance'
            ) THEN 'Imputed Income - Life Insurance'
            WHEN ben_plan_option_name IN (
              'Basic Supplemental AD&D (Employer)',
              'Basic Supplemental Life (Employer)',
              'Supplemental Employee Life & AD&D Insurance',
              'Waive Supplemental Employee Life and AD&D Insurance'
            ) THEN 'Life & AD&D supplemental'
            WHEN (
              ben_plan_name = 'Voluntary Accident Coverage'
              OR ben_plan_option_name = 'Waive Voluntary Accident Coverage'
            ) THEN 'Voluntary Accident Coverage'
            WHEN (
              ben_plan_name = 'Voluntary Hospital Indemnity'
              OR ben_plan_option_name = 'Waive Hospital Indemnity'
            ) THEN 'Voluntary Hospital Indemnity'
            ELSE ben_plan_name
          END AS ben_plan_category
        FROM
          dayforce.employee_benefits_options
      ) AS sub
  ) AS sub PIVOT (
    MAX(ben_plan_option_name) FOR ben_plan_category IN (
      [Dental],
      [Verizon Wireless],
      [Basic Life Insurance],
      [Basic AD&D Insurance],
      [FSA-Dep],
      [Life & AD&D supplemental],
      [Imputed Income - Life Insurance],
      [403b],
      [HSA],
      [Employee Assistance Program],
      [Voluntary Accident Coverage],
      [Vision],
      [Medical],
      [FSA-HC],
      [Voluntary Hospital Indemnity]
    )
  ) AS p
WHERE
  rn_curr = 1
