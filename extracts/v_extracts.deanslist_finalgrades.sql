USE gabby
GO

ALTER VIEW extracts.deanslist_finalgrades AS

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
FROM gabby.powerschool.course_section_scaffold_static o WITH(NOLOCK)
JOIN gabby.powerschool.sections sec WITH(NOLOCK)
  ON o.sectionid = sec.id
JOIN gabby.powerschool.courses cou WITH(NOLOCK)
  ON o.course_number = cou.course_number
JOIN gabby.powerschool.cc WITH(NOLOCK)
  ON o.studentid = cc.studentid
 AND o.sectionid = cc.sectionid
LEFT OUTER JOIN gabby.powerschool.final_grades_wide fg WITH(NOLOCK)
  ON o.student_number = fg.student_number
 AND (o.yearid + 1990) = fg.academic_year
 AND o.course_number = fg.course_number
 AND o.term_name = fg.term_name
 AND fg.reporting_term != 'CUR'
LEFT OUTER JOIN gabby.powerschool.category_grades_wide cat WITH(NOLOCK)
  ON o.student_number = cat.student_number
 AND (o.yearid + 1990) = cat.academic_year
 AND fg.course_number = cat.course_number
 AND fg.reporting_term = cat.reporting_term 
LEFT OUTER JOIN gabby.powerschool.pgfinalgrades comm WITH(NOLOCK)
  ON fg.studentid = comm.studentid
 AND fg.sectionid = comm.sectionid
 AND fg.term_name = comm.finalgradename
WHERE (o.yearid + 1990) = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

UNION ALL

SELECT comm.student_number
      ,comm.academic_year
      ,comm.term_name
      ,comm.comment_subject AS course_number      
      
      ,NULL AS sectionid      
      ,NULL AS sections_dcid
      ,NULL AS section_number

      ,comm.comment_subject AS course_name
      
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

      ,REPLACE(comm.comment,'"','''') AS comment_value      
FROM gabby.reporting.illuminate_report_card_comments comm WITH(NOLOCK)
WHERE comm.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()