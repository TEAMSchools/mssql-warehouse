CREATE OR ALTER VIEW powerschool.course_enrollments AS

SELECT sub.studentid
      ,sub.schoolid
      ,sub.termid
      ,sub.cc_id
      ,sub.course_number
      ,sub.section_number
      ,sub.dateenrolled
      ,sub.dateleft
      ,NULL AS lastgradeupdate
      ,sub.sectionid
      ,sub.expression
      ,sub.yearid
      ,sub.academic_year
      ,sub.student_number
      ,sub.students_dcid
      ,sub.credittype
      ,sub.course_name
      ,sub.credit_hours
      ,sub.courses_gradescaleid AS gradescaleid
      ,sub.excludefromgpa
      ,sub.excludefromstoredgrades
      ,sub.teachernumber
      ,sub.teacher_name
      ,sub.section_enroll_status
      ,sub.map_measurementscale
      ,sub.illuminate_subject
      ,sub.abs_sectionid
      ,sub.abs_termid
      ,sub.course_enroll_status
      ,sub.sections_dcid
      ,CONVERT(INT, ROW_NUMBER() OVER(
         PARTITION BY sub.studentid, sub.credittype, sub.section_enroll_status
           ORDER BY sub.termid DESC, sub.course_number DESC, sub.dateenrolled DESC, sub.dateleft DESC)) AS rn_subject
      ,CONVERT(INT, ROW_NUMBER() OVER(
         PARTITION BY sub.studentid, sub.course_number, sub.academic_year, sub.schoolid
           ORDER BY sub.termid DESC, sub.dateenrolled DESC, sub.dateleft DESC)) AS rn_course_yr
      ,CONVERT(INT, ROW_NUMBER() OVER(
         PARTITION BY sub.student_number, sub.academic_year, sub.illuminate_subject, sub.course_enroll_status, sub.section_enroll_status
           ORDER BY sub.termid DESC, sub.dateenrolled DESC, sub.dateleft DESC)) AS rn_illuminate_subject
FROM
    (
     SELECT sub.studentid
           ,sub.schoolid
           ,sub.termid
           ,sub.cc_id
           ,sub.course_number
           ,sub.section_number
           ,sub.dateenrolled
           ,sub.dateleft
           ,sub.sectionid
           ,sub.expression
           ,sub.yearid
           ,sub.academic_year
           ,sub.student_number
           ,sub.students_dcid
           ,sub.credittype
           ,sub.course_name
           ,sub.credit_hours
           ,sub.excludefromgpa
           ,sub.excludefromstoredgrades
           ,sub.teachernumber
           ,sub.teacher_name
           ,sub.section_enroll_status
           ,sub.map_measurementscale
           ,sub.illuminate_subject
           ,sub.abs_sectionid
           ,sub.abs_termid
           ,sub.sections_dcid
           ,sub.courses_gradescaleid
           ,SUM(sub.section_enroll_status) OVER(PARTITION BY sub.studentid, sub.yearid, sub.course_number)
              / COUNT(sub.sectionid) OVER(PARTITION BY sub.studentid, sub.yearid, sub.course_number) AS course_enroll_status
     FROM
         (
          SELECT CONVERT(INT, cc.studentid) AS studentid
                ,CONVERT(INT, cc.schoolid) AS schoolid
                ,CONVERT(INT, cc.termid) AS termid
                ,CONVERT(INT, cc.id) AS cc_id
                ,cc.course_number
                ,CONVERT(VARCHAR(25), cc.section_number) AS section_number
                ,cc.dateenrolled
                ,cc.dateleft
                ,CONVERT(INT, cc.sectionid) AS sectionid
                ,CONVERT(VARCHAR(25), cc.expression) AS expression
                ,ABS(CONVERT(INT, cc.termid)) AS abs_termid
                ,cc.abs_sectionid
                ,cc.yearid
                ,cc.academic_year
                ,CASE 
                  WHEN cc.sectionid < 0 AND s.enroll_status = 2 AND s.exitdate = cc.dateleft THEN 0
                  WHEN cc.sectionid < 0 THEN 1
                  ELSE 0
                 END AS section_enroll_status

                ,CONVERT(INT, s.student_number) AS student_number
                ,CONVERT(INT, s.dcid) AS students_dcid

                ,CONVERT(VARCHAR(25), cou.credittype) AS credittype
                ,CONVERT(VARCHAR(125), cou.course_name) AS course_name
                ,cou.credit_hours
                ,CONVERT(INT, cou.excludefromgpa) AS excludefromgpa
                ,CONVERT(INT, cou.excludefromstoredgrades) AS excludefromstoredgrades
                ,CONVERT(INT, cou.gradescaleid) AS courses_gradescaleid
                ,CASE
                  WHEN cou.credittype IN ('ENG','READ') THEN 'Reading'
                  WHEN cou.credittype = 'MATH' THEN 'Mathematics'
                  WHEN cou.credittype = 'RHET' THEN 'Language Usage'
                  WHEN cou.credittype = 'SCI' THEN 'Science - General Science'
                 END AS map_measurementscale

                ,t.teachernumber
                ,t.lastfirst AS teacher_name

                ,CONVERT(INT, sec.dcid) AS sections_dcid

                ,CONVERT(VARCHAR(125), sj.illuminate_subject) AS illuminate_subject
          FROM powerschool.cc
          JOIN powerschool.students s
            ON cc.studentid = s.id
          JOIN powerschool.courses cou
            ON cc.course_number = cou.course_number
          JOIN powerschool.teachers_static t
            ON cc.teacherid = t.id
          JOIN powerschool.sections sec
            ON cc.abs_sectionid = sec.id
          LEFT JOIN gabby.assessments.normed_subjects sj
            ON cc.course_number = sj.course_number COLLATE Latin1_General_BIN
           AND sj._fivetran_deleted = 0
         ) sub
    ) sub
