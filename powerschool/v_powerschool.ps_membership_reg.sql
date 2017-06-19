USE gabby
GO

ALTER VIEW powerschool.ps_membership_reg AS 

SELECT ev.studentid
      ,ev.schoolid 
      ,cd.date_value AS calendardate
  		  ,(CASE 
			      WHEN ((ev.track='A' AND cd.a = 1) 
			              OR (ev.track='B' AND cd.b = 1) 
			              OR (ev.track='C' AND cd.c = 1) 
			              OR (ev.track='D' AND cd.d = 1) 
			              OR (ev.track='E' AND cd.e = 1) 
			              OR (ev.track='F' AND cd.f = 1)) THEN ev.membershipshare         
			      WHEN (ev.track is null) THEN ev.membershipshare         
			      ELSE 0         
		      END) AS studentmembership
		    ,(CASE 
			      WHEN ((ev.track='A' AND cd.a = 1) 
			              OR (ev.track='B' AND cd.b = 1) 
			              OR (ev.track='C' AND cd.c = 1) 
			              OR (ev.track='D' AND cd.d = 1) 
			              OR (ev.track='E' AND cd.e = 1) 
			              OR (ev.track='F' AND cd.f = 1)) THEN cd.membershipvalue         
			      WHEN (ev.track is null) THEN cd.membershipvalue         
			      ELSE 0         
		      END) AS calendarmembership
      ,ev.track AS student_track
      ,ev.fteid 
      ,bs.attendance_conversion_id
      ,ev.dflt_att_mode_code
      ,ev.dflt_conversion_mode_code
      ,cd.a
      ,cd.b
      ,cd.c
      ,cd.d
      ,cd.e
      ,cd.f
      ,ev.ATT_CalcCntPresentAbsent      
      ,ev.ATT_IntervalDuration
		    ,(CASE 
			      WHEN ((ev.track='A' AND cd.a = 1) 
			              OR (ev.track='B' AND cd.b = 1) 
			              OR (ev.track='C' AND cd.c = 1) 
			              OR (ev.track='D' AND cd.d = 1) 
			              OR (ev.track='E' AND cd.e = 1) 
			              OR (ev.track='F' AND cd.f = 1)) THEN 1         
			      WHEN (ev.track is null) THEN 1         
			      ELSE 0         
		      END) AS ontrack
		    ,(CASE 
		       WHEN ((ev.track='A' AND cd.a = 1) 
			              OR (ev.track='B' AND cd.b = 1) 
			              OR (ev.track='C' AND cd.c = 1) 
			              OR (ev.track='D' AND cd.d = 1) 
			              OR (ev.track='E' AND cd.e = 1) 
			              OR (ev.track='F' AND cd.f = 1)) THEN 0         
			      WHEN (ev.track is null) THEN 0         
			      ELSE 1         
	       END) AS offtrack
      ,ev.grade_level
      ,cd.bell_schedule_id
      ,cd.cycle_day_id
      ,ev.yearid                                                                  
FROM gabby.powerschool.ps_enrollment_all ev
JOIN gabby.powerschool.calendar_day cd
  ON ev.schoolid = cd.schoolid
 AND cd.insession = 1
	AND cd.date_value >= ev.entrydate
	AND cd.date_value < ev.exitdate
JOIN gabby.powerschool.bell_schedule bs
  ON cd.bell_schedule_id = bs.id