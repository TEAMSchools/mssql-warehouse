USE gabby
GO

ALTER VIEW powerschool.course_section_scaffold AS 

WITH course_scaffold AS (
  SELECT DISTINCT 
         co.studentid
        ,co.yearid      
      
        ,terms.alt_name AS term_name
                   
        ,enr.course_number
  FROM gabby.powerschool.cohort co  
  JOIN gabby.reporting.reporting_terms terms
    ON co.schoolid = terms.schoolid   
   AND co.academic_year = terms.academic_year
   AND terms.identifier = 'RT'
   AND terms.alt_name != 'Summer School'
  JOIN gabby.powerschool.course_enrollments_static enr
    ON co.studentid = enr.studentid
   AND co.yearid = enr.yearid
   --AND enr.course_enroll_status = 0
   --AND enr.section_enroll_status = 0
   AND enr.dateenrolled <= CONVERT(DATE,GETDATE())
  WHERE co.rn_year = 1
 )

,section_scaffold AS (
  SELECT cc.studentid            
        ,cc.course_number            
        ,LEFT(ABS(cc.termid), 2) AS yearid      
        ,ABS(cc.sectionid) AS abs_sectionid
      
        ,CASE WHEN terms.alt_name = 'Summer School' THEN 'Q1' ELSE terms.alt_name END AS term_name

        ,ROW_NUMBER() OVER(
           PARTITION BY cc.studyear, cc.course_number, CASE WHEN terms.alt_name = 'Summer School' THEN 'Q1' ELSE terms.alt_name END
             ORDER BY cc.dateleft DESC, cc.sectionid DESC) AS rn_term
  FROM gabby.powerschool.cc
  JOIN gabby.reporting.reporting_terms terms
    ON cc.schoolid = terms.schoolid      
   AND RIGHT(cc.studyear, 2) = terms.yearid   
   AND cc.dateenrolled BETWEEN terms.start_date AND terms.end_date
   AND terms.identifier = 'RT'
  WHERE cc.dateenrolled <= CONVERT(DATE,GETDATE())
 )

SELECT cs.studentid
      ,cs.yearid
      ,cs.term_name
      ,cs.course_number      
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