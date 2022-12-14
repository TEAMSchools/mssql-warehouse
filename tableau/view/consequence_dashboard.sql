USE gabby GO
CREATE OR ALTER VIEW
  tableau.consequence_dashboard AS
SELECT
  co.student_number,
  co.state_studentnumber,
  co.lastfirst,
  co.academic_year,
  co.reporting_schoolid,
  co.schoolid,
  co.school_name,
  co.grade_level,
  co.team,
  co.advisor_name,
  co.iep_status,
  co.c_504_status,
  co.lep_status,
  co.lunchstatus,
  co.is_retained_year,
  co.is_retained_ever,
  co.gender,
  co.ethnicity,
  co.region,
  s.fedethnicity,
  dli.student_id AS dl_student_id,
  dli.incident_id,
  dli.reporting_incident_id,
  dli.[status],
  dli.[location],
  dli.reported_details,
  dli.admin_summary,
  dli.context,
  CONCAT(dli.create_last, ', ', dli.create_first) AS created_staff,
  CONCAT(dli.update_last, ', ', dli.update_first) AS last_update_staff,
  dli.update_ts AS dl_timestamp,
  dli.infraction AS incident_type,
  dli.is_referral,
  dli.category AS referral_category,
  'Referral' AS dl_category,
  CAST(d.alt_name AS VARCHAR(5)) AS term,
  dlp.penaltyname,
  dlp.startdate,
  dlp.enddate,
  dlp.numdays,
  dlp.issuspension,
  cf.[Behavior Category],
  cf.[NJ State Reporting],
  cf.[Others Involved],
  cf.[Parent Contacted?],
  cf.[Perceived Motivation],
  cf.[Restraint Used],
  cf.[SSDS Incident ID]
FROM
  gabby.powerschool.cohort_identifiers_static co
  LEFT JOIN gabby.powerschool.students s ON co.student_number = s.student_number
  LEFT JOIN gabby.deanslist.incidents_clean_static dli ON co.student_number = dli.student_school_id
  AND co.academic_year = dli.create_academic_year
  AND co.[db_name] = dli.[db_name]
  LEFT JOIN gabby.reporting.reporting_terms d ON co.schoolid = d.schoolid
  AND CAST(dli.create_ts AS DATE) BETWEEN d.[start_date] AND d.end_date
  AND d.identifier = 'RT'
  AND d._fivetran_deleted = 0
  LEFT JOIN deanslist.incidents_penalties_static dlp ON dli.incident_id = dlp.incident_id
  AND dli.[db_name] = dlp.[db_name]
  LEFT JOIN gabby.deanslist.incidents_custom_fields_wide cf ON dli.incident_id = cf.incident_id
  AND dli.[db_name] = cf.[db_name]
WHERE
  co.academic_year IN (
    gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
    gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1
  )
  AND co.rn_year = 1
  AND co.grade_level <> 99
