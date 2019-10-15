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
      ,[salesforce_id]
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
      ,[tfa_cm_or_alum]
      ,[is_alum]
      ,[miami_esol_endorsement]
      ,[miami_statement_eligibility]
      ,[miami_esol_expiry]
      ,[miami_statement_eligibility_expiry]
      ,[miami_ACES_number]
      ,[additional_cert_yn]
      ,[additional_certs]
      ,[alternate_route_currently_enrolled]
      ,[cert1_state]
      ,[cert1_expiry]
      ,[cert1_subject]
      ,[cert1_type]
      ,[cert1_grade_level]
      ,[cert2_state]
      ,[cert2_expiry]
      ,[cert2_subject]
      ,[cert2_grade_level]
      ,[you_Route_Program]
      ,[alternate_route]
      ,[miami_cert_leadership_exams]
      ,[nj_sped_course_credits]
      ,[undergrad_gpa]
      ,[praxis_passed]
      ,[highest_education_level]
FROM
    (
     SELECT sub.employee_reference_code
           ,sub.property_name
           ,sub.property_value

           ,sy.academic_year
     FROM
         (
          SELECT CONVERT(VARCHAR(25),employee_reference_code) AS employee_reference_code
                ,CONVERT(DATE,employee_property_value_effective_start) AS effective_start_date
                ,CONVERT(DATE,COALESCE(CASE 
                                        WHEN employee_property_value_effective_end = '' THEN GETDATE() 
                                        ELSE employee_property_value_effective_end 
                                       END
                                      ,GETDATE())) AS effective_end_date
                ,CONVERT(VARCHAR(25),LOWER(CASE
                                            WHEN employee_property_value_name IN ('Grade Taught', 'Subject')
                                                   THEN CONCAT(REPLACE(employee_property_value_name, ' ', '_') 
                                                              ,'_'
                                                              ,REPLACE(property_value, ' ', '_'))
                                            WHEN employee_property_value_name = 'Are you a TFA Corps Member or Alumni?'
                                                   THEN 'tfa_cm_or_alum'
                                            WHEN employee_property_value_name = 'Is Alum?' THEN 'is_alum'
                                            WHEN employee_property_value_name = '(KIPP Miami) Do you have an ESOL Endorsement?' THEN 'miami_esol_endorsement'
                                            WHEN employee_property_value_name = '(KIPP Miami) If working toward cert, Statement of Eligibility?' THEN 'miami_statement_eligibility'
                                            WHEN employee_property_value_name = '(KIPP Miami) If yes for prev, what is expiry date of ESOL?' THEN 'miami_esol_expiry'
                                            WHEN employee_property_value_name = '(KIPP Miami) If yes for prev, what is expiry Statement of Eligib' THEN 'miami_statement_eligibility_expiry'
                                            WHEN employee_property_value_name = '(KIPP Miami) What is your ACES number?' THEN 'miami_ACES_number'
                                            WHEN employee_property_value_name = 'Additional Certificates:  Do you have any additional cert?' THEN 'additional_cert_yn'
                                            WHEN employee_property_value_name = 'Additional Certificates:  If yes, please list additional certs' THEN 'additional_certs'
                                            WHEN employee_property_value_name = 'Are you currently enrolled in an Alternate Route Program?' THEN 'alternate_route_currently_enrolled'
                                            WHEN employee_property_value_name = 'Certificate 1: In which State to do you hold a Certificate?' THEN 'cert1_state'
                                            WHEN employee_property_value_name = 'Certificate 1: What is the expiry date of your certificate?' THEN 'cert1_expiry'
                                            WHEN employee_property_value_name = 'Certificate 1: What is the subject listed on your certificate?' THEN 'cert1_subject'
                                            WHEN employee_property_value_name = 'Certificate 1: What type of Certificate do you have?' THEN 'cert1_type'
                                            WHEN employee_property_value_name = 'Certificate 1:What is the grade level listed on the certificate?' THEN 'cert1_grade_level'
                                            WHEN employee_property_value_name = 'Certificate 2: In which State to do you hold a Certificate?' THEN 'cert2_state'
                                            WHEN employee_property_value_name = 'Certificate 2: What is the expiry date of your certificate?' THEN 'cert2_expiry'
                                            WHEN employee_property_value_name = 'Certificate 2: What is the subject listed on your certificate?' THEN 'cert2_subject'
                                            WHEN employee_property_value_name = 'Certificate 2:What is the grade level listed on the certificate?' THEN 'cert2_grade_level'
                                            WHEN employee_property_value_name = 'Have you completed an Alternate Route Program?' THEN 'you_Route_Program'
                                            WHEN employee_property_value_name = 'If currently enrolled in Alternate Route Program, which one?' THEN 'alternate_route'
                                            WHEN employee_property_value_name = 'If you''ve passed FL Certification/Leadership exams, which ones?' THEN 'miami_cert_leadership_exams'
                                            WHEN employee_property_value_name = 'NJ Only - Do you have 20-27 course credits in special education?' THEN 'nj_sped_course_credits'
                                            WHEN employee_property_value_name = 'Undergraduate GPA (type number or N/A)' THEN 'undergrad_gpa'
                                            WHEN employee_property_value_name = 'Which Praxis exam(s) have you passed?' THEN 'praxis_passed'
                                            WHEN employee_property_value_name = 'Highest Grade Completed' THEN 'highest_education_level'
                                            ELSE REPLACE(employee_property_value_name, ' ', '_')
                                           END)) AS property_name
                ,CONVERT(VARCHAR(25),CASE
                                      WHEN employee_property_value_name IN ('Grade Taught', 'Subject') THEN '1'
                                      ELSE property_value
                                     END) AS property_value
          FROM gabby.dayforce.employee_properties
         ) sub
     JOIN academic_years sy
       ON sy.academic_year BETWEEN gabby.utilities.DATE_TO_SY(sub.effective_start_date) AND gabby.utilities.DATE_TO_SY(sub.effective_end_date)
    ) sub
PIVOT(
  MAX(property_value)
  FOR property_name IN ([salesforce_id]
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
                       ,[tfa_cm_or_alum]
                       ,[is_alum]
                       ,[miami_esol_endorsement]
                       ,[miami_statement_eligibility]
                       ,[miami_esol_expiry]
                       ,[miami_statement_eligibility_expiry]
                       ,[miami_ACES_number]
                       ,[additional_cert_yn]
                       ,[additional_certs]
                       ,[alternate_route_currently_enrolled]
                       ,[cert1_state]
                       ,[cert1_expiry]
                       ,[cert1_subject]
                       ,[cert1_type]
                       ,[cert1_grade_level]
                       ,[cert2_state]
                       ,[cert2_expiry]
                       ,[cert2_subject]
                       ,[cert2_grade_level]
                       ,[you_Route_Program]
                       ,[alternate_route]
                       ,[miami_cert_leadership_exams]
                       ,[nj_sped_course_credits]
                       ,[undergrad_gpa]
                       ,[praxis_passed]
                       ,[highest_education_level])
 ) p