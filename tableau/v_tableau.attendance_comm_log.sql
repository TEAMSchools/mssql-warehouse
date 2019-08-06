USE gabby
GO

CREATE OR ALTER VIEW tableau.attendance_comm_log AS

WITH commlog AS (
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
  LEFT JOIN gabby.deanslist.followups f
    ON c.followup_id = f.followup_id
  WHERE (c.reason LIKE 'att:%' OR c.reason LIKE 'chronic%')
 )

,ada AS (
  SELECT psa.studentid
        ,psa.db_name
        ,psa.yearid + 1990 AS academic_year
        ,ROUND(AVG(CAST(psa.attendancevalue AS FLOAT)), 2) AS ada
  FROM gabby.powerschool.ps_adaadm_daily_ctod psa   
  WHERE psa.membershipvalue = 1
    AND psa.calendardate <= CAST(SYSDATETIME() AS DATE)
  GROUP BY psa.studentid
          ,psa.yearid
          ,psa.db_name
 )
 
,gpa_y1 AS (
  SELECT db_name
        ,student_number
        ,academic_year
        ,schoolid
        ,gpa_y1
        ,n_failing_y1

  FROM powerschool.gpa_detail

  WHERE is_curterm = 1
 )

,reading AS (
  SELECT student_number
      ,schoolid
      ,academic_year
      ,read_lvl
      ,goal_status
      ,gleq

  FROM lit.achieved_by_round_static

  WHERE is_curterm = 1
 )

SELECT co.student_number
      ,co.lastfirst
      ,co.academic_year
      ,co.region
      ,co.reporting_schoolid
      ,co.grade_level
      ,co.team
      ,co.iep_status
      ,co.gender
      ,co.is_retained_year
      ,co.enroll_status

      ,att.att_date
      ,att.att_comment
      ,CASE WHEN ac.att_code = 'true' THEN 'T' ELSE ac.att_code END AS att_code 
      
      ,CASE
        WHEN att.schoolid = 73253 THEN co.advisor_name
        ELSE cc.section_number
       END AS homeroom

      ,cl.commlog_staff_name
      ,cl.commlog_reason
      ,cl.commlog_notes
      ,cl.commlog_topic
      ,cl.followup_staff_name
      ,cl.followup_init_notes
      ,cl.followup_close_notes

      ,rt.alt_name AS term

      ,ada.ada

      ,r.read_lvl
      ,r.goal_status

      ,gpa.gpa_y1
      ,gpa.n_failing_y1

      ,ROW_NUMBER() OVER(
         PARTITION BY att.studentid, att.att_date
           ORDER BY cl.student_school_id DESC) AS rn_date
FROM gabby.powerschool.attendance_clean att
JOIN gabby.powerschool.attendance_code ac
  ON att.attendance_codeid = ac.id
 AND att.db_name = ac.db_name
 AND ac.att_code LIKE 'A%'
LEFT JOIN gabby.powerschool.cc
  ON att.studentid = cc.studentid
 AND att.db_name = cc.db_name
 AND att.att_date BETWEEN cc.dateenrolled AND cc.dateleft
 AND cc.course_number = 'HR'
JOIN gabby.powerschool.cohort_identifiers_static co
  ON att.studentid = co.studentid
 AND att.db_name = co.db_name
 AND att.att_date BETWEEN co.entrydate AND co.exitdate
LEFT JOIN commlog cl
  ON co.student_number = cl.student_school_id
 AND att.att_date = cl.commlog_date
JOIN ada
  ON ada.studentid = co.studentid
 AND ada.db_name = co.db_name
 AND ada.academic_year = co.academic_year
LEFT JOIN gpa_y1 gpa
  ON gpa.academic_year = co.academic_year
 AND gpa.db_name = co.db_name
 AND gpa.schoolid = co.schoolid
 AND gpa.student_number = co.student_number
LEFT JOIN reading r
  ON r.student_number = co.student_number
 AND r.academic_year = co.academic_year
 AND r.schoolid = co.schoolid
LEFT JOIN gabby.reporting.reporting_terms rt 
 ON co.schoolid = rt.schoolid
AND co.yearid = rt.yearid
AND att.att_date BETWEEN rt.[start_date] AND rt.end_date
AND rt.identifier = 'RT'

WHERE att.att_date >= DATEFROMPARTS((gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1), 07, 01)
  AND att.att_mode_code = 'ATT_ModeDaily'
