USE gabby
GO

CREATE OR ALTER VIEW tableau.es_remote_gradebook AS

SELECT co.student_number
      ,co.lastfirst
      ,co.grade_level
      ,co.region
      ,co.schoolid
      ,co.school_name
      ,co.team
      ,co.iep_status
      ,co.c_504_status
      ,co.gender
      ,co.ethnicity

      ,b.roster
      ,r.subject_name
      ,u.lastfirst AS teacher_name
      ,b.behavior_date AS assignment_date
      ,b.assignment AS assignment_name
      ,CAST(b.behavior AS int) AS score
      ,b.notes

      ,co.academic_year
      ,d.alt_name AS term

FROM deanslist.behavior b
LEFT JOIN gabby.powerschool.cohort_identifiers_static co
  ON b.student_school_id = co.student_number
LEFT JOIN gabby.powerschool.users u
  ON u.teachernumber = b.staff_school_id COLLATE Latin1_General_BIN
 AND u.db_name = co.db_name
LEFT JOIN deanslist.rosters_all r
  ON b.roster_id = r.roster_id
LEFT JOIN gabby.reporting.reporting_terms d
  ON d.schoolid = co.schoolid
 AND CONVERT(DATE, b.behavior_date) BETWEEN d.[start_date] AND d.end_date
 AND d.identifier = 'RT'
 AND d._fivetran_deleted = 0
 AND d.academic_year = co.academic_year

WHERE b.behavior_category = 'Remote Learning'
  AND co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
  AND b.is_deleted = 0
  AND co.rn_year = 1
  AND r.subject_name IN ('ELA','Math')