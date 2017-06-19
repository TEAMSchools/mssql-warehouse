USE gabby
GO

ALTER VIEW powerschool.cohort_identifiers_scaffold AS

SELECT co.academic_year
      ,co.schoolid
      ,co.reporting_schoolid
      ,co.school_name
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
      ,CONVERT(DATE,rd.date) AS date
      ,rd.reporting_hash
      ,NULL AS term
      --,dt.alt_name AS term
      ,CASE WHEN CONVERT(DATE,rd.date) BETWEEN co.entrydate AND co.exitdate THEN 1 ELSE 0 END AS is_enrolled
FROM gabby.powerschool.cohort_identifiers co
JOIN gabby.utilities.reporting_days rd
  ON co.academic_year = rd.academic_year
 AND co.exitdate >= rd.date
--LEFT OUTER JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
--  ON co.schoolid = dt.schoolid
-- AND co.year = dt.academic_year
-- AND dt.identifier = 'RT'
-- AND rd.date BETWEEN dt.start_date AND dt.end_date
WHERE co.schoolid != 999999
  AND co.rn_year = 1