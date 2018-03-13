USE gabby
GO

CREATE OR ALTER VIEW powerschool.course_enrollments AS

SELECT sub.studentid
      ,sub.schoolid
      ,sub.termid
      ,sub.cc_id
      ,sub.course_number
      ,sub.section_number
      ,sub.dateenrolled
      ,sub.dateleft
      ,sub.lastgradeupdate
      ,sub.sectionid
      ,sub.expression
      ,sub.yearid
      ,sub.academic_year
      ,sub.student_number
      ,sub.credittype
      ,sub.course_name
      ,sub.credit_hours
      ,sub.gradescaleid
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

      ,ROW_NUMBER() OVER(
         PARTITION BY sub.credittype, sub.studentid, sub.abs_termid, sub.section_enroll_status
           ORDER BY sub.termid DESC, sub.course_number DESC, sub.dateenrolled DESC, sub.dateleft DESC) AS rn_subject    
      ,ROW_NUMBER() OVER(
         PARTITION BY sub.studentid, sub.course_number, sub.academic_year
           ORDER BY sub.termid DESC, sub.dateenrolled DESC, sub.dateleft DESC) AS rn_course_yr      
      ,ROW_NUMBER() OVER(
         PARTITION BY sub.student_number, sub.academic_year, sub.illuminate_subject, sub.course_enroll_status, sub.section_enroll_status
           ORDER BY sub.termid DESC, sub.dateenrolled DESC, sub.dateleft DESC) AS rn_illuminate_subject
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
           ,sub.lastgradeupdate
           ,sub.sectionid
           ,sub.expression
           ,sub.yearid
           ,sub.academic_year
           ,sub.student_number
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
           ,SUM(sub.section_enroll_status) OVER(PARTITION BY sub.studentid, sub.yearid, sub.course_number)
              / COUNT(sub.sectionid) OVER(PARTITION BY sub.studentid, sub.yearid, sub.course_number) AS course_enroll_status
      
           ,CONVERT(INT,sec.dcid) AS sections_dcid
           
           ,CASE WHEN sec.gradescaleid = 0 THEN sub.gradescaleid ELSE CONVERT(INT,sec.gradescaleid) END AS gradescaleid
     FROM
         (
          SELECT CONVERT(INT,cc.studentid) AS studentid
                ,CONVERT(INT,cc.schoolid) AS schoolid
                ,CONVERT(INT,cc.termid) AS termid           
                ,CONVERT(INT,cc.id) AS cc_id
                ,CONVERT(VARCHAR(25),cc.course_number) AS course_number
                ,CONVERT(VARCHAR(25),cc.section_number) AS section_number
                ,cc.dateenrolled
                ,cc.dateleft
                ,cc.lastgradeupdate
                ,CONVERT(INT,cc.sectionid) AS sectionid
                ,CONVERT(VARCHAR(25),cc.expression) AS expression
                ,ABS(CONVERT(INT,cc.termid)) AS abs_termid
                ,ABS(CONVERT(INT,cc.sectionid)) AS abs_sectionid
                ,CONVERT(INT,RIGHT(cc.studyear, 2)) AS yearid
                ,RIGHT(cc.studyear, 2) + 1990 AS academic_year
                ,CASE WHEN cc.sectionid < 0 THEN 1 ELSE 0 END AS section_enroll_status

                ,CONVERT(INT,s.student_number) AS student_number
      
                ,CONVERT(VARCHAR(25),cou.credittype) AS credittype
                ,CONVERT(VARCHAR(125),cou.course_name) AS course_name
                ,cou.credit_hours
                ,CONVERT(INT,cou.gradescaleid) AS gradescaleid
                ,CONVERT(INT,cou.excludefromgpa) AS excludefromgpa
                ,CONVERT(INT,cou.excludefromstoredgrades) AS excludefromstoredgrades           
                ,CASE
                  WHEN cou.credittype IN ('ENG','READ') THEN 'Reading'
                  WHEN cou.credittype = 'MATH' THEN 'Mathematics'
                  WHEN cou.credittype = 'RHET' THEN 'Language Usage'
                  WHEN cou.credittype = 'SCI' THEN 'Science - General Science'
                 END AS map_measurementscale

                ,CONVERT(VARCHAR(25),u.teachernumber) AS teachernumber
                ,CONVERT(VARCHAR(125),u.lastfirst) AS teacher_name      
           
                ,CASE
                  WHEN s.grade_level <= 8 AND cou.credittype = 'ENG' THEN 'Text Study'        
                  WHEN s.grade_level <= 8 AND cou.credittype = 'SCI' THEN 'Science'
                  WHEN s.grade_level <= 8 AND cou.credittype = 'SOC' THEN 'Social Studies'        
                  WHEN cc.course_number IN ('MATH10','MATH15','MATH71','MATH10ICS','MATH12','MATH12ICS','MATH14','MATH16','M415') THEN 'Algebra I'        
                  WHEN cc.course_number IN ('MATH20','MATH25','MATH31','MATH73','MATH20ICS') THEN 'Geometry'
                  WHEN cc.course_number IN ('MATH32','MATH35','MATH32A','MATH32HA') THEN 'Algebra IIA'
                  WHEN cc.course_number IN ('MATH32B') THEN 'Algebra IIB'
                  WHEN cc.course_number = 'M315' THEN NULL
                  WHEN s.grade_level <= 8 AND cou.credittype = 'MATH' THEN 'Mathematics'             
                  WHEN cc.course_number IN ('ENG10','ENG12','ENG15','NCCSE0010') THEN 'English 100'             
                  WHEN cc.course_number IN ('ENG20','ENG22','ENG25','NCCSE0020') THEN 'English 200'
                  WHEN cc.course_number IN ('ENG30','ENG32','ENG35','NCCSE0030') THEN 'English 300'
                  WHEN cc.course_number IN ('ENG40','ENG42','ENG45') THEN 'English 400'
                 END AS illuminate_subject
          FROM gabby.powerschool.cc WITH(NOLOCK)
          JOIN gabby.powerschool.students s 
            ON cc.studentid = s.id
          JOIN gabby.powerschool.courses cou
            ON cc.course_number = cou.course_number     
          JOIN gabby.powerschool.schoolstaff ss
            ON cc.teacherid = ss.id
          JOIN gabby.powerschool.users u
            ON ss.users_dcid = u.dcid
         ) sub
     JOIN gabby.powerschool.sections sec
       ON sub.abs_sectionid = sec.id
    ) sub