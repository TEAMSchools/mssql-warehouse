CREATE OR ALTER VIEW powerschool.ps_attendance_meeting AS 

SELECT att.id
		    ,att.studentid
		    ,att.schoolid
		    ,att.att_date
		    ,att.attendance_codeid
      ,att.att_mode_code
		    ,att.att_interval
		    ,att.calendar_dayid
		    ,att.ccid
      ,att.periodid
      ,att.programid
      ,att.total_minutes

		    ,CASE WHEN ac.att_code = 'true' THEN 'T' ELSE ac.att_code END AS att_code 
      ,ac.calculate_ada_yn
		    ,ac.presence_status_cd
      ,ac.course_credit_points

		    ,cc.schoolid AS cc_schoolid
      ,(CASE WHEN cc.sectionid < 0 THEN 1 ELSE 0 END) AS dropped
      		    
		    ,per.abbreviation AS period_abbreviation
		    ,per.period_number

		    ,s.id AS sectionid
		    ,s.section_number
		    
		    ,cd.a
		    ,cd.b
		    ,cd.c
		    ,cd.d
		    ,cd.e
		    ,cd.f
		    ,cd.insession
		    ,cd.cycle_day_id

		    ,cy.abbreviation
FROM gabby.powerschool.attendance att
JOIN gabby.powerschool.cc 
  ON att.ccid = cc.id 
 AND att.studentid = cc.studentid
JOIN gabby.powerschool.sections s 
  ON ABS(cc.sectionid) = s.id
JOIN gabby.powerschool.calendar_day cd 
  ON att.calendar_dayid = cd.id
JOIN gabby.powerschool.attendance_code ac 
  ON att.attendance_codeid = ac.id
JOIN gabby.powerschool.cycle_day cy 
  ON cd.cycle_day_id = cy.id
JOIN gabby.powerschool.period per 
  ON att.periodid = per.id
WHERE att.att_date >= cc.dateenrolled 
	 AND att.att_date < cc.dateleft
	 AND att.att_mode_code = 'ATT_ModeMeeting'