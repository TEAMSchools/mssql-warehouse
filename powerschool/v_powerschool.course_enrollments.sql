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
          SELECT CONVERT(INT,cc.studentid) AS studentid
                ,CONVERT(INT,cc.schoolid) AS schoolid
                ,CONVERT(INT,cc.termid) AS termid           
                ,CONVERT(INT,cc.id) AS cc_id
                ,cc.course_number_clean AS course_number
                ,CONVERT(VARCHAR(25),cc.section_number) AS section_number
                ,cc.dateenrolled
                ,cc.dateleft
                ,NULL AS lastgradeupdate
                ,CONVERT(INT,cc.sectionid) AS sectionid
                ,CONVERT(VARCHAR(25),cc.expression) AS expression
                ,ABS(CONVERT(INT,cc.termid)) AS abs_termid
                ,cc.abs_sectionid
                ,cc.yearid
                ,cc.academic_year
                ,CASE WHEN cc.sectionid < 0 THEN 1 ELSE 0 END AS section_enroll_status

                ,CONVERT(INT,s.student_number) AS student_number
                ,CONVERT(INT,s.dcid) AS students_dcid
      
                ,CONVERT(VARCHAR(25),cou.credittype) AS credittype
                ,CONVERT(VARCHAR(125),cou.course_name) AS course_name
                ,cou.credit_hours                
                ,CONVERT(INT,cou.excludefromgpa) AS excludefromgpa
                ,CONVERT(INT,cou.excludefromstoredgrades) AS excludefromstoredgrades           
                ,CONVERT(INT,cou.gradescaleid) AS courses_gradescaleid
                ,CASE
                  WHEN cou.credittype IN ('ENG','READ') THEN 'Reading'
                  WHEN cou.credittype = 'MATH' THEN 'Mathematics'
                  WHEN cou.credittype = 'RHET' THEN 'Language Usage'
                  WHEN cou.credittype = 'SCI' THEN 'Science - General Science'
                 END AS map_measurementscale

                ,CONVERT(VARCHAR(25),t.teachernumber) AS teachernumber
                ,CONVERT(VARCHAR(125),t.lastfirst) AS teacher_name

                ,CONVERT(INT,sec.dcid) AS sections_dcid               
                
                ,CASE
                  WHEN cc.course_number_clean IN ('MATH10','MATH15','MATH71','MATH10ICS','MATH12','MATH12ICS','MATH14','MATH16','M415'
                                                 ,'MAT02052F1','MAT02052G1','MAT02052P1','MAT02052H4') THEN 'Algebra I'
                  WHEN cc.course_number_clean IN ('MATH20','MATH25','MATH31','MATH73','MATH20ICS','MAT02072F2','MAT02072G2') THEN 'Geometry'
                  WHEN cc.course_number_clean IN ('MAT02056F3','MAT02056G3') THEN 'Algebra II'
                  WHEN cc.course_number_clean IN ('MATH32','MATH35','MATH32A','MATH32HA') THEN 'Algebra IIA'
                  WHEN cc.course_number_clean IN ('MATH32B') THEN 'Algebra IIB'
                  WHEN cc.course_number_clean = 'MAT02110G4' THEN 'Pre-Calculus'                  
                  WHEN cc.course_number_clean IN ('ENG10','ENG12','ENG15','NCCSE0010','ENG01051A1','ENG01051F1','ENG01051G1','ENG01051P1') THEN 'English 100'             
                  WHEN cc.course_number_clean IN ('ENG20','ENG22','ENG25','NCCSE0020','ENG01051A2','ENG01051F2','ENG01051G2') THEN 'English 200'
                  WHEN cc.course_number_clean IN ('ENG30','ENG32','ENG35','NCCSE0030','ENG01005C3','ENG01052F3','ENG01052G3') THEN 'English 300'
                  WHEN cc.course_number_clean IN ('ENG40','ENG42','ENG45','ENG01006C4','ENG01052F4','ENG01052G4') THEN 'English 400'
                  WHEN cc.course_number_clean = 'M315' THEN NULL /* ignore MS Pre-Algebra */
                  WHEN sec.grade_level <= 8 AND cou.credittype = 'ENG' THEN 'Text Study'        
                  WHEN sec.grade_level <= 8 AND cou.credittype = 'SCI' THEN 'Science'
                  WHEN sec.grade_level <= 8 AND cou.credittype = 'SOC' THEN 'Social Studies'        
                  WHEN sec.grade_level <= 8 AND cou.credittype = 'MATH' THEN 'Mathematics'             
                 END AS illuminate_subject
          FROM powerschool.cc
          JOIN powerschool.students s 
            ON cc.studentid = s.id
          JOIN powerschool.courses cou
            ON cc.course_number_clean = cou.course_number_clean
          JOIN powerschool.teachers_static t
            ON cc.teacherid = t.id          
          JOIN powerschool.sections sec
            ON cc.abs_sectionid = sec.id
         ) sub
    ) sub