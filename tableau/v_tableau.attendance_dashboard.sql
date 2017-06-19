USE gabby
GO

ALTER VIEW tableau.attendance_dashboard AS

SELECT co.academic_year
      ,co.reporting_schoolid AS schoolid
      ,co.studentid
      ,co.student_number
      ,co.lastfirst
      ,co.grade_level
      ,co.school_level
      ,co.team
      ,co.enroll_status
      ,co.iep_status
      ,co.gender
      ,co.ethnicity
      
      ,NULL AS term

      ,mem.calendardate
      ,mem.membershipvalue
      ,mem.attendancevalue AS is_present
      ,ABS(mem.attendancevalue - 1) AS is_absent
      --,mem.last_updated
      
      ,att.att_code
      ,CASE WHEN att.att_code IN ('T','T10','ET','TE') THEN 1 ELSE 0 END AS is_tardy
      ,CASE WHEN att.att_code IN ('OSS','ISS') THEN 1 ELSE 0 END AS suspension_all

      ,enr.section_number
      ,enr.teacher_name

      ,CASE WHEN att.att_code = 'A' THEN 1 ELSE 0 END AS n_A
      ,CASE WHEN att.att_code = 'AD' THEN 1 ELSE 0 END AS n_AD
      ,CASE WHEN att.att_code = 'AE' THEN 1 ELSE 0 END AS n_AE
      ,CASE WHEN att.att_code = 'A-E' THEN 1 ELSE 0 END AS n_A_E
      ,CASE WHEN att.att_code = 'CR' THEN 1 ELSE 0 END AS n_CR
      ,CASE WHEN att.att_code = 'CS' THEN 1 ELSE 0 END AS n_CS
      ,CASE WHEN att.att_code = 'D' THEN 1 ELSE 0 END AS n_D
      ,CASE WHEN att.att_code = 'E' THEN 1 ELSE 0 END AS n_E
      ,CASE WHEN att.att_code = 'EA' THEN 1 ELSE 0 END AS n_EA
      ,CASE WHEN att.att_code = 'ET' THEN 1 ELSE 0 END AS n_ET
      ,CASE WHEN att.att_code = 'EV' THEN 1 ELSE 0 END AS n_EV
      ,CASE WHEN att.att_code = 'ISS' THEN 1 ELSE 0 END AS n_ISS
      ,CASE WHEN att.att_code = 'NM' THEN 1 ELSE 0 END AS n_NM
      ,CASE WHEN att.att_code = 'OS' THEN 1 ELSE 0 END AS n_OS
      ,CASE WHEN att.att_code = 'OSS' THEN 1 ELSE 0 END AS n_OSS
      ,CASE WHEN att.att_code = 'OSSP' THEN 1 ELSE 0 END AS n_OSSP
      ,CASE WHEN att.att_code = 'PLE' THEN 1 ELSE 0 END AS n_PLE
      ,CASE WHEN att.att_code = 'Q' THEN 1 ELSE 0 END AS n_Q
      ,CASE WHEN att.att_code = 'S' THEN 1 ELSE 0 END AS n_S
      ,CASE WHEN att.att_code = 'SE' THEN 1 ELSE 0 END AS n_SE
      ,CASE WHEN att.att_code = 'T' THEN 1 ELSE 0 END AS n_T
      ,CASE WHEN att.att_code = 'T10' THEN 1 ELSE 0 END AS n_T10
      ,CASE WHEN att.att_code = 'TE' THEN 1 ELSE 0 END AS n_TE
      ,CASE WHEN att.att_code = 'TLE' THEN 1 ELSE 0 END AS n_TLE
      ,CASE WHEN att.att_code = 'U' THEN 1 ELSE 0 END AS n_U
      ,CASE WHEN att.att_code = 'X' THEN 1 ELSE 0 END AS n_X
      
      ,MAX(CASE WHEN att.att_code = 'OS' THEN 1 ELSE 0 END 
            + CASE WHEN att.att_code = 'OSS' THEN 1 ELSE 0 END 
            + CASE WHEN att.att_code = 'OSSP' THEN 1 ELSE 0 END) 
         OVER(PARTITION BY co.student_number, co.academic_year
              ORDER BY mem.calendardate) AS is_oss_running
      ,MAX(CASE WHEN att.att_code = 'S' THEN 1 ELSE 0 END 
            + CASE WHEN att.att_code = 'ISS' THEN 1 ELSE 0 END) 
         OVER(PARTITION BY co.student_number, co.academic_year
              ORDER BY mem.calendardate) AS is_iss_running
      ,MAX(CASE WHEN att.att_code = 'OS' THEN 1 ELSE 0 END 
            + CASE WHEN att.att_code = 'OSS' THEN 1 ELSE 0 END 
            + CASE WHEN att.att_code = 'OSSP' THEN 1 ELSE 0 END
            + CASE WHEN att.att_code = 'S' THEN 1 ELSE 0 END 
            + CASE WHEN att.att_code = 'ISS' THEN 1 ELSE 0 END) 
         OVER(PARTITION BY co.student_number, co.academic_year
              ORDER BY mem.calendardate) AS is_suspended_running
FROM gabby.powerschool.cohort_identifiers co
JOIN gabby.powerschool.ps_adaadm_daily_ctod mem
  ON co.studentid = mem.studentid
 AND co.schoolid = mem.schoolid
 AND mem.calendardate BETWEEN co.entrydate AND co.exitdate
 AND mem.calendardate <= CONVERT(DATE,GETDATE()) 
 AND mem.membershipvalue > 0
 AND mem.attendancevalue IS NOT NULL
LEFT OUTER JOIN gabby.powerschool.ps_attendance_daily att
  ON co.studentid = att.studentid
 AND mem.calendardate = att.att_date
--LEFT OUTER JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK) 
--  ON co.schoolid = dt.schoolid
-- AND co.year = dt.academic_year
-- AND mem.CALENDARDATE BETWEEN dt.start_date AND dt.end_date
-- AND dt.identifier = 'RT'
LEFT OUTER JOIN gabby.powerschool.course_enrollments enr WITH(NOLOCK)
  ON co.studentid = enr.studentid
 AND mem.calendardate BETWEEN enr.dateenrolled AND enr.dateleft
 AND enr.course_number = 'HR' 
--WHERE co.academic_year = gabby.utility.GLOBAL_ACADEMIC_YEAR()