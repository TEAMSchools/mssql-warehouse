CREATE OR ALTER VIEW titan.income_form_data_clean AS

SELECT student_identifier
      ,reference_code
      ,CONVERT(DATE, date_signed) AS date_signed
      ,CONVERT(INT, LEFT(academic_year, 4)) AS academic_year_clean
      ,eligibility_result
      ,CASE
        WHEN eligibility_result = '1' THEN 'F'
        WHEN eligibility_result = '2' THEN 'R'
        WHEN eligibility_result = '3' THEN 'P'
        ELSE CONVERT(VARCHAR(1), eligibility_result)
       END AS eligibility_name
      ,ROW_NUMBER() OVER(
         PARTITION BY student_identifier, academic_year 
           ORDER BY CONVERT(DATE, date_signed) DESC, eligibility_result DESC) AS rn
FROM titan.income_form_data
