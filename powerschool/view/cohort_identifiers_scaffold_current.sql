CREATE OR ALTER VIEW
  powerschool.cohort_identifiers_scaffold_current AS
SELECT
  co.studentid,
  co.student_number,
  co.lastfirst,
  co.academic_year,
  co.region,
  co.school_level,
  co.schoolid,
  co.reporting_schoolid,
  co.school_name,
  co.grade_level,
  co.team,
  co.advisor_name,
  co.gender,
  co.ethnicity,
  co.lunchstatus,
  co.iep_status,
  co.lep_status,
  co.enroll_status,
  co.entrydate,
  co.exitdate,
  rd.[date],
  dt.alt_name
COLLATE Latin1_General_BIN AS term
-- ,CASE WHEN CAST(rd.[date] AS DATE) (BETWEEN co.entrydate AND co.exitdate) THEN 1 ELSE 0 END AS is_enrolled
FROM
  powerschool.cohort_identifiers_static AS co
  INNER JOIN gabby.utilities.reporting_days AS rd ON co.academic_year = rd.academic_year
  AND co.exitdate >= rd.[date]
  LEFT JOIN gabby.reporting.reporting_terms AS dt ON co.schoolid = dt.schoolid
  AND dt.identifier = 'RT'
  AND rd.[date] (BETWEEN dt.[start_date] AND dt.end_date)
WHERE
  co.rn_year = 1
  AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.grade_level <> 99
