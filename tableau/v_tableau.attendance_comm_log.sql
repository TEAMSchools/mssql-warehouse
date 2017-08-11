USE gabby
GO

ALTER VIEW tableau.attendance_comm_log AS

WITH commlog AS (
  SELECT c.student_school_id        
        ,CONVERT(DATE,c.call_date_time) AS commlog_date
        ,CONCAT(u.first_name, ' ', u.last_name) AS commlog_staff_name
        ,c.reason AS commlog_reason
        ,c.response AS commlog_notes
        ,CONCAT(f.c_first, ' ', f.c_last) AS followup_staff_name      
        ,f.init_notes AS followup_init_notes
        ,f.followup_notes AS followup_close_notes
        ,f.outstanding
  FROM gabby.deanslist.communication c
  JOIN gabby.deanslist.users u
    ON c.dluser_id = u.dluser_id
  JOIN gabby.deanslist.followups f
    ON c.followup_id = f.followup_id
  WHERE reason LIKE 'att:%'
 )

SELECT s.student_number
      ,s.lastfirst
      ,s.grade_level
      ,s.team
      
      ,att.att_date
      ,CASE WHEN ac.att_code = 'true' THEN 'T' ELSE ac.att_code END AS att_code 
      
      ,CASE
        WHEN att.schoolid = 73253 THEN suf.advisor
        ELSE cc.section_number
       END AS homeroom

      ,cl.commlog_staff_name
      ,cl.commlog_reason
      ,cl.commlog_notes
      ,cl.followup_staff_name
      ,cl.followup_init_notes
      ,cl.followup_close_notes
FROM gabby.powerschool.attendance att WITH(NOLOCK)
JOIN gabby.powerschool.attendance_code ac WITH(NOLOCK)
  ON att.attendance_codeid = ac.id
 AND ac.att_code LIKE 'A%'
JOIN gabby.powerschool.students s
  ON att.studentid = s.id
LEFT OUTER JOIN gabby.powerschool.cc
  ON att.studentid = cc.studentid
 AND att.att_date BETWEEN cc.dateenrolled AND cc.dateleft
 AND cc.course_number = 'HR'
LEFT OUTER JOIN gabby.powerschool.u_studentsuserfields suf
  ON s.dcid = suf.studentsdcid
LEFT OUTER JOIN commlog cl
  ON s.student_number = cl.student_school_id
 AND att.att_date = cl.commlog_date
WHERE att.att_date >= '2017-06-01'
  AND att.att_mode_code = 'ATT_ModeDaily'
  AND att.schoolid = 73254
  AND s.grade_level < 5