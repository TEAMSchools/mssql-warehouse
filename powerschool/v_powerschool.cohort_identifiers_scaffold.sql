USE gabby
GO

CREATE OR ALTER VIEW powerschool.cohort_identifiers_scaffold AS

SELECT co.academic_year
      ,co.schoolid
      ,co.reporting_schoolid
      ,co.school_name
      ,co.school_level
      ,co.grade_level
      ,co.studentid
      ,co.student_number
      ,co.lastfirst
      ,co.team
      ,co.advisor_name
      ,co.gender
      ,co.ethnicity
      ,co.lunchstatus
      ,co.iep_status
      ,co.lep_status
      ,co.enroll_status
      ,co.entrydate
      ,co.exitdate
      
      ,rd.date
      
      ,CONVERT(VARCHAR(25),dt.alt_name) AS term
      
      ,CASE WHEN CONVERT(DATE,rd.date) BETWEEN co.entrydate AND co.exitdate THEN 1 ELSE 0 END AS is_enrolled
FROM powerschool.cohort_identifiers_static co
JOIN utilities.reporting_days rd
  ON co.academic_year = rd.academic_year
 AND co.exitdate >= rd.date
LEFT OUTER JOIN gabby.reporting.reporting_terms dt
  ON co.schoolid = dt.schoolid
 AND dt.identifier = 'RT'
 AND rd.date BETWEEN dt.start_date AND dt.end_date
WHERE co.schoolid != 999999
  AND co.rn_year = 1
  AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

UNION ALL

SELECT CONVERT(INT,academic_year) AS academic_year
      ,CONVERT(INT,schoolid) AS schoolid
      ,CONVERT(INT,reporting_schoolid) AS reporting_schoolid
      ,CONVERT(VARCHAR(25),school_name) AS school_name
      ,CONVERT(VARCHAR(5),school_level) AS school_level
      ,CONVERT(INT,grade_level) AS grade_level
      ,CONVERT(INT,studentid) AS studentid
      ,CONVERT(INT,student_number) AS student_number
      ,CONVERT(VARCHAR(125),lastfirst) AS lastfirst
      ,CONVERT(VARCHAR(25),team) AS team
      ,CONVERT(VARCHAR(125),advisor_name) AS advisor_name
      ,CONVERT(VARCHAR(1),gender) AS gender
      ,CONVERT(VARCHAR(1),ethnicity) AS ethnicity
      ,CONVERT(VARCHAR(25),lunchstatus) AS lunchstatus
      ,CONVERT(VARCHAR(25),iep_status) AS iep_status
      ,lep_status
      ,CONVERT(INT,enroll_status) AS enroll_status
      ,entrydate
      ,exitdate      
      ,date
      ,CONVERT(VARCHAR(25),term) AS term
      ,is_enrolled
FROM powerschool.cohort_identifiers_scaffold_archive