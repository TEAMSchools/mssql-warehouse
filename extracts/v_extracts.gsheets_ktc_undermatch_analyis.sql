USE gabby
GO

CREATE OR ALTER VIEW extracts.gsheets_ktc_undermatch_analyis AS

WITH apps AS (
  SELECT a.applicant_c AS contact_id
        ,a.application_status_c AS application_status

        ,ac.[name] AS school_name
        ,ac.[type] AS school_type
        ,ac.[description] AS school_description
        ,ac.adjusted_6_year_minority_graduation_rate_c AS adjusted_6_year_minority_graduation_rate

        ,rt.[name] AS record_type_name

        ,ROW_NUMBER() OVER(PARTITION BY a.applicant_c ORDER BY ac.adjusted_6_year_minority_graduation_rate_c DESC) AS rn_grad_rate
  FROM gabby.alumni.application_c a
  LEFT JOIN gabby.alumni.account ac
    ON a.school_c = ac.id
   AND ac.is_deleted = 0
  LEFT JOIN gabby.alumni.record_type rt
    ON ac.record_type_id = rt.id
  WHERE a.is_deleted = 0
    AND a.application_status_c IN ('Conditionally Accepted','Accepted')
    AND rt.[name] != 'High School'
 )

SELECT c.id AS salesforce_contact_id
      ,c.[name] AS student_name
      ,c.kipp_hs_class_c AS kipp_hs_class
      ,c.kipp_region_name_c AS kipp_region_name
      ,c.currently_enrolled_school_c AS currently_enrolled_school
      ,c.current_kipp_student_c AS current_kipp_student
      ,c.expected_hs_graduation_c AS expected_hs_graduation
      ,c.college_match_display_gpa_c AS college_match_display_gpa
      ,c.highest_act_score_c AS highest_act_score

      ,a.school_name
      ,a.school_type
      ,a.application_status
      ,a.adjusted_6_year_minority_graduation_rate
      ,a.school_description
      ,a.record_type_name
FROM gabby.alumni.contact c
LEFT JOIN apps a
  ON c.id = a.contact_id
 AND a.rn_grad_rate = 1
WHERE c.is_deleted = 0