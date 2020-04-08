SELECT *
FROM
    (
     SELECT DISTINCT 
            CONCAT(CASE
                    WHEN s.[db_name] = 'kippnewark' THEN 'nwk'
                    WHEN s.[db_name] = 'kippcamden' THEN 'cmd'
                    WHEN s.[db_name] = 'kippmiami' THEN 'mia'
                   END
                  ,cc.teacherid
                  ,cc.course_number_clean) AS alias

           ,sas.student_web_id + '@teamstudents.org' AS email
     FROM gabby.powerschool.cc
     JOIN gabby.powerschool.courses c
       ON cc.course_number_clean = c.course_number_clean
      AND cc.[db_name] = c.[db_name]
      AND c.credittype != 'LOG'
     JOIN gabby.powerschool.terms t
       ON cc.termid = t.id
      AND cc.schoolid = t.schoolid
      AND cc.[db_name] = t.[db_name]
      AND t.[name] IN ('2019-2020', 'Quarter 3', 'Quarter 4', 'Semester 2')
     JOIN gabby.powerschool.students s
       ON cc.studentid = s.id
      AND cc.[db_name] = s.[db_name]
      AND s.enroll_status = 0
     JOIN gabby.powerschool.student_access_accounts_static sas
       ON s.student_number = sas.student_number
     WHERE cc.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
       AND cc.sectionid > 0
    ) sub
WHERE sub.alias IN ('nwk11280HR', 'mia620HR')
