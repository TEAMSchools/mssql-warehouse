USE gabby
GO

CREATE OR ALTER VIEW powerschool.course_enrollments AS

SELECT studentid
      ,schoolid
      ,termid
      ,cc_id
      ,course_number
      ,section_number
      ,dateenrolled
      ,dateleft
      ,lastgradeupdate
      ,sectionid
      ,expression
      ,yearid
      ,academic_year
      ,student_number
      ,credittype
      ,course_name
      ,credit_hours
      ,gradescaleid
      ,excludefromgpa
      ,excludefromstoredgrades
      ,sections_dcid
      ,teachernumber
      ,teacher_name
      ,course_enroll_status
      ,section_enroll_status
      ,map_measurementscale
      ,illuminate_subject
      ,rn_subject
      ,rn_course_yr

      ,ROW_NUMBER() OVER(
         PARTITION BY student_number, academic_year, illuminate_subject, course_enroll_status, section_enroll_status
           ORDER BY termid DESC, dateenrolled DESC, dateleft DESC) AS rn_illuminate_subject
FROM
    (
     SELECT cc.studentid
           ,cc.schoolid
           ,cc.termid
           ,cc.id AS cc_id
           ,cc.course_number
           ,cc.section_number
           ,cc.dateenrolled
           ,cc.dateleft
           ,cc.lastgradeupdate
           ,cc.sectionid
           ,cc.expression
           ,RIGHT(cc.studyear, 2) AS yearid
           ,RIGHT(cc.studyear, 2) + 1990 AS academic_year

           ,s.student_number
      
           ,cou.credittype
           ,cou.course_name
           ,cou.credit_hours
           ,cou.gradescaleid
           ,cou.excludefromgpa
           ,cou.excludefromstoredgrades      

           ,sec.dcid AS sections_dcid

           ,u.teachernumber
           ,u.lastfirst AS teacher_name
      
           ,SUM(CASE WHEN cc.sectionid < 0 THEN 1 ELSE 0 END) OVER(PARTITION BY cc.studentid, RIGHT(cc.studyear, 2), cc.course_number)
              / COUNT(cc.sectionid) OVER(PARTITION BY cc.studentid, RIGHT(cc.studyear, 2), cc.course_number) AS course_enroll_status
           ,CASE WHEN cc.sectionid < 0 THEN 1 ELSE 0 END AS section_enroll_status
      
           ,CASE
             WHEN cou.credittype IN ('ENG','READ') THEN 'Reading'
             WHEN cou.credittype = 'MATH' THEN 'Mathematics'
             WHEN cou.credittype = 'RHET' THEN 'Language Usage'
             WHEN cou.credittype = 'SCI' THEN 'Science - General Science'
            END AS map_measurementscale
           ,CASE
             WHEN s.grade_level <= 8 AND cou.credittype = 'ENG' THEN 'Text Study'        
             WHEN s.grade_level <= 8 AND cou.credittype = 'SCI' THEN 'Science'
             WHEN s.grade_level <= 8 AND cou.credittype = 'SOC' THEN 'Social Studies'        
             WHEN cc.course_number IN ('MATH10','MATH15','MATH71','MATH10ICS','MATH12','MATH12ICS','MATH14','MATH16','M415') THEN 'Algebra I'        
             WHEN cc.course_number IN ('MATH20','MATH25','MATH31','MATH73','MATH20ICS') THEN 'Geometry'
             WHEN cc.course_number IN ('MATH32','MATH35','MATH32A','MATH32HA') THEN 'Algebra IIA'
             WHEN cc.course_number IN ('MATH32B') THEN 'Algebra IIB'
             WHEN s.grade_level <= 8 AND cou.credittype = 'MATH' THEN 'Mathematics'             
             WHEN cc.course_number IN ('ENG10','ENG12','ENG15','NCCSE0010') THEN 'English 100'             
             WHEN cc.course_number IN ('ENG20','ENG22','ENG25','NCCSE0020') THEN 'English 200'
             WHEN cc.course_number IN ('ENG30','ENG32','ENG35','NCCSE0030') THEN 'English 300'
             WHEN cc.course_number IN ('ENG40','ENG42','ENG45') THEN 'English 400'
            END AS illuminate_subject
      
           ,ROW_NUMBER() OVER(
              PARTITION BY cou.credittype, cc.studentid, ABS(cc.termid), CASE WHEN cc.sectionid < 0 THEN 1 ELSE 0 END
                ORDER BY cc.termid DESC, cc.course_number DESC, cc.dateenrolled DESC, cc.dateleft DESC) AS rn_subject    
           ,ROW_NUMBER() OVER(
              PARTITION BY cc.studentid, cc.course_number, (RIGHT(cc.studyear, 2) + 1990)
                ORDER BY cc.termid DESC, cc.dateenrolled DESC, cc.dateleft DESC) AS rn_course_yr
     FROM gabby.powerschool.cc
     JOIN gabby.powerschool.students s 
       ON cc.studentid = s.id
     JOIN gabby.powerschool.courses cou
       ON cc.course_number = cou.course_number
     JOIN gabby.powerschool.sections sec
       ON ABS(cc.sectionid) = sec.id
     JOIN gabby.powerschool.schoolstaff ss
       ON cc.teacherid = ss.id
     JOIN gabby.powerschool.users u
       ON ss.users_dcid = u.dcid
    ) sub