CREATE OR ALTER VIEW
  extracts.deanslist_promo_status AS
SELECT
  ps.student_number,
  ps.academic_year,
  ps.alt_name AS term,
  ps.promo_status_overall,
  ps.promo_status_attendance,
  ps.promo_status_lit,
  ps.promo_status_grades,
  ps.promo_status_qa_math,
  ps.grades_y1_credits_projected,
  ps.grades_y1_credits_enrolled,
  ps.grades_y1_failing_projected,
  gpa.gpa_term AS gpa_term,
  gpa.gpa_y1 AS gpa_y1,
  cum.cumulative_y1_gpa AS gpa_cum,
  cum.cumulative_y1_gpa_projected AS gpa_cum_projected
FROM
  reporting.promotional_status AS ps
  LEFT JOIN powerschool.gpa_detail AS gpa ON (
    ps.student_number = gpa.student_number
    AND ps.academic_year = gpa.academic_year
    AND ps.alt_name = gpa.term_name
  )
  LEFT JOIN powerschool.gpa_cumulative AS cum ON (
    ps.studentid = cum.studentid
    AND ps.schoolid = cum.schoolid
    AND ps.[db_name] = cum.[db_name]
  )
WHERE
  ps.academic_year = utilities.GLOBAL_ACADEMIC_YEAR ();
