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
                 END
               + '/' 
               + CASE 
                  WHEN co.school_name = 'TEAM' THEN 'TEAM Academy'
                  WHEN co.school_name = 'KSA' THEN 'Sunrise Academy'
                  WHEN co.school_name = 'NLH' THEN 'Newark Lab'
                  WHEN co.school_name = 'URA' THEN 'Upper Roseville'
                  WHEN co.school_name = 'NCP' THEN 'Newark Community'
                  WHEN co.school_name = 'LIB' THEN 'Liberty Academy'
                  ELSE co.school_name
                 END
           END AS org
      ,co.student_web_id + '@teamstudents.org' AS email
      ,co.student_web_password AS [password]
      ,CASE
        WHEN co.region = 'TEAM' THEN 'group-students-newark@teamstudents.org'
        WHEN co.region = 'KCNA' THEN 'group-students-camden@teamstudents.org'
        WHEN co.region = 'KMS' THEN 'group-students-miami@teamstudents.org'
       END AS group_email
FROM gabby.powerschool.cohort_identifiers_static co
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1
  AND co.student_web_id IS NOT NULL