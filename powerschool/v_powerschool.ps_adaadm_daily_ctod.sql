USE gabby
GO

ALTER VIEW powerschool.ps_adaadm_daily_ctod AS 

SELECT mv.studentid
      ,mv.schoolid
      ,mv.calendardate
      ,mv.fteid
      ,mv.attendance_conversion_id          
      ,mv.grade_level
      ,mv.ontrack
      ,mv.offtrack
      ,mv.student_track          
      ,(CASE 
         WHEN ada_0.id IS NOT NULL THEN 0
         ELSE aci_real.attendance_value  				        
        END) * mv.ontrack AS attendancevalue
      ,(CASE
         WHEN adm_0.id IS NOT NULL THEN 0
         WHEN mv.studentmembership < mv.calendarmembership THEN mv.studentmembership
         ELSE mv.calendarmembership
        END) * mv.ontrack AS membershipvalue       
      ,(CASE 
         WHEN ada_1.id IS NOT NULL THEN 0
         ELSE aci_potential.attendance_value			   	         
			     END) * mv.ontrack AS potential_attendancevalue
FROM gabby.powerschool.ps_membership_reg mv
LEFT OUTER JOIN gabby.powerschool.terms t
  ON mv.calendardate BETWEEN t.firstday AND t.lastday 
 AND mv.schoolid = t.schoolid
 AND t.isyearrec = 1
LEFT OUTER JOIN gabby.powerschool.attendance_code ac
  ON t.schoolid = ac.schoolid
 AND t.yearid = ac.yearid
 AND ac.att_code IS NULL
	AND ac.presence_status_cd = 'Present'
LEFT OUTER JOIN gabby.powerschool.ps_attendance_daily ada_0 WITH(NOEXPAND)
  ON mv.studentid = ada_0.studentid
 AND mv.calendardate = ada_0.att_date
 AND ada_0.count_for_ada = 0
LEFT OUTER JOIN gabby.powerschool.ps_attendance_daily ada_1 WITH(NOEXPAND)
  ON mv.studentid = ada_1.studentid
 AND mv.calendardate = ada_1.att_date
 AND ada_1.count_for_ada = 1
LEFT OUTER JOIN gabby.powerschool.ps_attendance_daily adm_0 WITH(NOEXPAND)
  ON mv.studentid = adm_0.studentid
 AND mv.calendardate = adm_0.att_date
 AND adm_0.count_for_adm = 0
LEFT OUTER JOIN gabby.powerschool.attendance_conversion_items aci_real
  ON mv.fteid = aci_real.fteid
 AND mv.attendance_conversion_id = aci_real.attendance_conversion_id
 AND ISNULL(ada_1.attendance_codeid, ac.id) = aci_real.input_value
 AND aci_real.conversion_mode_code = 'codeday' 
LEFT OUTER JOIN gabby.powerschool.attendance_conversion_items aci_potential
  ON mv.fteid = aci_potential.fteid
 AND mv.attendance_conversion_id = aci_potential.attendance_conversion_id
 AND ac.id = aci_potential.input_value
 AND aci_potential.conversion_mode_code = 'codeday' 