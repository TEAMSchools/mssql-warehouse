USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_finalgrades AS

SELECT o.student_number
      ,gabby.utilities.GLOBAL_ACADEMIC_YEAR() AS academic_year
      ,o.term_name AS term
      ,o.course_number
      ,o.sectionid

      ,sec.dcid AS sections_dcid
      ,sec.section_number

      ,cou.course_name
      ,cou.credit_hours
      ,ABS(cou.excludefromgpa - 1) AS include_grades_display

      ,ISNULL(cc.currentabsences, 0) AS currentabsences
      ,ISNULL(cc.currenttardies, 0) AS currenttardies

      /* final grades */
      ,fg.teacher_name
      ,fg.RT1_term_grade_percent_adjusted AS Q1_pct
      ,fg.RT1_term_grade_letter_adjusted AS Q1_letter
      ,fg.RT2_term_grade_percent_adjusted AS Q2_pct
      ,fg.RT2_term_grade_letter_adjusted AS Q2_letter
      ,fg.RT3_term_grade_percent_adjusted AS Q3_pct
      ,fg.RT3_term_grade_letter_adjusted AS Q3_letter
      ,fg.RT4_term_grade_percent_adjusted AS Q4_pct
      ,fg.RT4_term_grade_letter_adjusted AS Q4_letter
      ,fg.e1_grade_percent AS e1_pct
      ,fg.e2_grade_percent AS e2_pct
      ,fg.y1_grade_percent AS y1_pct
      ,fg.y1_grade_letter AS y1_letter
      ,COALESCE(
         LEAD(fg.need_65, 1) OVER(
          PARTITION BY o.student_number, o.course_number 
            ORDER BY o.term_name)
        ,fg.need_65) AS need_60

      /* category grades */
      ,cat.M_CUR AS A_term
      ,cat.P_CUR AS P_term
      ,cat.W_CUR AS W_term
      ,cat.W_RT1
      ,cat.W_RT2
      ,cat.W_RT3
      ,cat.W_RT4

      ,COALESCE(cat.CTZ_CUR, kctz.CTZ_CUR) AS CTZ_CUR
      ,COALESCE(cat.CTZ_RT1, kctz.CTZ_RT1) AS CTZ_RT1
      ,COALESCE(cat.CTZ_RT2, kctz.CTZ_RT2) AS CTZ_RT2
      ,COALESCE(cat.CTZ_RT3, kctz.CTZ_RT3) AS CTZ_RT3
      ,COALESCE(cat.CTZ_RT4, kctz.CTZ_RT4) AS CTZ_RT4

      ,REPLACE(comm.comment_value, '"', '''') AS comment_value
FROM gabby.powerschool.course_section_scaffold_current_static o
JOIN gabby.powerschool.sections sec
  ON o.sectionid = sec.id
 AND o.[db_name] = sec.[db_name]
JOIN gabby.powerschool.courses cou
  ON o.course_number = cou.course_number
 AND o.[db_name] = cou.[db_name]
JOIN gabby.powerschool.cc
  ON o.studentid = cc.studentid
 AND o.sectionid = cc.sectionid
 AND o.[db_name] = cc.[db_name]
LEFT JOIN gabby.powerschool.final_grades_wide_static fg
  ON o.student_number = fg.student_number
 AND o.course_number = fg.course_number
 AND o.term_name = fg.term_name
 AND o.[db_name] = fg.[db_name]
 AND fg.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
 AND fg.reporting_term <> 'CUR'
LEFT JOIN gabby.powerschool.category_grades_wide_static cat
  ON o.student_number = cat.student_number
 AND o.course_number = cat.course_number
 AND o.[db_name] = cat.[db_name]
 AND fg.reporting_term = cat.reporting_term 
LEFT JOIN gabby.powerschool.category_grades_wide_static kctz
  ON o.student_number = kctz.student_number
 AND o.[db_name] = kctz.[db_name]
 AND fg.reporting_term = kctz.reporting_term 
 AND kctz.course_number = 'HR'
 AND sec.section_number LIKE '0%'
LEFT JOIN gabby.powerschool.pgfinalgrades comm
  ON fg.studentid = comm.studentid
 AND fg.sectionid = comm.sectionid
 AND fg.term_name = comm.finalgradename
 AND fg.[db_name] = comm.[db_name]
