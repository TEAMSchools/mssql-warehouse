USE gabby
GO

ALTER VIEW tableau.gradebook_dashboard AS

WITH section_teacher AS (
  SELECT scaff.studentid
        ,scaff.yearid + 1990 AS academic_year
        ,scaff.course_number        
        ,scaff.sectionid        
        
        ,sec.section_number 
        
        ,t.lastfirst AS teacher_name               
        
        ,ROW_NUMBER() OVER(
           PARTITION BY scaff.studentid, scaff.yearid, scaff.course_number
             ORDER BY scaff.term_name DESC) AS rn        
  FROM gabby.powerschool.course_section_scaffold_static scaff
  JOIN gabby.powerschool.sections sec
    ON scaff.sectionid = sec.id
  JOIN gabby.powerschool.teachers t
    ON sec.teacher = t.id 
 )

/* final grades */
SELECT co.student_number
      ,co.lastfirst
      ,co.reporting_schoolid AS schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor_name
      ,co.enroll_status
      ,co.academic_year
      ,co.iep_status
            
      ,gr.credittype
      ,gr.course_number
      ,gr.course_name                 
      ,gr.term_name
      ,gr.term_name AS finalgradename
      ,gr.is_curterm      
      ,gr.excludefromgpa
      ,gr.credit_hours      
      ,gr.term_grade_percent_adjusted
      ,gr.term_grade_letter_adjusted
      ,gr.term_gpa_points
      ,gr.y1_grade_percent_adjusted
      ,gr.y1_grade_letter           
      ,gr.y1_gpa_points
      
      ,st.sectionid
      ,st.teacher_name
      ,st.section_number       
      ,st.section_number AS period

      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_65 ELSE NULL END) OVER(PARTITION BY co.student_number, co.academic_year, gr.course_number) AS need_65
      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_70 ELSE NULL END) OVER(PARTITION BY co.student_number, co.academic_year, gr.course_number) AS need_70
      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_80 ELSE NULL END) OVER(PARTITION BY co.student_number, co.academic_year, gr.course_number) AS need_80
      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_90 ELSE NULL END) OVER(PARTITION BY co.student_number, co.academic_year, gr.course_number) AS need_90
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.powerschool.final_grades_static gr
  ON co.student_number = gr.student_number
 AND co.academic_year = gr.academic_year 
JOIN section_teacher st
  ON co.studentid = st.studentid
 AND co.academic_year = st.academic_year
 AND gr.course_number = st.course_number
 AND st.rn = 1
WHERE co.rn_year = 1
  AND co.school_level IN ('MS','HS')

UNION ALL

/* Y1 grades as additional term */
SELECT co.student_number
      ,co.lastfirst
      ,co.reporting_schoolid AS schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor_name
      ,co.enroll_status
      ,co.academic_year
      ,co.iep_status

      ,gr.credittype
      ,gr.course_number
      ,gr.course_name            
      ,'Y1' AS reporting_term   
      ,'Y1' AS finalgradename      
      ,gr.is_curterm            
      ,gr.excludefromgpa
      ,gr.credit_hours      
      ,gr.y1_grade_percent_adjusted AS term_grade_percent_adjusted
      ,gr.y1_grade_letter AS term_grade_letter_adjusted
      ,gr.y1_gpa_points AS term_gpa_points
      ,gr.y1_grade_percent_adjusted
      ,gr.y1_grade_letter           
      ,gr.y1_gpa_points      
      
      ,st.sectionid
      ,st.teacher_name
      ,st.section_number       
      ,st.section_number AS period

      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_65 ELSE NULL END) OVER(PARTITION BY co.student_number, co.academic_year, gr.course_number) AS need_65
      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_70 ELSE NULL END) OVER(PARTITION BY co.student_number, co.academic_year, gr.course_number) AS need_70
      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_80 ELSE NULL END) OVER(PARTITION BY co.student_number, co.academic_year, gr.course_number) AS need_80
      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_90 ELSE NULL END) OVER(PARTITION BY co.student_number, co.academic_year, gr.course_number) AS need_90
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.powerschool.final_grades_static gr
  ON co.student_number = gr.student_number
 AND co.academic_year = gr.academic_year 
 AND gr.is_curterm = 1
JOIN section_teacher st
  ON co.studentid = st.studentid
 AND co.academic_year = st.academic_year
 AND gr.course_number = st.course_number
 AND st.rn = 1
WHERE co.rn_year = 1
  AND co.school_level IN ('MS','HS')  

UNION ALL

/* transfer grades */
SELECT s.student_number
      ,s.lastfirst
      ,s.schoolid
      ,s.grade_level
      ,s.team
      ,NULL AS advisor_name
      ,s.enroll_status
      ,LEFT(gr.termid,2) + 1990 AS academic_year
      ,cs.spedlep AS iep_status
      
      ,'TRANSFER' AS credittype
      ,CONCAT('TRANSFER', gr.termid, gr._line) AS course_number
      ,gr.course_name              
      ,'Y1' AS reporting_term
      ,'Y1' AS finalgradename            
      ,1 AS is_curterm
      ,gr.excludefromgpa
      ,gr.potentialcrhrs AS credit_hours      
      ,gr.[percent] AS term_grade_percent_adjusted
      ,gr.grade AS term_grade_letter_adjusted
      ,gr.gpa_points AS term_gpa_points
      ,gr.[percent] AS y1_grade_percent_adjusted
      ,gr.grade AS y1_grade_letter           
      ,gr.gpa_points AS y1_gpa_points            
      
      ,gr.sectionid
      ,'TRANSFER' AS teacher_name    
      ,'TRANSFER' AS section_number       
      ,NULL AS period
      ,NULL AS need_65
      ,NULL AS need_70
      ,NULL AS need_80
      ,NULL AS need_90
FROM gabby.powerschool.storedgrades gr
JOIN gabby.powerschool.students s
  ON gr.studentid = s.id 
 AND gr.schoolid = s.schoolid
LEFT OUTER JOIN gabby.powerschool.studentcorefields cs
  ON s.dcid = cs.studentsdcid
WHERE gr.storecode = 'Y1'
  AND gr.course_number IS NULL

UNION ALL

/* NCA exam grades */
SELECT co.student_number
      ,co.lastfirst
      ,co.reporting_schoolid AS schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor_name
      ,co.enroll_status
      ,co.academic_year
      ,co.iep_status      
      
      ,gr.credittype
      ,gr.course_number
      ,gr.course_name        
      ,CASE 
        WHEN gr.e1 IS NOT NULL THEN 'Q2' 
        WHEN gr.e2 IS NOT NULL THEN 'Q4'
       END AS term_name
      ,CASE
        WHEN gr.e1 IS NOT NULL THEN 'E1'
        WHEN gr.e2 IS NOT NULL THEN 'E2'
       END AS finalgradename
      ,gr.is_curterm                
      ,gr.excludefromgpa
      ,gr.credit_hours      
      ,COALESCE(gr.e1, gr.e2) AS term_grade_percent_adjusted
      ,NULL AS term_grade_letter_adjusted
      ,NULL AS term_gpa_points
      ,NULL AS y1_grade_percent_adjusted
      ,NULL AS y1_grade_letter           
      ,NULL AS y1_gpa_points      
      
      ,st.sectionid
      ,st.teacher_name
      ,st.section_number       
      ,st.section_number AS period

      ,NULL AS need_65
      ,NULL AS need_70
      ,NULL AS need_80
      ,NULL AS need_90
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.powerschool.final_grades_static gr
  ON co.student_number = gr.student_number
 AND co.academic_year = gr.academic_year
 AND (gr.e1 IS NOT NULL OR gr.e2 IS NOT NULL)
JOIN section_teacher st
  ON co.studentid = st.studentid
 AND co.academic_year = st.academic_year
 AND gr.course_number = st.course_number
 AND st.rn = 1
WHERE co.rn_year = 1
  AND co.schoolid = 73253

UNION ALL

/* category grades - term */
SELECT co.student_number
      ,co.lastfirst
      ,co.reporting_schoolid AS schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor_name
      ,co.enroll_status
      ,co.academic_year
      ,co.iep_status      
      
      ,gr.credittype
      ,gr.course_number
      ,cou.course_name         
      ,REPLACE(gr.reporting_term,'RT','Q') AS term_name
      ,CASE 
        WHEN co.schoolid != 73253 AND gr.grade_category = 'E' THEN 'HWQ'
        WHEN co.schoolid != 73253 AND co.academic_year <= 2014 AND gr.grade_category = 'Q' THEN 'HWQ'
        ELSE gr.grade_category
       END AS finalgradename
      ,gr.is_curterm         
      ,NULL AS excludefromgpa
      ,NULL AS credit_hours      
      ,gr.grade_category_pct AS term_grade_percent_adjusted
      ,NULL AS term_grade_letter_adjusted
      ,NULL AS term_gpa_points      
      ,gr.grade_category_pct_y1 AS y1_grade_percent_adjusted
      ,NULL AS y1_grade_letter            
      ,NULL AS y1_gpa_points      

      ,st.sectionid
      ,st.teacher_name
      ,st.section_number       
      ,st.section_number AS period

      ,NULL AS need_65
      ,NULL AS need_70
      ,NULL AS need_80
      ,NULL AS need_90
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.powerschool.category_grades_static gr
  ON co.student_number = gr.student_number
 AND co.academic_year = gr.academic_year 
JOIN section_teacher st
  ON co.studentid = st.studentid
 AND co.academic_year = st.academic_year
 AND gr.course_number = st.COURSE_NUMBER
 AND st.rn = 1
JOIN gabby.powerschool.courses cou
  ON gr.course_number = cou.course_number
WHERE co.rn_year = 1
  AND co.school_level IN ('MS','HS')
  
UNION ALL

/* category grades - year */
SELECT co.student_number
      ,co.lastfirst
      ,co.reporting_schoolid AS schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor_name
      ,co.enroll_status
      ,co.academic_year
      ,co.iep_status      
      
      ,gr.credittype
      ,gr.course_number
      ,cou.course_name         
      ,'Y1' AS term_name
      ,CONCAT(CASE 
               WHEN co.schoolid != 73253 AND gr.grade_category = 'E' THEN 'HWQ'
               WHEN co.schoolid != 73253 AND co.academic_year <= 2014 AND gr.grade_category = 'Q' THEN 'HWQ'
               ELSE gr.grade_category
              END, 'Y1') AS finalgradename
      ,gr.is_curterm         
      ,NULL AS excludefromgpa
      ,NULL AS credit_hours      
      ,gr.grade_category_pct AS term_grade_percent_adjusted
      ,NULL AS term_grade_letter_adjusted
      ,NULL AS term_gpa_points      
      ,gr.grade_category_pct_y1 AS y1_grade_percent_adjusted
      ,NULL AS y1_grade_letter            
      ,NULL AS y1_gpa_points      

      ,st.sectionid
      ,st.teacher_name
      ,st.section_number       
      ,st.section_number AS period

      ,NULL AS need_65
      ,NULL AS need_70
      ,NULL AS need_80
      ,NULL AS need_90
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.powerschool.category_grades_static gr
  ON co.student_number = gr.student_number
 AND co.academic_year = gr.academic_year 
 AND gr.is_curterm = 1
JOIN section_teacher st
  ON co.studentid = st.studentid
 AND co.academic_year = st.academic_year
 AND gr.course_number = st.COURSE_NUMBER
 AND st.rn = 1
JOIN gabby.powerschool.courses cou
  ON gr.course_number = cou.course_number
WHERE co.rn_year = 1
  AND co.school_level IN ('MS','HS')