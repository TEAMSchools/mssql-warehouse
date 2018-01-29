USE gabby
GO

CREATE OR ALTER VIEW powerschool.course_section_scaffold AS 

WITH course_scaffold AS (
  SELECT studentid
        ,student_number
        ,yearid
        ,term_name
        ,course_number
        ,excludefromgpa
        ,CASE 
          WHEN CONVERT(DATE,GETDATE()) BETWEEN term_start_date AND term_end_date THEN 1
          WHEN term_end_date <= CONVERT(DATE,GETDATE()) AND term_start_date = MAX(term_start_date) OVER(PARTITION BY studentid, yearid, course_number) THEN 1
          ELSE 0
         END AS is_curterm
  FROM
      (
       SELECT DISTINCT 
              enr.studentid
             ,enr.student_number
             ,enr.yearid           
             ,enr.course_number
             ,enr.excludefromgpa

             ,CONVERT(VARCHAR(25),terms.alt_name) AS term_name
             ,terms.start_date AS term_start_date
             ,terms.end_date AS term_end_date
       FROM gabby.powerschool.course_enrollments_static enr
       JOIN gabby.powerschool.schools
         ON enr.schoolid = schools.school_number
        AND schools.high_grade >= 8
       JOIN gabby.reporting.reporting_terms terms  
         ON enr.yearid = terms.yearid
        AND enr.schoolid = terms.schoolid
        AND terms.identifier = 'RT'
        AND terms.alt_name NOT IN ('Summer School','Capstone','EOY')
       WHERE enr.dateenrolled <= CONVERT(DATE,GETDATE())
         AND enr.course_enroll_status = 0
         AND enr.section_enroll_status = 0
      ) sub
 )

,section_scaffold AS (  
  SELECT studentid
        ,course_number
        ,yearid
        ,abs_sectionid
        ,term_name
        ,ROW_NUMBER() OVER(
           PARTITION BY studyear, course_number, term_name
             ORDER BY dateleft DESC, sectionid DESC) AS rn_term
  FROM
      (
       SELECT CONVERT(INT,cc.studentid) AS studentid
             ,CONVERT(INT,cc.studyear) AS studyear
             ,CONVERT(VARCHAR(25),cc.course_number) AS course_number
             ,CONVERT(INT,cc.sectionid) AS sectionid
             ,cc.dateleft
             ,CONVERT(INT,LEFT(ABS(cc.termid), 2)) AS yearid      
             ,CONVERT(INT,ABS(cc.sectionid)) AS abs_sectionid
      
             ,CASE WHEN terms.alt_name = 'Summer School' THEN 'Q1' ELSE CONVERT(VARCHAR,terms.alt_name) END AS term_name        
       FROM gabby.powerschool.cc
       JOIN gabby.reporting.reporting_terms terms
         ON cc.schoolid = terms.schoolid         
        AND cc.dateenrolled BETWEEN terms.start_date AND terms.end_date
        AND terms.identifier = 'RT'   
        AND terms.school_level IN ('MS','HS')
       WHERE cc.dateenrolled <= CONVERT(DATE,GETDATE())
      ) sub
 )

SELECT cs.studentid
      ,cs.student_number
      ,cs.yearid
      ,cs.term_name
      ,cs.is_curterm
      ,cs.course_number      
      ,cs.excludefromgpa

      ,COALESCE(ss.abs_sectionid
               ,LAG(ss.abs_sectionid, 1) OVER(PARTITION BY cs.studentid, cs.yearid, cs.course_number ORDER BY cs.term_name)
               ,LAG(ss.abs_sectionid, 2) OVER(PARTITION BY cs.studentid, cs.yearid, cs.course_number ORDER BY cs.term_name)
               ,LAG(ss.abs_sectionid, 3) OVER(PARTITION BY cs.studentid, cs.yearid, cs.course_number ORDER BY cs.term_name)) AS sectionid
FROM course_scaffold cs
LEFT OUTER JOIN section_scaffold ss
  ON cs.studentid = ss.studentid
 AND cs.yearid = ss.yearid
 AND cs.term_name = ss.term_name
 AND cs.course_number = ss.course_number
 AND ss.rn_term = 1