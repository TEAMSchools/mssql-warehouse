USE gabby
GO

ALTER VIEW powerschool.category_grades AS

SELECT sub.student_number
      ,sub.schoolid
      ,sub.academic_year
      ,sub.credittype
      ,sub.course_number
      ,sub.course_name
      ,sub.sectionid
      ,sub.teacher_name
      ,sub.reporting_term
      ,sub.grade_category
      ,sub.grade_category_pct
      
      ,ROUND(AVG(sub.grade_category_pct) OVER(
         PARTITION BY sub.student_number, sub.academic_year, sub.course_number, sub.grade_category 
           ORDER BY sub.startdate), 0) AS grade_category_pct_y1
      
      ,CASE 
        WHEN CONVERT(DATE,GETDATE()) BETWEEN sub.startdate AND sub.enddate THEN 1 
        WHEN sub.academic_year <= gabby.utilities.GLOBAL_ACADEMIC_YEAR() 
         AND sub.startdate = MAX(sub.startdate) OVER(PARTITION BY student_number, sub.academic_year, sub.course_number)
               THEN 1
        ELSE 0
       END AS is_curterm
      ,NULL AS rn_curterm
      --,ROW_NUMBER() OVER(
      --   PARTITION BY sub.student_number, sub.academic_year, sub.course_number, sub.grade_category
      --     ORDER BY sub.startdate DESC) AS rn_curterm
FROM
    (
     /* NCA */
     SELECT enr.student_number                   
           ,enr.schoolid
           ,enr.academic_year
           ,enr.credittype      
           ,enr.course_number      
           ,enr.course_name
           ,enr.sectionid           
           ,enr.teacher_name            
           
           ,pgf.startdate
           ,pgf.enddate
      
           ,LEFT(pgf.finalgradename,1) AS grade_category
           ,CONCAT('RT', RIGHT(pgf.finalgradename,1)) AS reporting_term            
           ,ROUND(pgf.[percent],0) AS grade_category_pct               
      
           ,ROW_NUMBER() OVER(
              PARTITION BY enr.student_number, enr.academic_year, enr.course_number, pgf.finalgradename
                ORDER BY enr.dateenrolled DESC, enr.dateleft DESC) AS rn
     FROM gabby.powerschool.course_enrollments_static enr
     JOIN gabby.powerschool.pgfinalgrades pgf
       ON enr.studentid = pgf.studentid
      AND enr.sectionid = pgf.sectionid
      AND pgf.finalgradename != 'Y1'       
      AND pgf.finalgradename NOT LIKE 'Q%'
      AND pgf.finalgradename NOT LIKE 'E%'
     WHERE enr.course_enroll_status = 0
       AND enr.section_enroll_status = 0
       AND enr.schoolid = 73253

     UNION ALL

     /* MS */
     SELECT enr.student_number                   
           ,enr.schoolid
           ,enr.academic_year
           ,enr.credittype      
           ,enr.course_number      
           ,enr.course_name
           ,enr.sectionid           
           ,enr.teacher_name            

           ,pgf.startdate
           ,pgf.enddate
      
           ,CASE
             WHEN pgf.startdate <= '2015-06-30' AND LEFT(pgf.finalgradename,1) = 'E' THEN 'X'
             WHEN pgf.startdate <= '2015-06-30' AND LEFT(pgf.finalgradename,1) = 'Q' THEN 'E'
             ELSE LEFT(pgf.finalgradename,1)
            END AS grade_category
           ,CONCAT('RT', RIGHT(pgf.finalgradename,1)) AS reporting_term            
           ,ROUND(pgf.[percent],0) AS grade_category_pct               
      
           ,ROW_NUMBER() OVER(
              PARTITION BY enr.student_number, enr.academic_year, enr.course_number, pgf.finalgradename
                ORDER BY enr.dateenrolled DESC, enr.dateleft DESC) AS rn
     FROM gabby.powerschool.course_enrollments_static enr
     JOIN gabby.powerschool.pgfinalgrades pgf
       ON enr.studentid = pgf.studentid       
      AND enr.sectionid = pgf.sectionid 
      AND pgf.finalgradename != 'Y1'       
      AND ((pgf.startdate <= '2015-06-30' AND pgf.FINALGRADENAME NOT LIKE 'T%') 
              OR (pgf.startdate >= '2015-07-01' AND pgf.FINALGRADENAME NOT LIKE 'Q%'))
     WHERE enr.course_enroll_status = 0
       AND enr.section_enroll_status = 0
       AND enr.schoolid != 73253
    ) sub
WHERE sub.rn = 1