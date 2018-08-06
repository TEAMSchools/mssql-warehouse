USE gabby
GO

CREATE OR ALTER VIEW extracts.gapps_users_students AS

SELECT co.student_number
      ,co.school_level
      ,co.schoolid      
      ,co.first_name AS firstname
      ,co.last_name AS lastname      
      ,CASE WHEN co.school_level IN ('MS','HS') THEN 'on' ELSE 'off' END AS changepassword
      ,CASE WHEN co.enroll_status = 0 THEN 'off' ELSE 'on' END AS suspended
      ,'/Students/' 
         + CASE 
            WHEN co.enroll_status != 0 THEN 'Disabled'
            WHEN co.school_name = 'Out of District' THEN 'Disabled'
            ELSE CASE
                  WHEN co.region = 'KCNA' THEN 'KCNA'
                  WHEN co.region = 'TEAM' THEN 'TEAM'
                  WHEN co.region = 'KMS' THEN 'Miami'
                 END + '/' + CASE 
                              WHEN co.school_name = 'TEAM' THEN 'TEAM Academy'
                              WHEN co.school_name = 'KSA' THEN 'Sunrise Academy'
                              ELSE co.school_name
                             END
           END AS org
      ,co.student_web_id + '@teamstudents.org' AS email
      ,co.student_web_password AS password
FROM gabby.powerschool.cohort_identifiers_static co
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1