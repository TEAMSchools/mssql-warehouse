USE gabby
GO

ALTER VIEW tableau.lexia_tracker AS 

WITH prev_week_time AS (
  SELECT username
        ,gabby.utilities.DATE_TO_SY(date) AS academic_year
        ,date
        ,week_time
        ,ROW_NUMBER() OVER(
          PARTITION BY username, gabby.utilities.DATE_TO_SY(date)
            ORDER BY date DESC) AS rn
  FROM gabby.lexia.units_to_target
  WHERE DATEPART(WEEKDAY,date) = 1
 )

SELECT co.student_number
      ,co.lastfirst
      ,co.academic_year
      ,co.reporting_schoolid AS schoolid
      ,co.grade_level
      ,co.iep_status     
      
      ,enr.teacher_name
      ,enr.section_number

      ,g.target_units
      ,g.grade_level_target
      ,g.other_level_target
      
      ,pw.week_time AS prev_week_time

      ,lex.username
      ,lex.lexia_id
      ,lex.predictor
      ,lex.activity_name
      ,lex.activity_end_time
      ,lex.accuracy      
      ,lex.rate
      ,lex.percent_completed
      ,lex.status_flag_complete
      ,lex.duration_minutes
      ,lex.all_ccss_in_lr
      ,lex.grade_level_material
      ,lex.units_to_target
      ,lex.today_mins
      ,lex.today_units
      ,lex.week_time
      ,lex.weekly_target
      ,lex.meeting_target_usage            
      ,lex.struggling_indicator

      ,ISNULL(g.target_units,0) - ISNULL(lex.units_to_target,0) AS units_completed
      ,CONVERT(FLOAT,(ISNULL(g.target_units,0.0) - ISNULL(lex.units_to_target,0.0))) / CONVERT(FLOAT,g.target_units) AS pct_to_target      

      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number, co.academic_year
           ORDER BY lex.activity_start_time DESC) AS rn_curr
FROM gabby.powerschool.cohort_identifiers_static co 
JOIN gabby.powerschool.students s
  ON co.student_number = s.student_number
LEFT OUTER JOIN gabby.powerschool.course_enrollments_static enr 
  ON co.student_number = enr.student_number
 AND co.academic_year = enr.academic_year
 AND enr.course_number = 'HR'
 AND enr.section_enroll_status = 0
LEFT OUTER JOIN gabby.lexia.student_goals g
  ON co.student_number = g.student_number
 AND co.academic_year = g.academic_year
LEFT OUTER JOIN prev_week_time pw
  ON s.student_web_id = pw.username
 AND co.academic_year = pw.academic_year
 AND pw.rn = 1
JOIN gabby.lexia.student_progress lex 
  ON s.student_web_id = lex.username
 AND (lex.activity_start_time BETWEEN co.entrydate AND co.exitdate
        OR lex.activity_end_time BETWEEN co.entrydate AND co.exitdate)
WHERE co.academic_year >= 2015
  AND co.grade_level <= 8
  AND co.enroll_status = 0
  AND co.rn_year = 1