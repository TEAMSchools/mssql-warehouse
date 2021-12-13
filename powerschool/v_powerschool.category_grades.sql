CREATE OR ALTER VIEW powerschool.category_grades AS

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
      ,sub.citizenship
      ,ROUND(AVG(sub.grade_category_pct) OVER(
         PARTITION BY sub.student_number, sub.academic_year, sub.course_number, sub.grade_category 
           ORDER BY sub.startdate), 0) AS grade_category_pct_y1
      ,CASE
        WHEN CONVERT(DATE, GETDATE()) BETWEEN sub.startdate AND sub.enddate THEN 1 
        WHEN sub.academic_year < gabby.utilities.GLOBAL_ACADEMIC_YEAR() 
         AND sub.startdate = MAX(sub.startdate) OVER(PARTITION BY student_number, sub.academic_year)
               THEN 1
        ELSE 0
       END AS is_curterm
      ,NULL AS rn_curterm
FROM
    (
     SELECT enr.student_number
           ,enr.schoolid
           ,enr.academic_year
           ,enr.credittype
           ,enr.course_number
           ,enr.course_name
           ,enr.sectionid
           ,enr.teacher_name

           ,tb.date_1 AS startdate
           ,tb.date_2 AS enddate
           ,LEFT(tb.storecode, 1) AS grade_category
           ,CONVERT(VARCHAR(5), CONCAT('RT', RIGHT(tb.storecode, 1))) AS reporting_term

           ,ROUND(CASE WHEN pgf.grade = '--' THEN NULL ELSE pgf.[percent] END, 0) AS grade_category_pct
           ,CASE WHEN pgf.citizenship <> '' THEN pgf.citizenship END AS citizenship

           ,ROW_NUMBER() OVER(
              PARTITION BY enr.student_number, enr.academic_year, enr.course_number, tb.storecode
                ORDER BY pgf.[percent] DESC, enr.sectionid DESC) AS rn_year
     FROM powerschool.course_enrollments_current_static enr
     JOIN powerschool.terms t
       ON enr.schoolid = t.schoolid
      AND t.yearid = (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1990)
      AND t.isyearrec = 1
     JOIN powerschool.termbins tb
       ON t.schoolid = tb.schoolid
      AND t.id = tb.termid
      AND LEFT(tb.storecode, 1) NOT IN ('Q', 'T', 'Y', 'E')
      AND tb.date_1 <= GETDATE()
     LEFT JOIN powerschool.pgfinalgrades pgf
       ON enr.studentid = pgf.studentid
      AND enr.sectionid = pgf.sectionid
      AND tb.storecode = pgf.finalgradename
     WHERE enr.course_enroll_status = 0
       AND enr.section_enroll_status = 0
    ) sub
WHERE rn_year = 1
