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

SELECT co.student_number
      ,co.lastfirst
      ,co.grade_level
      ,co.team
      ,co.region
      ,co.reporting_schoolid
      
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
WHERE att.att_date >= DATEFROMPARTS((gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1), 07, 01)
  AND att.att_mode_code = 'ATT_ModeDaily'