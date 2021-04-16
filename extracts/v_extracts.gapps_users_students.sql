USE gabby
GO

CREATE OR ALTER VIEW extracts.gapps_users_students AS

SELECT sub.student_number
      ,sub.school_level
      ,sub.schoolid
      ,sub.first_name AS firstname
      ,sub.last_name AS lastname
      ,sub.suspended
      ,sub.email
      ,sub.student_web_password AS [password]
      ,sub.group_email
      ,CASE WHEN sub.school_level IN ('MS','HS') THEN 'on' ELSE 'off' END AS changepassword
      ,'/Students/'
         + CASE
            WHEN sub.suspended = 'on' THEN 'Disabled'
            WHEN sub.school_name = 'Out of District' THEN 'Disabled'
            ELSE sub.region + '/' + sub.school_name
           END AS org
FROM
    (
     SELECT s.student_number
           ,s.schoolid
           ,s.first_name
           ,s.last_name
           ,CASE WHEN s.enroll_status = 0 THEN 'off' ELSE 'on' END AS suspended
           ,CASE
             WHEN s.[db_name] = 'kippcamden' THEN 'KCNA'
             WHEN s.[db_name] = 'kippnewark' THEN 'TEAM'
             WHEN s.[db_name] = 'kippmiami' THEN 'Miami'
            END AS region
           ,CASE
             WHEN s.[db_name] = 'kippnewark' THEN 'group-students-newark@teamstudents.org'
             WHEN s.[db_name] = 'kippcamden' THEN 'group-students-camden@teamstudents.org'
             WHEN s.[db_name] = 'kippmiami' THEN 'group-students-miami@teamstudents.org'
            END AS group_email

           ,CASE
             WHEN sp.specprog_name = 'Out of District' THEN 'OD'
             WHEN sch.high_grade = 12 THEN 'HS'
             WHEN sch.high_grade = 8 THEN 'MS'
             WHEN sch.high_grade = 4 THEN 'ES'
             ELSE 'OD'
            END AS school_level
           ,CASE
             WHEN sp.specprog_name = 'Out of District' THEN sp.specprog_name
             WHEN sch.abbreviation = 'TEAM' THEN 'TEAM Academy'
             WHEN sch.abbreviation = 'KSA' THEN 'Sunrise Academy'
             WHEN sch.abbreviation = 'NLH' THEN 'Newark Lab'
             WHEN sch.abbreviation = 'URA' THEN 'Upper Roseville'
             WHEN sch.abbreviation = 'NCP' THEN 'Newark Community'
             WHEN sch.abbreviation = 'LIB' THEN 'Liberty Academy'
             WHEN sch.abbreviation = 'COU' THEN 'Courage'
             ELSE sch.abbreviation
            END AS school_name
           ,sch.abbreviation
           ,sch.name

           ,saa.student_web_id + '@teamstudents.org' AS email
           ,saa.student_web_password
     FROM gabby.powerschool.students s
     LEFT JOIN powerschool.spenrollments_gen_static sp
       ON s.id = sp.studentid
      AND s.entrydate BETWEEN sp.enter_date AND sp.exit_date
      AND s.[db_name] = sp.[db_name]
      AND sp.specprog_name IN ('Out of District', 'Self-Contained Special Education', 'Pathways ES', 'Pathways MS', 'Whittier ES')
     JOIN gabby.powerschool.schools sch
       ON s.schoolid = sch.school_number
      AND s.[db_name] = sch.[db_name]
     JOIN gabby.powerschool.student_access_accounts_static saa
       ON s.student_number = saa.student_number
    ) sub
