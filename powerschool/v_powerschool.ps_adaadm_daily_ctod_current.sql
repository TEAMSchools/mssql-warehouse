CREATE OR ALTER VIEW powerschool.ps_adaadm_daily_ctod_current AS 

WITH terms_attendance_code AS (
  SELECT t.firstday
        ,t.lastday
        ,CONVERT(INT,t.schoolid) AS schoolid
        ,CONVERT(INT,t.yearid) AS yearid
      
        ,CONVERT(INT,ac.id) AS id
  FROM powerschool.terms t  
  LEFT JOIN powerschool.attendance_code ac
    ON t.schoolid = ac.schoolid
   AND t.yearid = ac.yearid
   AND ac.[description] = 'Present'
  WHERE t.isyearrec = 1
 )

,aci AS (
  SELECT CONVERT(INT,attendance_value) AS attendance_value
        ,CONVERT(INT,fteid) AS fteid
        ,CONVERT(INT,attendance_conversion_id) AS attendance_conversion_id
        ,CONVERT(INT,input_value) AS input_value
  FROM powerschool.attendance_conversion_items 
  WHERE conversion_mode_code = 'codeday'
 )

SELECT mv.studentid
      ,mv.schoolid
      ,mv.calendardate
      ,mv.fteid
      ,mv.attendance_conversion_id          
      ,mv.grade_level
      ,mv.ontrack
      ,mv.offtrack
      ,mv.student_track          

      ,CONVERT(INT,tac.yearid) AS yearid

      ,(CASE 
         WHEN ada_0.id IS NOT NULL THEN 0
         ELSE CONVERT(INT,aci_real.attendance_value)
        END) * mv.ontrack AS attendancevalue
      ,(CASE
         WHEN adm_0.id IS NOT NULL THEN 0
         WHEN mv.studentmembership < mv.calendarmembership THEN mv.studentmembership
         ELSE mv.calendarmembership
        END) * mv.ontrack AS membershipvalue       
      ,(CASE 
         WHEN ada_1.id IS NOT NULL THEN 0
         ELSE CONVERT(INT,aci_potential.attendance_value)
        END) * mv.ontrack AS potential_attendancevalue
FROM powerschool.ps_membership_reg_current mv
LEFT JOIN terms_attendance_code tac
  ON mv.calendardate BETWEEN tac.firstday AND tac.lastday 
 AND mv.schoolid = tac.schoolid
LEFT JOIN powerschool.ps_attendance_daily_current ada_0
  ON mv.studentid = ada_0.studentid
 AND mv.calendardate = ada_0.att_date
 AND ada_0.count_for_ada = 0
LEFT JOIN powerschool.ps_attendance_daily_current ada_1
  ON mv.studentid = ada_1.studentid
 AND mv.calendardate = ada_1.att_date
 AND ada_1.count_for_ada = 1
LEFT JOIN powerschool.ps_attendance_daily_current adm_0
  ON mv.studentid = adm_0.studentid
 AND mv.calendardate = adm_0.att_date
 AND adm_0.count_for_adm = 0
LEFT JOIN aci aci_real
  ON mv.fteid = aci_real.fteid
 AND mv.attendance_conversion_id = aci_real.attendance_conversion_id
 AND ISNULL(ada_1.attendance_codeid, tac.id) = aci_real.input_value 
LEFT JOIN aci aci_potential
  ON mv.fteid = aci_potential.fteid
 AND mv.attendance_conversion_id = aci_potential.attendance_conversion_id
 AND tac.id = aci_potential.input_value 