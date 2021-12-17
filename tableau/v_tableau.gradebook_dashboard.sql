USE gabby
GO

CREATE OR ALTER VIEW tableau.gradebook_dashboard AS

WITH section_teacher AS (
  SELECT scaff.studentid
        ,scaff.yearid
        ,scaff.course_number
        ,scaff.sectionid
        ,scaff.[db_name]

        ,CONVERT(VARCHAR(125), sec.section_number) AS section_number
        ,sec.external_expression
        ,sec.termid

        ,t.lastfirst AS teacher_name
  FROM gabby.powerschool.course_section_scaffold scaff 
  LEFT JOIN gabby.powerschool.sections sec 
    ON scaff.sectionid = sec.id
   AND scaff.[db_name] = sec.[db_name]
  LEFT JOIN gabby.powerschool.teachers_static t 
    ON sec.teacher = t.id 
   AND sec.[db_name] = t.[db_name]
  WHERE scaff.is_curterm = 1
 )

/* current year - term grades */
SELECT co.student_number
      ,co.lastfirst
      ,co.reporting_schoolid AS schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor_name
      ,co.enroll_status
      ,co.academic_year
      ,co.iep_status
      ,co.cohort
      ,co.region
      ,co.gender
      ,co.school_level

      ,CASE WHEN sp.studentid IS NOT NULL THEN 1 END AS is_counselingservices

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
      ,NULL AS earnedcrhrs

      ,CASE WHEN pgf.citizenship <> '' THEN pgf.citizenship END AS citizenship
      ,CASE WHEN pgf.comment_value <> '' THEN pgf.comment_value END AS comment_value

      ,st.sectionid
      ,st.termid
      ,st.teacher_name
      ,st.section_number
      ,st.section_number AS [period]
      ,st.external_expression

      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_65 ELSE NULL END) OVER(PARTITION BY co.student_number, co.academic_year, gr.course_number) AS need_65
      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_70 ELSE NULL END) OVER(PARTITION BY co.student_number, co.academic_year, gr.course_number) AS need_70
      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_80 ELSE NULL END) OVER(PARTITION BY co.student_number, co.academic_year, gr.course_number) AS need_80
      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_90 ELSE NULL END) OVER(PARTITION BY co.student_number, co.academic_year, gr.course_number) AS need_90
FROM gabby.powerschool.cohort_identifiers_static co 
LEFT JOIN gabby.powerschool.final_grades_static gr 
  ON co.student_number = gr.student_number
 AND co.academic_year = gr.academic_year 
 AND co.[db_name] = gr.[db_name]
LEFT JOIN gabby.powerschool.pgfinalgrades pgf
  ON gr.studentid = pgf.studentid
 AND gr.sectionid = pgf.sectionid
 AND gr.term_name = pgf.finalgradename
 AND gr.[db_name] = pgf.[db_name]
LEFT JOIN section_teacher st 
  ON co.studentid = st.studentid
 AND co.yearid = st.yearid
 AND co.[db_name] = st.[db_name]
 AND gr.course_number = st.course_number
LEFT JOIN gabby.powerschool.spenrollments_gen_static sp
  ON co.studentid = sp.studentid
 AND CONVERT(DATE, GETDATE()) BETWEEN sp.enter_date AND sp.exit_date
 AND sp.specprog_name = 'Counseling Services'
 AND co.[db_name] = sp.[db_name]
WHERE co.rn_year = 1
  AND co.grade_level <> 99
  AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

UNION ALL

/* current year - Y1 grades */
SELECT co.student_number
      ,co.lastfirst
      ,co.reporting_schoolid AS schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor_name
      ,co.enroll_status
      ,co.academic_year
      ,co.iep_status
      ,co.cohort
      ,co.region
      ,co.gender
      ,co.school_level

      ,CASE WHEN sp.studentid IS NOT NULL THEN 1 END AS is_counselingservices

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

      ,y1.earnedcrhrs
      ,NULL AS citizenship
      ,NULL AS comment_value

      ,st.sectionid
      ,st.termid
      ,st.teacher_name
      ,st.section_number
      ,st.section_number AS [period]
      ,st.external_expression

      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_65 ELSE NULL END) OVER(PARTITION BY co.student_number, co.academic_year, gr.course_number) AS need_65
      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_70 ELSE NULL END) OVER(PARTITION BY co.student_number, co.academic_year, gr.course_number) AS need_70
      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_80 ELSE NULL END) OVER(PARTITION BY co.student_number, co.academic_year, gr.course_number) AS need_80
      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_90 ELSE NULL END) OVER(PARTITION BY co.student_number, co.academic_year, gr.course_number) AS need_90
FROM gabby.powerschool.cohort_identifiers_static co 
LEFT JOIN gabby.powerschool.final_grades_static gr 
  ON co.student_number = gr.student_number
 AND co.academic_year = gr.academic_year 
 AND co.[db_name] = gr.[db_name]
 AND gr.is_curterm = 1
LEFT JOIN gabby.powerschool.storedgrades y1
  ON co.studentid = y1.studentid
 AND co.academic_year = y1.academic_year
 AND co.[db_name] = y1.[db_name]
 AND gr.course_number = y1.course_number
 AND y1.storecode = 'Y1'
LEFT JOIN section_teacher st
  ON co.studentid = st.studentid
 AND co.yearid = st.yearid
 AND co.[db_name] = st.[db_name]
 AND gr.course_number = st.course_number
LEFT JOIN gabby.powerschool.spenrollments_gen_static sp
  ON co.studentid = sp.studentid
 AND CONVERT(DATE, GETDATE()) BETWEEN sp.enter_date AND sp.exit_date
 AND sp.specprog_name = 'Counseling Services'
 AND co.[db_name] = sp.[db_name]
WHERE co.rn_year = 1
  AND co.grade_level <> 99
  AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

UNION ALL

/* current year - HS exam grades */
SELECT co.student_number
      ,co.lastfirst
      ,co.reporting_schoolid AS schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor_name
      ,co.enroll_status
      ,co.academic_year
      ,co.iep_status
      ,co.cohort
      ,co.region
      ,co.gender
      ,co.school_level

      ,CASE WHEN sp.studentid IS NOT NULL THEN 1 END AS is_counselingservices

      ,ex.credittype
      ,ex.course_number
      ,ex.course_name
      ,CASE
        WHEN ex.e1 IS NOT NULL THEN 'Q2' 
        WHEN ex.e2 IS NOT NULL THEN 'Q4'
       END AS term_name
      ,CASE
        WHEN ex.e1 IS NOT NULL THEN 'E1'
        WHEN ex.e2 IS NOT NULL THEN 'E2'
       END AS finalgradename
      ,ex.is_curterm
      ,ex.excludefromgpa
      ,ex.credit_hours
      ,COALESCE(ex.e1, ex.e2) AS term_grade_percent_adjusted
      ,NULL AS term_grade_letter_adjusted
      ,NULL AS term_gpa_points
      ,NULL AS y1_grade_percent_adjusted
      ,NULL AS y1_grade_letter
      ,NULL AS y1_gpa_points
      ,NULL AS earnedcrhrs
      ,NULL AS citizenship
      ,NULL AS comment_value

      ,st.sectionid
      ,st.termid
      ,st.teacher_name
      ,st.section_number
      ,st.section_number AS [period]
      ,st.external_expression

      ,NULL AS need_65
      ,NULL AS need_70
      ,NULL AS need_80
      ,NULL AS need_90
FROM gabby.powerschool.cohort_identifiers_static co 
LEFT JOIN gabby.powerschool.final_grades_static ex
  ON co.student_number = ex.student_number
 AND co.academic_year = ex.academic_year
 AND co.[db_name] = ex.[db_name]
 AND (ex.e1 IS NOT NULL OR ex.e2 IS NOT NULL)
LEFT JOIN section_teacher st
  ON co.studentid = st.studentid
 AND co.yearid = st.yearid
 AND co.[db_name] = st.[db_name]
 AND ex.course_number = st.course_number
LEFT JOIN gabby.powerschool.spenrollments_gen_static sp
  ON co.studentid = sp.studentid
 AND CONVERT(DATE, GETDATE()) BETWEEN sp.enter_date AND sp.exit_date
 AND sp.specprog_name = 'Counseling Services'
 AND co.[db_name] = sp.[db_name]
WHERE co.rn_year = 1
  AND co.school_level = 'HS'
  AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

UNION ALL

/* historical grades */
SELECT co.student_number
      ,co.lastfirst
      ,co.reporting_schoolid AS schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor_name
      ,co.enroll_status
      ,co.academic_year
      ,co.iep_status
      ,co.cohort
      ,co.region
      ,co.gender
      ,co.school_level

      ,CASE WHEN sp.studentid IS NOT NULL THEN 1 END AS is_counselingservices

      ,sg.credit_type AS credittype
      ,sg.course_number
      ,sg.course_name
      ,'Y1' AS reporting_term
      ,'Y1' AS finalgradename
      ,1 AS is_curterm
      ,sg.excludefromgpa
      ,sg.potentialcrhrs AS credit_hours
      ,sg.[percent] AS term_grade_percent_adjusted
      ,CONVERT(VARCHAR(5), sg.grade) AS term_grade_letter_adjusted
      ,sg.gpa_points AS term_gpa_points
      ,sg.[percent] AS y1_grade_percent_adjusted
      ,CONVERT(VARCHAR(5), sg.grade) AS y1_grade_letter
      ,sg.gpa_points AS y1_gpa_points

      ,sg.earnedcrhrs
      ,NULL AS citizenship
      ,NULL AS comment_value

      ,st.sectionid
      ,st.termid
      ,st.teacher_name
      ,st.section_number
      ,st.section_number AS [period]
      ,st.external_expression

      ,NULL AS need_65
      ,NULL AS need_70
      ,NULL AS need_80
      ,NULL AS need_90
FROM gabby.powerschool.cohort_identifiers_static co 
LEFT JOIN gabby.powerschool.storedgrades sg
  ON co.studentid = sg.studentid
 AND co.academic_year = sg.academic_year
 AND co.[db_name] = sg.[db_name]
 AND sg.storecode = 'Y1'
 AND sg.course_number IS NOT NULL
LEFT JOIN section_teacher st
  ON co.studentid = st.studentid
 AND co.yearid = st.yearid
 AND co.[db_name] = st.[db_name]
 AND sg.course_number = st.course_number
LEFT JOIN gabby.powerschool.spenrollments_gen_static sp
  ON co.studentid = sp.studentid
 AND CONVERT(DATE, GETDATE()) BETWEEN sp.enter_date AND sp.exit_date
 AND sp.specprog_name = 'Counseling Services'
 AND co.[db_name] = sp.[db_name]
WHERE co.rn_year = 1
  AND co.academic_year <> gabby.utilities.GLOBAL_ACADEMIC_YEAR()

UNION ALL

/* transfer grades */
SELECT COALESCE(co.student_number, e1.student_number) AS student_number
      ,COALESCE(co.lastfirst, e1.lastfirst) AS lastfirst
      ,COALESCE(co.schoolid, e1.schoolid) AS schoolid
      ,COALESCE(co.grade_level, e1.grade_level) AS grade_level
      ,COALESCE(co.team, e1.team) AS team
      ,NULL AS advisor_name
      ,COALESCE(co.enroll_status, e1.enroll_status) AS enroll_status
      ,tr.academic_year
      ,COALESCE(co.iep_status, e1.iep_status) AS iep_status
      ,COALESCE(co.cohort, e1.cohort) AS cohort
      ,COALESCE(co.region, e1.region) AS region
      ,COALESCE(co.gender, e1.gender) AS gender
      ,COALESCE(co.school_level, e1.school_level) AS school_level

      ,CASE WHEN sp.studentid IS NOT NULL THEN 1 END AS is_counselingservices

      ,'TRANSFER' AS credittype
      ,CONVERT(VARCHAR(125), CONCAT('TRANSFER', tr.termid, tr.[db_name], tr.dcid)) COLLATE Latin1_General_BIN AS course_number
      ,CONVERT(VARCHAR(125), tr.course_name) AS course_name
      ,'Y1' AS reporting_term
      ,'Y1' AS finalgradename
      ,1 AS is_curterm
      ,CONVERT(INT, tr.excludefromgpa) AS excludefromgpa
      ,tr.potentialcrhrs AS credit_hours
      ,tr.[percent] AS term_grade_percent_adjusted
      ,CONVERT(VARCHAR(5), tr.grade) AS term_grade_letter_adjusted
      ,tr.gpa_points AS term_gpa_points
      ,tr.[percent] AS y1_grade_percent_adjusted
      ,CONVERT(VARCHAR(5), tr.grade) AS y1_grade_letter
      ,tr.gpa_points AS y1_gpa_points
      ,tr.earnedcrhrs
      ,NULL AS citizenship
      ,NULL AS comment_value

      ,CONVERT(INT, tr.sectionid) AS sectionid
      ,tr.termid
      ,'TRANSFER' AS teacher_name
      ,'TRANSFER' AS section_number
      ,NULL AS [period]
      ,NULL AS external_expression
      ,NULL AS need_65
      ,NULL AS need_70
      ,NULL AS need_80
      ,NULL AS need_90
FROM gabby.powerschool.storedgrades tr
LEFT JOIN gabby.powerschool.cohort_identifiers_static co 
  ON tr.studentid = co.studentid
 AND tr.schoolid = co.schoolid
 AND tr.[db_name] = co.[db_name]
 AND tr.academic_year = co.academic_year
 AND co.rn_year = 1
LEFT JOIN gabby.powerschool.cohort_identifiers_static e1 
  ON tr.studentid = e1.studentid
 AND tr.schoolid = e1.schoolid
 AND tr.[db_name] = e1.[db_name]
 AND e1.year_in_school = 1
LEFT JOIN gabby.powerschool.spenrollments_gen_static sp
  ON co.studentid = sp.studentid
 AND CONVERT(DATE, GETDATE()) BETWEEN sp.enter_date AND sp.exit_date
 AND sp.specprog_name = 'Counseling Services'
 AND co.[db_name] = sp.[db_name]
WHERE tr.storecode = 'Y1'
  AND tr.course_number IS NULL

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
      ,co.cohort
      ,co.region
      ,co.gender
      ,co.school_level

      ,CASE WHEN sp.studentid IS NOT NULL THEN 1 END AS is_counselingservices

      ,cg.credittype
      ,cg.course_number
      ,cg.course_name
      ,REPLACE(cg.reporting_term,'RT','Q') AS term_name
      ,cg.grade_category AS finalgradename
      ,cg.is_curterm
      ,NULL AS excludefromgpa
      ,NULL AS credit_hours
      ,cg.grade_category_pct AS term_grade_percent_adjusted
      ,NULL AS term_grade_letter_adjusted
      ,NULL AS term_gpa_points
      ,cg.grade_category_pct_y1 AS y1_grade_percent_adjusted
      ,NULL AS y1_grade_letter
      ,NULL AS y1_gpa_points
      ,NULL AS earnedcrhrs
      ,NULL AS citizenship
      ,NULL AS comment_value

      ,st.sectionid
      ,st.termid
      ,st.teacher_name
      ,st.section_number
      ,st.section_number AS [period]
      ,st.external_expression

      ,NULL AS need_65
      ,NULL AS need_70
      ,NULL AS need_80
      ,NULL AS need_90
FROM gabby.powerschool.cohort_identifiers_static co 
LEFT JOIN gabby.powerschool.category_grades_static cg
  ON co.student_number = cg.student_number
 AND co.academic_year = cg.academic_year 
 AND co.[db_name] = cg.[db_name]
 AND cg.grade_category <> 'Q'
LEFT JOIN section_teacher st
  ON co.studentid = st.studentid
 AND co.yearid = st.yearid
 AND co.[db_name] = st.[db_name]
 AND cg.course_number = st.course_number
LEFT JOIN gabby.powerschool.spenrollments_gen_static sp
  ON co.studentid = sp.studentid
 AND CONVERT(DATE, GETDATE()) BETWEEN sp.enter_date AND sp.exit_date
 AND sp.specprog_name = 'Counseling Services'
 AND co.[db_name] = sp.[db_name]
WHERE co.rn_year = 1
  AND co.grade_level <> 99
  AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

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
      ,co.cohort
      ,co.region
      ,co.gender
      ,co.school_level

      ,CASE WHEN sp.studentid IS NOT NULL THEN 1 END AS is_counselingservices

      ,cy.credittype
      ,cy.course_number
      ,cy.course_name
      ,'Y1' AS term_name
      ,CONCAT(cy.grade_category, 'Y1') AS finalgradename
      ,cy.is_curterm
      ,NULL AS excludefromgpa
      ,NULL AS credit_hours
      ,cy.grade_category_pct_y1 AS term_grade_percent_adjusted
      ,NULL AS term_grade_letter_adjusted
      ,NULL AS term_gpa_points
      ,cy.grade_category_pct_y1 AS y1_grade_percent_adjusted
      ,NULL AS y1_grade_letter
      ,NULL AS y1_gpa_points
      ,NULL AS earnedcrhrs
      ,NULL AS citizenship
      ,NULL AS comment_value

      ,st.sectionid
      ,st.termid
      ,st.teacher_name
      ,st.section_number
      ,st.section_number AS [period]
      ,st.external_expression

      ,NULL AS need_65
      ,NULL AS need_70
      ,NULL AS need_80
      ,NULL AS need_90
FROM gabby.powerschool.cohort_identifiers_static co 
LEFT JOIN gabby.powerschool.category_grades_static cy
  ON co.student_number = cy.student_number
 AND co.academic_year = cy.academic_year 
 AND co.[db_name] = cy.[db_name]
 AND cy.grade_category <> 'Q'
 AND cy.is_curterm = 1
LEFT JOIN section_teacher st
  ON co.studentid = st.studentid
 AND co.yearid = st.yearid
 AND co.[db_name] = st.[db_name]
 AND cy.course_number = st.course_number
LEFT JOIN gabby.powerschool.spenrollments_gen_static sp
  ON co.studentid = sp.studentid
 AND CONVERT(DATE, GETDATE()) BETWEEN sp.enter_date AND sp.exit_date
 AND sp.specprog_name = 'Counseling Services'
 AND co.[db_name] = sp.[db_name]
WHERE co.rn_year = 1
  AND co.grade_level <> 99
  AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
