CREATE OR ALTER VIEW powerschool.cohort_identifiers_scaffold_current AS

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
      
      ,CONVERT(VARCHAR(25),dt.alt_name) COLLATE Latin1_General_BIN AS term
      
      ,CASE WHEN CONVERT(DATE,rd.date) BETWEEN co.entrydate AND co.exitdate THEN 1 ELSE 0 END AS is_enrolled

      ,co.region
FROM powerschool.cohort_identifiers_static co
JOIN gabby.utilities.reporting_days rd
  ON co.academic_year = rd.academic_year
 AND co.exitdate >= rd.date
LEFT JOIN gabby.reporting.reporting_terms dt
  ON co.schoolid = dt.schoolid
 AND dt.identifier = 'RT'
 AND rd.date BETWEEN dt.start_date AND dt.end_date
WHERE co.schoolid != 999999
  AND co.rn_year = 1
  AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()