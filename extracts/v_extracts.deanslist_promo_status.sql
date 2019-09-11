USE gabby;
GO

CREATE OR ALTER VIEW extracts.deanslist_promo_status AS 

SELECT ps.student_number
      ,ps.academic_year
      ,ps.alt_name AS term
      ,ps.promo_status_overall
      ,ps.promo_status_attendance
      ,ps.promo_status_lit
      ,ps.promo_status_grades
      ,ps.promo_status_qa_math

      ,gpa.gpa_term AS gpa_term
      ,gpa.gpa_y1 AS gpa_y1

      ,cum.cumulative_Y1_gpa AS gpa_cum
FROM gabby.reporting.promotional_status ps
LEFT JOIN gabby.powerschool.gpa_detail gpa
  ON ps.student_number = gpa.student_number
 AND ps.academic_year = gpa.academic_year
 AND ps.alt_name = gpa.term_name COLLATE Latin1_General_BIN
LEFT JOIN gabby.powerschool.gpa_cumulative cum
  ON ps.studentid = cum.studentid
 AND ps.schoolid = cum.schoolid
 AND ps.[db_name] = cum.[db_name]
WHERE ps.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR();