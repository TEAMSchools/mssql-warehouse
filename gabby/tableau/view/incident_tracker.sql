CREATE OR ALTER VIEW
  tableau.incident_tracker AS
SELECT
  co.student_number,
  co.state_studentnumber,
  co.lastfirst,
  co.academic_year,
  co.reporting_schoolid,
  co.grade_level,
  co.team,
  co.advisor_name,
  co.iep_status,
  co.gender,
  co.ethnicity,
  co.region,
  NULL AS dl_rostername,
  dli.student_id AS dl_student_id,
  dli.incident_id AS dl_id,
  dli.[status],
  dli.[location],
  dli.reported_details,
  dli.admin_summary,
  dli.context,
  dli.create_first + ' ' + dli.create_last AS referring_teacher_name,
  dli.update_first + ' ' + dli.update_last AS reviewed_by,
  dli.create_ts AS dl_timestamp,
  dli.infraction,
  ISNULL(dli.category, 'Referral') AS dl_behavior,
  NULL AS dl_numdays,
  'Referral' AS dl_category,
  NULL AS dl_point_value,
  NULL AS roster,
  NULL AS assignment,
  NULL AS notes,
  NULL AS roster_subject_name,
  CAST(d.alt_name AS VARCHAR(5)) AS term,
  cf.[Behavior Category],
  cf.[NJ State Reporting],
  cf.[Others Involved],
  cf.[Parent Contacted?],
  cf.[Perceived Motivation],
  cf.[Restraint Used],
  cf.[SSDS Incident ID]
FROM
  powerschool.cohort_identifiers_static AS co
  INNER JOIN deanslist.incidents_clean_static AS dli ON (
    co.student_number = dli.student_school_id
    AND co.academic_year = dli.create_academic_year
  )
  INNER JOIN reporting.reporting_terms AS d ON (
    co.schoolid = d.schoolid
    AND (
      CAST(dli.create_ts AS DATE) BETWEEN d.[start_date] AND d.end_date
    )
    AND d.identifier = 'RT'
    AND d._fivetran_deleted = 0
  )
  -- trunk-ignore(sqlfluff/LT05)
  LEFT JOIN deanslist.incidents_custom_fields_wide AS cf ON (dli.incident_id = cf.incident_id)
WHERE
  co.academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.rn_year = 1
  AND co.grade_level != 99
UNION ALL
SELECT
  co.student_number,
  co.state_studentnumber,
  co.lastfirst,
  co.academic_year,
  co.reporting_schoolid,
  co.grade_level,
  co.team,
  co.advisor_name,
  co.iep_status,
  co.gender,
  co.ethnicity,
  co.region,
  NULL AS dl_rostername,
  dli.student_id AS dl_student_id,
  dlip.incidentpenaltyid AS dl_id,
  dli.[status],
  dli.[location],
  dli.reported_details,
  dli.admin_summary,
  dli.context,
  dli.create_first + ' ' + dli.create_last AS referring_teacher_name,
  dli.update_first + ' ' + dli.update_last AS reviewed_by,
  ISNULL(dlip.startdate, dli.create_ts) AS dl_timestamp,
  dli.infraction,
  dlip.penaltyname AS dl_behavior,
  dlip.numdays AS dl_numdays,
  'Consequence' AS dl_category,
  NULL AS dl_point_value,
  NULL AS roster,
  NULL AS assignment,
  NULL AS notes,
  NULL AS roster_subject_name,
  CAST(d.alt_name AS VARCHAR(5)) AS term,
  NULL AS [Behavior Category],
  NULL AS [NJ State Reporting],
  NULL AS [Others Involved],
  NULL AS [Parent Contacted?],
  NULL AS [Perceived Motivation],
  NULL AS [Restraint Used],
  NULL AS [SSDS Incident ID]
FROM
  powerschool.cohort_identifiers_static AS co
  INNER JOIN deanslist.incidents_clean_static AS dli ON (
    co.student_number = dli.student_school_id
    AND co.academic_year = dli.create_academic_year
  )
  INNER JOIN deanslist.incidents_penalties_static AS dlip ON (
    dli.incident_id = dlip.incident_id
  )
  INNER JOIN reporting.reporting_terms AS d ON (
    co.schoolid = d.schoolid
    AND (
      ISNULL(
        dlip.startdate,
        CAST(dli.create_ts AS DATE)
      ) BETWEEN d.[start_date] AND d.end_date
    )
    AND d.identifier = 'RT'
    AND d._fivetran_deleted = 0
  )
WHERE
  co.academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.rn_year = 1
  AND co.grade_level != 99
UNION ALL
SELECT
  co.student_number,
  co.state_studentnumber,
  co.lastfirst,
  co.academic_year,
  co.reporting_schoolid,
  co.grade_level,
  co.team,
  co.advisor_name,
  co.iep_status,
  co.gender,
  co.ethnicity,
  co.region,
  NULL AS dl_rostername,
  dlb.dlstudent_id AS dl_student_id,
  CAST(dlb.dlsaid AS INT) AS dl_id,
  NULL AS [status],
  NULL AS [location],
  NULL AS reported_details,
  NULL AS admin_summary,
  NULL AS context,
  CAST(
    dlb.staff_first_name + ' ' + dlb.staff_last_name AS VARCHAR(125)
  ) AS referring_teacher_name,
  NULL AS reviewed_by,
  dlb.behavior_date AS dl_timestamp,
  NULL AS infraction,
  CAST(dlb.behavior AS VARCHAR(250)) AS dl_behavior,
  NULL AS dl_numdays,
  CAST(
    dlb.behavior_category AS VARCHAR(125)
  ) AS dl_category,
  dlb.point_value AS dl_point_value,
  dlb.roster,
  NULL AS assignment,
  dlb.notes,
  r.subject_name AS roster_subject_name,
  CAST(d.alt_name AS VARCHAR(5)) AS term,
  NULL AS [Behavior Category],
  NULL AS [NJ State Reporting],
  NULL AS [Others Involved],
  NULL AS [Parent Contacted?],
  NULL AS [Perceived Motivation],
  NULL AS [Restraint Used],
  NULL AS [SSDS Incident ID]
FROM
  deanslist.behavior AS dlb
  INNER JOIN powerschool.cohort_identifiers_static AS co ON (
    co.student_number = dlb.student_school_id
    AND (
      dlb.behavior_date BETWEEN co.entrydate AND co.exitdate
    )
    AND dlb.[db_name] = co.[db_name]
    AND co.rn_year = 1
  )
  LEFT JOIN deanslist.rosters AS r ON (
    dlb.roster_id = r.roster_id
    AND dlb.[db_name] = r.[db_name]
  )
  INNER JOIN reporting.reporting_terms AS d ON (
    co.schoolid = d.schoolid
    AND (
      dlb.behavior_date BETWEEN d.[start_date] AND d.end_date
    )
    AND d.identifier = 'RT'
    AND d._fivetran_deleted = 0
  )
WHERE
  dlb.behavior_date >= DATEFROMPARTS(
    utilities.GLOBAL_ACADEMIC_YEAR (),
    7,
    1
  )
  AND dlb.is_deleted = 0
  AND (
    dlb.school_name IN (
      'KIPP NCA',
      'KIPP Newark Lab High School'
    )
  )
