CREATE OR ALTER VIEW powerschool.course_section_scaffold_current AS 

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
FROM powerschool.course_scaffold_current_static cs
LEFT JOIN powerschool.section_scaffold_current_static ss
  ON cs.studentid = ss.studentid
 AND cs.yearid = ss.yearid
 AND cs.term_name = ss.term_name
 AND cs.course_number = ss.course_number
 AND ss.rn_term = 1