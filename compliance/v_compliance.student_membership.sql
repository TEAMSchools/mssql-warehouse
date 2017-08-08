USE gabby
GO

ALTER VIEW compliance.student_membership AS

SELECT co.student_number      
      ,co.academic_year
      ,co.school_name
      ,co.grade_level
      ,SUM(CONVERT(INT,mem.attendancevalue)) AS att
      ,SUM(CONVERT(INT,mem.membershipvalue)) AS mem
      ,SUM(CONVERT(INT,mem.membershipvalue)) - SUM(CONVERT(INT,mem.attendancevalue)) AS absences
FROM gabby.powerschool.cohort_identifiers_static co
JOIN gabby.powerschool.ps_adaadm_daily_ctod_static mem
  ON co.studentid = mem.studentid
 AND co.academic_year = gabby.utilities.DATE_TO_SY(mem.calendardate)
WHERE co.schoolid != 999999
  AND co.rn_year = 1
GROUP BY co.student_number      
        ,co.school_name
        ,co.grade_level
        ,co.academic_year