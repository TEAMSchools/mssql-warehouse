CREATE OR ALTER VIEW titan.income_form_data_clean AS

SELECT student_identifier
      ,reference_code
      ,CAST(date_signed AS DATE) AS date_signed
      ,CAST(LEFT(academic_year, 4) AS INT) AS academic_year_clean
      ,eligibility_result
      ,CASE
        WHEN eligibility_result = '1' THEN 'F'
        WHEN eligibility_result = '2' THEN 'R'
        WHEN eligibility_result = '3' THEN 'P'
        ELSE CAST(eligibility_result AS VARCHAR(1))
       END AS eligibility_name
      ,ROW_NUMBER() OVER(
         PARTITION BY student_identifier, academic_year 
           ORDER BY CAST(date_signed AS DATE) DESC, eligibility_result DESC) AS rn
FROM titan.income_form_data
