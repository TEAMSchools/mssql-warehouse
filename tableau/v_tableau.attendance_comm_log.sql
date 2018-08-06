USE gabby
GO

CREATE OR ALTER VIEW tableau.attendance_comm_log AS

WITH y1_ada AS (
  SELECT studentid
        ,schoolid
        ,(yearid + 1990) AS academic_year
        ,AVG(CONVERT(FLOAT,attendancevalue)) AS pct_attendance
        ,SUM(ABS(attendancevalue - 1)) AS n_absences
  FROM gabby.powerschool.ps_adaadm_daily_ctod
  WHERE membershipvalue = 1
  GROUP BY studentid
          ,schoolid
          ,(yearid + 1990)
 )

,weekly_ada AS (
  SELECT studentid
        ,schoolid
        ,DATEADD(DAY, (1 - DATEPART(WEEKDAY, calendardate)), calendardate) AS week_start_date
        ,SUM(ABS(attendancevalue - 1)) AS n_absences
  FROM gabby.powerschool.ps_adaadm_daily_ctod
  WHERE membershipvalue = 1
  GROUP BY studentid
          ,schoolid
          ,DATEADD(DAY, (1 - DATEPART(WEEKDAY, calendardate)), calendardate) 
 )

,commlog AS (
  SELECT c.student_school_id
        ,c.reason AS commlog_reason
        ,c.response AS commlog_notes        
        ,c.call_topic AS commlog_topic
        ,CONVERT(DATE,c.call_date_time) AS commlog_date
        
        ,CONCAT(u.first_name, ' ', u.last_name) AS commlog_staff_name
        
        ,f.init_notes AS followup_init_notes
        ,f.followup_notes AS followup_close_notes
        ,f.outstanding
        ,CONCAT(f.c_first, ' ', f.c_last) AS followup_staff_name      
  FROM gabby.deanslist.communication c
  JOIN gabby.deanslist.users u
    ON c.dluser_id = u.dluser_id
  LEFT OUTER JOIN gabby.deanslist.followups f
    ON c.followup_id = f.followup_id
  WHERE (c.reason LIKE 'att:%' OR c.reason LIKE 'chronic%')
 )

SELECT co.student_number
      ,co.lastfirst
      ,co.academic_year
      ,co.region
      ,co.school_name
      ,co.grade_level
      ,co.team
      ,co.enroll_status      
      ,co.date AS week_start_date
      ,DATEADD(DAY, 6, co.date) AS week_end_date
      
      ,y1.pct_attendance AS y1_ada
      ,y1.n_absences AS y1_absences

      ,wk.n_absences AS wk_absences

      ,cl.commlog_reason
      ,cl.commlog_notes
      ,cl.commlog_topic
      ,cl.commlog_date
      ,cl.commlog_staff_name
      ,cl.followup_init_notes
      ,cl.followup_close_notes
      ,cl.followup_staff_name
      ,cl.outstanding      
FROM gabby.powerschool.cohort_identifiers_scaffold co
LEFT JOIN y1_ada y1
  ON co.studentid = y1.studentid
 AND co.schoolid = y1.schoolid
 AND co.academic_year = y1.academic_year
LEFT JOIN weekly_ada wk
  ON co.studentid = wk.studentid
 AND co.schoolid = wk.schoolid
 AND co.date = wk.week_start_date
LEFT JOIN commlog cl
  ON co.student_number = cl.student_school_id
 AND cl.commlog_date BETWEEN co.date AND DATEADD(DAY, 6, co.date)
WHERE DATEPART(WEEKDAY, co.date) = 1
  AND co.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)