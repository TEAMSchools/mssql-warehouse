USE gabby
GO

CREATE OR ALTER VIEW tableau.hs_early_warning AS

WITH attendance AS (
  SELECT mem.studentid
        ,mem.[db_name]
        ,ROUND(AVG(CONVERT(FLOAT, mem.attendancevalue)), 3) AS ada
  FROM gabby.powerschool.ps_adaadm_daily_ctod_current_static mem
  WHERE mem.membershipvalue = 1
  GROUP BY mem.studentid
          ,mem.[db_name]
 )

,suspension AS (
  SELECT ics.student_school_id
        ,ics.create_academic_year

        ,COUNT(ips.incidentpenaltyid) AS suspension_count
        ,SUM(ips.numdays) AS suspension_days
  FROM gabby.deanslist.incidents_penalties_static ips
  LEFT JOIN gabby.deanslist.incidents_clean_static ics
    ON ips.incident_id = ics.incident_id
   AND ips.[db_name] = ics.[db_name]
  WHERE ips.issuspension = 1
  GROUP BY ics.student_school_id
          ,ics.create_academic_year
 )

SELECT co.studentid
      ,co.student_number
      ,co.lastfirst
      ,co.dob      
      ,co.academic_year
      ,co.region
      ,co.school_level
      ,co.schoolid
      ,co.reporting_schoolid
      ,co.school_name
      ,co.grade_level
      ,co.cohort
      ,co.team
      ,co.advisor_name   
      ,co.iep_status
      ,co.lep_status
      ,co.c_504_status
      ,co.gender
      ,co.ethnicity
      ,co.enroll_status
      ,co.boy_status
      ,co.is_retained_year
      ,co.is_retained_ever
      ,co.year_in_network
      ,co.[db_name]

      ,dt.alt_name AS term_name
      ,dt.time_per_name AS reporting_term
      ,dt.[start_date] AS term_start_date
      ,dt.[end_date] AS term_end_date

      ,gr.credittype
      ,gr.course_name
      ,gr.course_number
      ,gr.credit_hours
      ,gr.teacher_name
      ,gr.term_grade_percent_adjusted
      ,gr.term_grade_letter_adjusted
      ,gr.y1_grade_percent_adjusted
      ,gr.y1_grade_letter
      ,gr.need_65
      ,gr.is_curterm
      
      ,gpa.gpa_y1
      ,gpa.gpa_y1_unweighted
      ,gpa.gpa_term
      
      ,gpc.cumulative_Y1_gpa
      ,gpc.cumulative_Y1_gpa_projected
      ,gpc.earned_credits_cum
      ,gpc.earned_credits_cum_projected
      ,gpc.potential_credits_cum

      ,att.ada

      ,sus.suspension_count
      ,sus.suspension_days
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.reporting.reporting_terms dt
  ON co.academic_year = dt.academic_year
 AND co.schoolid = dt.schoolid
 AND dt.identifier = 'RT'
 AND dt._fivetran_deleted = 0
 AND dt.alt_name NOT IN ('Summer School', 'Y1')
LEFT JOIN gabby.powerschool.final_grades_static gr
  ON co.student_number = gr.student_number
 AND co.academic_year = gr.academic_year
 AND dt.time_per_name = gr.reporting_term COLLATE Latin1_General_BIN
 AND gr.excludefromgpa = 0
LEFT JOIN gabby.powerschool.gpa_detail gpa
  ON co.student_number = gpa.student_number
 AND co.academic_year = gpa.academic_year
 AND dt.time_per_name = gpa.reporting_term COLLATE Latin1_General_BIN
LEFT JOIN gabby.powerschool.gpa_cumulative gpc
  ON co.studentid = gpc.studentid
 AND co.schoolid = gpc.schoolid
 AND co.[db_name] = gpc.[db_name]
LEFT JOIN attendance att
  ON co.studentid = att.studentid
 AND co.[db_name] = att.[db_name]
LEFT JOIN suspension AS sus
  ON co.student_number = sus.student_school_id
 AND co.academic_year = sus.create_academic_year
WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND co.rn_year = 1
  AND co.is_enrolled_recent = 1
  AND co.grade_level >= 9
