USE gabby
GO

ALTER VIEW powerschool.ps_attendance_daily WITH SCHEMABINDING AS 

SELECT att.id
      ,att.studentid
      ,att.schoolid
      ,att.att_date
      ,att.attendance_codeid       
      ,att.att_mode_code
      ,att.calendar_dayid
      ,att.programid
      ,att.total_minutes

      ,ac.att_code
      ,ac.calculate_ada_yn AS count_for_ada
      ,ac.presence_status_cd
      ,ac.calculate_adm_yn AS count_for_adm

      ,cd.a
      ,cd.b
      ,cd.c
      ,cd.d
      ,cd.e
      ,cd.f
      ,cd.insession
      ,cd.cycle_day_id      
  
      ,cy.abbreviation           
FROM powerschool.attendance att
JOIN powerschool.attendance_code ac
  ON att.attendance_codeid = ac.id
JOIN powerschool.calendar_day cd
  ON att.calendar_dayid = cd.id
JOIN powerschool.cycle_day cy
  ON cd.cycle_day_id = cy.id
WHERE att.att_mode_code = 'ATT_ModeDaily'