USE gabby
GO

ALTER VIEW powerschool.course_enrollments AS

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

      ,cou.credittype
      ,cou.course_name
      ,cou.credit_hours
      ,cou.gradescaleid
      ,cou.excludefromgpa
      ,cou.excludefromstoredgrades
      ,REPLACE(ROUND(cc.termid, -2), '00', '') AS yearid

      ,sec.dcid AS sections_dcid

      ,t.teachernumber
      ,t.lastfirst AS teacher_name
      
      ,SUM(CASE WHEN cc.sectionid < 0 THEN 1 ELSE 0 END) OVER(PARTITION BY cc.studentid, ROUND(ABS(cc.termid), -2), cc.course_number)
         / COUNT(cc.sectionid) OVER(PARTITION BY cc.studentid, ROUND(ABS(cc.termid), -2), cc.course_number) AS course_enroll_status
      ,CASE WHEN cc.sectionid < 0 THEN 1 ELSE 0 END AS section_enroll_status
      
      ,CASE
        WHEN cou.credittype IN ('ENG','READ') THEN 'Reading'
        WHEN cou.credittype = 'MATH' THEN 'Mathematics'
        WHEN cou.credittype = 'RHET' THEN 'Language Usage'
        WHEN cou.credittype = 'SCI' THEN 'Science - General Science'
       END AS map_measurementscale
      ,CASE
        WHEN sec.grade_level <= 8 AND cou.CREDITTYPE = 'ENG' THEN 'Text Study'
        WHEN sec.grade_level <= 8 AND cou.CREDITTYPE = 'MATH' THEN 'Mathematics'
        WHEN sec.grade_level <= 8 AND cou.CREDITTYPE = 'SCI' THEN 'Science'
        WHEN sec.grade_level <= 8 AND cou.CREDITTYPE = 'SOC' THEN 'Social Studies'
        WHEN cc.course_number IN ('ENG10') THEN 'English 100'
        WHEN cc.course_number IN ('ENG20', 'ENG25') THEN 'English 200'
        WHEN cc.course_number IN ('ENG30', 'ENG35') THEN 'English 300'
        WHEN cc.course_number IN ('ENG40', 'ENG45') THEN 'English 400 / 450'
        WHEN cc.course_number IN ('ENG75', 'ENG78') THEN 'English Foundations'
        WHEN cc.course_number IN ('MATH13') THEN 'Pre-Algebra'
        WHEN cc.course_number IN ('MATH10') THEN 'Algebra'        
        WHEN cc.course_number IN ('MATH20', 'MATH22', 'MATH25', 'MATH73') THEN 'Geometry'        
        WHEN cc.course_number IN ('MATH32', 'MATH35') THEN 'Algebra II'
        WHEN cc.course_number IN ('MATH40') THEN 'Pre Calculus'
        WHEN cc.course_number IN ('MATH33') THEN 'Discrete Math'
        WHEN cc.course_number IN ('MATH45') THEN 'Statistics AP'
        WHEN cc.course_number IN ('SCI10') THEN 'Intro to Engineering'
        WHEN cc.course_number IN ('SCI20', 'SCI25') THEN 'Biology'
        WHEN cc.course_number IN ('SCI30', 'SCI32', 'SCI35') THEN 'Chemistry'
        WHEN cc.course_number IN ('SCI31', 'SCI36') THEN 'Physics'
        WHEN cc.course_number IN ('SCI40') THEN 'Environmental Science'
        WHEN cc.course_number IN ('SCI41') THEN 'Anatomy and Physiology'
        WHEN cc.course_number IN ('SCI43') THEN 'Electronics and Magnetism'
        WHEN cc.course_number IN ('SCI70') THEN 'Lab Skills'        
        WHEN cc.course_number IN ('SCI75') THEN 'Life Science'
        WHEN cc.course_number IN ('HIST10', 'HIST11', 'HIST70') THEN 'Global Studies/ AWH'
        WHEN cc.course_number IN ('HIST20', 'HIST25') THEN 'Modern World History'
        WHEN cc.course_number IN ('HIST71', 'HIST30', 'HIST35') THEN 'US History'
        WHEN cc.course_number IN ('HIST40', 'HIST45') THEN 'Comparative Government'
        WHEN cc.course_number IN ('HIST41') THEN 'Sociology'
        WHEN cc.course_number IN ('FREN10', 'FREN11', 'FREN12', 'FREN20', 'FREN30') THEN 'French'
        WHEN cc.course_number IN ('SPAN10', 'SPAN11', 'SPAN20', 'SPAN30', 'SPAN12', 'SPAN40') THEN 'Spanish'
        WHEN cc.course_number IN ('ARAB20') THEN 'Arabic'
       END AS illuminate_subject
      --,ROW_NUMBER() OVER(
      --   PARTITION BY cou.credittype
      --               ,cc.studentid                     
      --               ,ABS(cc.termid)
      --               ,CASE WHEN cc.termid < 0 THEN 1 ELSE 0 END
      --     ORDER BY cc.termid DESC
      --             ,cc.course_number DESC
      --             ,cc.dateenrolled DESC
      --             ,cc.dateleft DESC) AS rn_subject    
FROM powerschool.cc
JOIN powerschool.courses cou
  ON cc.course_number = cou.course_number
JOIN powerschool.sections sec
  ON ABS(cc.sectionid) = sec.id
JOIN powerschool.teachers t WITH(NOEXPAND)
  ON cc.teacherid = t.id