USE gabby
GO

CREATE OR ALTER VIEW dayforce.employee_properties_wide AS

WITH academic_years AS (
  SELECT n AS academic_year
  FROM gabby.utilities.row_generator
  WHERE n BETWEEN 2000 AND gabby.utilities.GLOBAL_ACADEMIC_YEAR()
 )

SELECT employee_reference_code
      ,academic_year      
      ,[grade_taught_kindergarten]
      ,[grade_taught_grade_1]
      ,[grade_taught_grade_2]
      ,[grade_taught_grade_3]
      ,[grade_taught_grade_4]
      ,[grade_taught_grade_5]
      ,[grade_taught_grade_6]
      ,[grade_taught_grade_7]
      ,[grade_taught_grade_8]
      ,[grade_taught_grade_9]
      ,[grade_taught_grade_10]
      ,[grade_taught_grade_11]
      ,[grade_taught_grade_12]    
FROM
    (
     SELECT sub.employee_reference_code
           ,sub.property_value
           ,1 AS n      

           ,sy.academic_year
     FROM
         (
          SELECT CONVERT(VARCHAR(25),employee_reference_code) AS employee_reference_code
                ,CONVERT(DATE,employee_property_value_effective_start) AS effective_start_date
                ,CONVERT(DATE,COALESCE(employee_property_value_effective_end, GETDATE())) AS effective_end_date
                ,CONVERT(VARCHAR(25),LOWER(CONCAT(REPLACE(employee_property_value_name, ' ', '_') 
                                                 ,'_'
                                                 ,REPLACE(property_value, ' ', '_')))) AS property_value
          FROM gabby.dayforce.employee_properties
          WHERE employee_property_value_name IN ('Grade Taught', 'Subject')
         ) sub
     JOIN academic_years sy
       ON sy.academic_year BETWEEN gabby.utilities.DATE_TO_SY(sub.effective_start_date) AND gabby.utilities.DATE_TO_SY(sub.effective_end_date)
    ) sub
PIVOT(
  MAX(n)
  FOR property_value IN ([grade_taught_kindergarten]
                        ,[grade_taught_grade_1]
                        ,[grade_taught_grade_2]
                        ,[grade_taught_grade_3]
                        ,[grade_taught_grade_4]
                        ,[grade_taught_grade_5]
                        ,[grade_taught_grade_6]
                        ,[grade_taught_grade_7]
                        ,[grade_taught_grade_8]
                        ,[grade_taught_grade_9]
                        ,[grade_taught_grade_10]
                        ,[grade_taught_grade_11]
                        ,[grade_taught_grade_12])
 ) p