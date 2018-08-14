USE gabby
GO

CREATE OR ALTER VIEW extracts.deanslist_finalgrades AS

SELECT o.student_number
      ,(o.yearid + 1990) AS academic_year
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
      ,fg.RT2_term_grade_percent_adjusted AS Q2_pct
      ,fg.RT3_term_grade_percent_adjusted AS Q3_pct
      ,fg.RT4_term_grade_percent_adjusted AS Q4_pct
      ,fg.y1_grade_percent AS y1_pct
      ,fg.y1_grade_letter AS y1_letter

      /* category grades */      
      ,cat.A_CUR AS A_term
      ,cat.C_CUR AS CW_term
      ,cat.H_CUR AS HWC_term
      ,cat.P_CUR AS CP_term
      ,cat.E_CUR AS HWQ_term      

      ,REPLACE(comm.comment_value,'"','''') AS comment_value
FROM gabby.powerschool.course_section_scaffold o WITH(NOLOCK)
JOIN gabby.powerschool.sections sec WITH(NOLOCK)
  ON o.sectionid = sec.id
 AND o.db_name = sec.db_name
JOIN gabby.powerschool.courses cou WITH(NOLOCK)
  ON o.course_number = cou.course_number_clean
 AND o.db_name = cou.db_name
JOIN gabby.powerschool.cc WITH(NOLOCK)
  ON o.studentid = cc.studentid
 AND o.sectionid = cc.sectionid
 AND o.db_name = cc.db_name
LEFT JOIN gabby.powerschool.final_grades_wide fg WITH(NOLOCK)
  ON o.student_number = fg.student_number
 AND (o.yearid + 1990) = fg.academic_year
 AND o.course_number = fg.course_number
 AND o.term_name = fg.term_name
 AND o.db_name = fg.db_name
 AND fg.reporting_term != 'CUR'
LEFT JOIN gabby.powerschool.category_grades_wide cat WITH(NOLOCK)
  ON o.student_number = cat.student_number
 AND (o.yearid + 1990) = cat.academic_year
 AND o.db_name = cat.db_name
 AND fg.course_number = cat.course_number
 AND fg.reporting_term = cat.reporting_term 
LEFT JOIN gabby.powerschool.pgfinalgrades comm WITH(NOLOCK)
  ON fg.studentid = comm.studentid
 AND fg.sectionid = comm.sectionid
 AND fg.term_name = comm.finalgradename_clean
 AND fg.db_name = comm.db_name
WHERE o.yearid = (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1990)

UNION ALL

SELECT comm.student_number
      ,comm.academic_year
      ,comm.term_name COLLATE Latin1_General_BIN AS term_name
      ,comm.comment_subject COLLATE Latin1_General_BIN AS course_number      
      
      ,NULL AS sectionid      
      ,NULL AS sections_dcid
      ,NULL AS section_number

      ,comm.comment_subject COLLATE Latin1_General_BIN AS course_name
      
      ,NULL AS credit_hours
      
      ,0 AS include_grades_display

      ,NULL AS currentabsences
      ,NULL AS currenttardies      
      ,NULL AS teacher_name
      ,NULL AS Q1_pct
      ,NULL AS Q2_pct
      ,NULL AS Q3_pct
      ,NULL AS Q4_pct
      ,NULL AS Y1_pct
      ,NULL AS Y1_letter
      ,NULL AS A_term
      ,NULL AS CW_term
      ,NULL AS HWC_term
      ,NULL AS CP_term
      ,NULL AS HWQ_term      

      ,REPLACE(comm.comment,'"','''') COLLATE Latin1_General_BIN AS comment_value      
FROM gabby.reporting.illuminate_report_card_comments comm WITH(NOLOCK)
WHERE comm.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()