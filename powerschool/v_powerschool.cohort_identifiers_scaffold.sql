CREATE OR ALTER VIEW powerschool.cohort_identifiers_scaffold AS

SELECT academic_year
      ,schoolid
      ,reporting_schoolid
      ,school_name
      ,school_level
      ,grade_level
      ,studentid
      ,student_number
      ,lastfirst
      ,team
      ,advisor_name
      ,gender
      ,ethnicity
      ,lunchstatus
      ,iep_status
      ,lep_status
      ,enroll_status
      ,entrydate
      ,exitdate      
      ,date      
      ,term      
      ,is_enrolled
FROM powerschool.cohort_identifiers_scaffold_current_static

UNION ALL

SELECT academic_year
      ,schoolid
      ,reporting_schoolid
      ,school_name
      ,school_level
      ,grade_level
      ,studentid
      ,student_number
      ,lastfirst
      ,team
      ,advisor_name
      ,gender
      ,ethnicity
      ,lunchstatus
      ,iep_status
      ,lep_status
      ,enroll_status
      ,entrydate
      ,exitdate      
      ,date      
      ,term      
      ,is_enrolled
FROM powerschool.cohort_identifiers_scaffold_archive