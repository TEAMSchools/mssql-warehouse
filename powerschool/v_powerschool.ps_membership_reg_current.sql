CREATE OR ALTER VIEW powerschool.ps_membership_reg_current AS 

SELECT ev.studentid
      ,ev.schoolid 
      ,ev.track AS student_track
      ,ev.fteid 
      ,ev.dflt_att_mode_code
      ,ev.dflt_conversion_mode_code
      ,ev.att_calccntpresentabsent      
      ,ev.att_intervalduration
      ,ev.grade_level
      ,ev.yearid      

      ,cd.date_value AS calendardate
      ,CONVERT(INT,cd.a) AS a
      ,CONVERT(INT,cd.b) AS b
      ,CONVERT(INT,cd.c) AS c
      ,CONVERT(INT,cd.d) AS d
      ,CONVERT(INT,cd.e) AS e
      ,CONVERT(INT,cd.f) AS f
      ,CONVERT(INT,cd.bell_schedule_id) AS bell_schedule_id
      ,CONVERT(INT,cd.cycle_day_id) AS cycle_day_id
  		  
      ,CONVERT(INT,bs.attendance_conversion_id) AS attendance_conversion_id

		    ,(CASE 
			      WHEN ((ev.track='A' AND cd.a = 1) 
			         OR (ev.track='B' AND cd.b = 1) 
			         OR (ev.track='C' AND cd.c = 1) 
			         OR (ev.track='D' AND cd.d = 1) 
			         OR (ev.track='E' AND cd.e = 1) 
			         OR (ev.track='F' AND cd.f = 1)) THEN ev.membershipshare         
			      WHEN (ev.track IS NULL) THEN ev.membershipshare         
			      ELSE 0         
		      END) AS studentmembership
      ,(CASE 
			      WHEN ((ev.track='A' AND cd.a = 1) 
			         OR (ev.track='B' AND cd.b = 1) 
			         OR (ev.track='C' AND cd.c = 1) 
			         OR (ev.track='D' AND cd.d = 1) 
			         OR (ev.track='E' AND cd.e = 1) 
			         OR (ev.track='F' AND cd.f = 1)) THEN CONVERT(INT,cd.membershipvalue)
			      WHEN (ev.track IS NULL) THEN CONVERT(INT,cd.membershipvalue)
			      ELSE 0         
		      END) AS calendarmembership
		    ,(CASE 
			      WHEN ((ev.track='A' AND cd.a = 1) 
			         OR (ev.track='B' AND cd.b = 1) 
			         OR (ev.track='C' AND cd.c = 1) 
			         OR (ev.track='D' AND cd.d = 1) 
			         OR (ev.track='E' AND cd.e = 1) 
			         OR (ev.track='F' AND cd.f = 1)) THEN 1         
			      WHEN (ev.track IS NULL) THEN 1         
			      ELSE 0         
		      END) AS ontrack
		    ,(CASE 
		       WHEN ((ev.track='A' AND cd.a = 1) 
			         OR (ev.track='B' AND cd.b = 1) 
			         OR (ev.track='C' AND cd.c = 1) 
			         OR (ev.track='D' AND cd.d = 1) 
			         OR (ev.track='E' AND cd.e = 1) 
			         OR (ev.track='F' AND cd.f = 1)) THEN 0         
			      WHEN (ev.track IS NULL) THEN 0         
			      ELSE 1         
	       END) AS offtrack
FROM gabby.powerschool.ps_enrollment_all_static ev 
JOIN gabby.powerschool.calendar_day cd 
  ON ev.schoolid = cd.schoolid
 AND cd.insession = 1
	AND cd.date_value >= ev.entrydate
	AND cd.date_value < ev.exitdate
JOIN gabby.powerschool.bell_schedule bs
  ON cd.bell_schedule_id = bs.id
WHERE ev.yearid = (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1990)