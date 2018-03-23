USE gabby
GO

CREATE OR ALTER VIEW powerschool.ps_adaadm_daily_ctod AS 

SELECT padcc.studentid
      ,padcc.schoolid
      ,padcc.calendardate
      ,padcc.fteid
      ,padcc.attendance_conversion_id          
      ,padcc.grade_level
      ,padcc.ontrack
      ,padcc.offtrack
      ,padcc.student_track
      ,padcc.yearid
      ,padcc.attendancevalue
      ,padcc.membershipvalue
      ,padcc.potential_attendancevalue      
FROM gabby.powerschool.ps_adaadm_daily_ctod_current_static padcc

UNION ALL

SELECT padca.studentid
      ,padca.schoolid
      ,padca.calendardate
      ,padca.fteid
      ,padca.attendance_conversion_id          
      ,padca.grade_level
      ,padca.ontrack
      ,padca.offtrack
      ,padca.student_track
      ,padca.yearid
      ,padca.attendancevalue
      ,padca.membershipvalue
      ,padca.potential_attendancevalue      
FROM gabby.powerschool.ps_adaadm_daily_ctod_archive padca