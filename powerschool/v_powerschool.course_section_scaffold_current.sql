CREATE OR ALTER VIEW powerschool.course_section_scaffold_current AS 

WITH course_scaffold AS (
  SELECT studentid
        ,student_number
        ,yearid
        ,term_name
        ,course_number
        ,course_name
        ,credittype
        ,credit_hours        
        ,excludefromgpa
        ,gradescaleid
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
             ,enr.course_name
             ,enr.credittype
             ,enr.credit_hours             
             ,enr.excludefromgpa
             ,enr.gradescaleid

             ,CONVERT(VARCHAR(25),terms.alt_name) COLLATE Latin1_General_BIN AS term_name
             ,terms.start_date AS term_start_date
             ,terms.end_date AS term_end_date
       FROM powerschool.course_enrollments_static enr
       JOIN powerschool.schools
         ON enr.schoolid = schools.school_number
        AND schools.high_grade >= 8
       JOIN gabby.reporting.reporting_terms terms  
         ON enr.yearid = terms.yearid
        AND enr.schoolid = terms.schoolid
        AND terms.identifier = 'RT'
        AND terms.alt_name NOT IN ('Summer School','Capstone','EOY')
       WHERE enr.dateenrolled BETWEEN DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1) AND CONVERT(DATE,GETDATE())
         AND enr.course_enroll_status = 0
         AND enr.section_enroll_status = 0
      ) sub
 )

,section_scaffold AS (  
  SELECT studentid
        ,course_number
        ,yearid
        ,abs_sectionid
        ,gradescaleid
        ,term_name
        ,ROW_NUMBER() OVER(
           PARTITION BY studentid, yearid, course_number, term_name
             ORDER BY dateleft DESC, sectionid DESC) AS rn_term
  FROM
      (
       SELECT CONVERT(INT,cc.studentid) AS studentid
             ,CONVERT(VARCHAR(25),cc.course_number) AS course_number
             ,CONVERT(INT,cc.sectionid) AS sectionid
             ,cc.dateleft
             ,CONVERT(INT,LEFT(ABS(cc.termid), 2)) AS yearid                   
             ,cc.abs_sectionid
      
             ,CONVERT(INT,sec.gradescaleid) AS gradescaleid

             ,CASE 
               WHEN terms.alt_name = 'Summer School' THEN 'Q1' 
               ELSE CONVERT(VARCHAR,terms.alt_name) 
              END AS term_name        
       FROM powerschool.cc
       JOIN powerschool.sections sec
         ON cc.abs_sectionid = sec.id
       JOIN gabby.reporting.reporting_terms terms
         ON cc.schoolid = terms.schoolid         
        AND cc.dateenrolled BETWEEN terms.start_date AND terms.end_date
        AND terms.identifier = 'RT'   
        AND terms.school_level IN ('MS','HS')
       WHERE cc.dateenrolled BETWEEN DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1) AND CONVERT(DATE,GETDATE())
      ) sub
 )

SELECT cs.studentid
      ,cs.student_number
      ,cs.yearid
      ,cs.term_name
      ,cs.is_curterm
      ,cs.course_number      
      ,cs.course_name
      ,cs.credittype
      ,cs.credit_hours
      ,COALESCE(CASE WHEN ss.gradescaleid = 0 THEN cs.gradescaleid ELSE ss.gradescaleid END
               ,LAG(CASE WHEN ss.gradescaleid = 0 THEN cs.gradescaleid ELSE ss.gradescaleid END, 1) OVER(PARTITION BY cs.studentid, cs.yearid, cs.course_number ORDER BY cs.term_name)
               ,LAG(CASE WHEN ss.gradescaleid = 0 THEN cs.gradescaleid ELSE ss.gradescaleid END, 2) OVER(PARTITION BY cs.studentid, cs.yearid, cs.course_number ORDER BY cs.term_name)
               ,LAG(CASE WHEN ss.gradescaleid = 0 THEN cs.gradescaleid ELSE ss.gradescaleid END, 3) OVER(PARTITION BY cs.studentid, cs.yearid, cs.course_number ORDER BY cs.term_name)) AS gradescaleid
      ,cs.excludefromgpa

      ,COALESCE(ss.abs_sectionid
               ,LAG(ss.abs_sectionid, 1) OVER(PARTITION BY cs.studentid, cs.yearid, cs.course_number ORDER BY cs.term_name)
               ,LAG(ss.abs_sectionid, 2) OVER(PARTITION BY cs.studentid, cs.yearid, cs.course_number ORDER BY cs.term_name)
               ,LAG(ss.abs_sectionid, 3) OVER(PARTITION BY cs.studentid, cs.yearid, cs.course_number ORDER BY cs.term_name)) AS sectionid
FROM course_scaffold cs
LEFT JOIN section_scaffold ss
  ON cs.studentid = ss.studentid
 AND cs.yearid = ss.yearid
 AND cs.term_name = ss.term_name
 AND cs.course_number = ss.course_number
 AND ss.rn_term = 1