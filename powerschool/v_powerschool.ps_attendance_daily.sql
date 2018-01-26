USE gabby
GO

CREATE OR ALTER VIEW powerschool.ps_attendance_daily AS 

SELECT CONVERT(INT,att.id) AS id
      ,CONVERT(INT,att.studentid) AS studentid
      ,CONVERT(INT,att.schoolid) AS schoolid
      ,att.att_date
      ,CONVERT(INT,att.attendance_codeid) AS attendance_codeid
      ,CONVERT(VARCHAR(25),att.att_mode_code) AS att_mode_code
      ,CONVERT(INT,att.calendar_dayid) AS calendar_dayid
      ,CONVERT(INT,att.programid) AS programid
      ,CONVERT(INT,att.total_minutes) AS total_minutes

      ,CASE WHEN ac.att_code = 'true' THEN 'T' ELSE CONVERT(VARCHAR(5),ac.att_code) END AS att_code 
      ,CONVERT(INT,ac.calculate_ada_yn) AS count_for_ada
      ,CONVERT(VARCHAR(25),ac.presence_status_cd) AS presence_status_cd
      ,CONVERT(INT,ac.calculate_adm_yn) AS count_for_adm

      ,CONVERT(INT,cd.a) AS a
      ,CONVERT(INT,cd.b) AS b
      ,CONVERT(INT,cd.c) AS c
      ,CONVERT(INT,cd.d) AS d
      ,CONVERT(INT,cd.e) AS e
      ,CONVERT(INT,cd.f) AS f
      ,CONVERT(INT,cd.insession) AS insession
      ,CONVERT(INT,cd.cycle_day_id) AS cycle_day_id
  
      ,CONVERT(VARCHAR(25),cy.abbreviation) AS abbreviation
FROM gabby.powerschool.attendance att 
JOIN gabby.powerschool.attendance_code ac 
  ON att.attendance_codeid = ac.id
JOIN gabby.powerschool.calendar_day cd
  ON att.calendar_dayid = cd.id
JOIN gabby.powerschool.cycle_day cy
  ON cd.cycle_day_id = cy.id
WHERE att.att_mode_code = 'ATT_ModeDaily'