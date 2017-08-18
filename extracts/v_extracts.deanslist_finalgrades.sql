USE gabby
GO

ALTER VIEW extracts.deanslist_finalgrades AS

SELECT fg.student_number
      ,fg.academic_year
      ,fg.term_name AS term
      ,fg.course_number
      ,fg.course_name
      ,fg.sectionid            
      ,fg.teacher_name
      ,fg.credit_hours
      ,ABS(fg.excludefromgpa - 1) AS include_grades_display      
      
      /* final grades */
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

      /* other */
      ,sec.dcid AS sections_dcid
      ,sec.section_number      
      
      ,ISNULL(cc.currentabsences, 0) AS currentabsences
      ,ISNULL(cc.currenttardies, 0) AS currenttardies

      ,REPLACE(comm.comment_value,'"','''') AS comment_value
FROM gabby.powerschool.final_grades_wide fg
LEFT OUTER JOIN gabby.powerschool.category_grades_wide cat
  ON fg.student_number = cat.student_number
 AND fg.academic_year = cat.academic_year
 AND fg.course_number = cat.course_number
 AND fg.reporting_term = cat.reporting_term
LEFT OUTER JOIN gabby.powerschool.pgfinalgrades comm
  ON fg.studentid = comm.studentid
 AND fg.sectionid = comm.sectionid
 AND fg.term_name = comm.finalgradename
LEFT OUTER JOIN gabby.powerschool.sections sec
  ON fg.sectionid = sec.id
LEFT OUTER JOIN gabby.powerschool.cc 
  ON fg.studentid = cc.studentid
 AND fg.sectionid = cc.sectionid
WHERE fg.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1
  AND fg.reporting_term != 'CUR'

UNION ALL

SELECT comm.student_number
      ,comm.academic_year
      ,comm.term
      ,comm.subject AS course_number
      ,comm.subject AS COURSE_NAME
      ,NULL AS sectionid
      ,NULL AS sections_dcid
      ,NULL AS section_number
      ,NULL AS teacher_name
      ,NULL AS credit_hours
      ,0 AS include_grades_display
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
      ,NULL AS currentabsences
      ,NULL AS currenttardies
FROM KIPP_NJ..REPORTING$report_card_comments#ES#static comm WITH(NOLOCK)  
WHERE CONVERT(VARCHAR,comm.comment) IS NOT NULL
  AND comm.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()