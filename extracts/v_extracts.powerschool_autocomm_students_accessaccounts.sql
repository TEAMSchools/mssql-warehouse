USE gabby
GO

CREATE OR ALTER VIEW extracts.powerschool_autocomm_students_accessaccounts AS

SELECT co.student_number
      ,co.student_web_id
      ,co.student_web_password
      ,CASE WHEN co.enroll_status = 0 THEN 1 ELSE 0 END AS student_allowwebaccess
      ,co.student_web_id + '.fam' AS web_id
      ,co.student_web_password AS web_password
      ,CASE WHEN co.enroll_status = 0 THEN 1 ELSE 0 END AS allowwebaccess
      ,co.team
      ,CASE
        WHEN co.grade_level IN (0, 5, 9) THEN 'A'
        WHEN co.grade_level IN (1, 6, 10) THEN 'B'
        WHEN co.grade_level IN (2, 7, 11) THEN 'C'
        WHEN co.grade_level IN (3, 8, 12) THEN 'D'
        WHEN co.grade_level = 4 THEN 'E'
       END AS track

      ,t.eligibility_name
      ,t.total_balance

      ,co.advisor_name AS home_room

      ,co.[db_name]
FROM gabby.powerschool.cohort_identifiers_static co
LEFT JOIN gabby.titan.person_data_clean t
  ON co.student_number = t.person_identifier
 AND co.academic_year = t.application_academic_school_year_clean
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1
  AND co.grade_level <> 99
