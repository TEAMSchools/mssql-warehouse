CREATE OR ALTER VIEW
  tableau.hi_approval_queue AS
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
  CAST(d.alt_name AS VARCHAR(5)) AS term,
  cf.[Final approval],
  CONCAT(u.first_name, ' ', u.last_name) AS [Approver Name],
  cf.[Instructor Source],
  cf.[Instructor Name],
  cf.[Hours per week],
  cf.[Hourly rate],
  cf.[Board Approval Date],
  cf.[HI start date],
  cf.[HI end date]
FROM
  deanslist.incidents_clean_static AS dli
  LEFT JOIN deanslist.incidents_custom_fields_wide AS cf ON dli.incident_id = cf.incident_id -- noqa: L016
  LEFT JOIN deanslist.users AS u ON (
    u.dluser_id = cf.[Approver name]
    AND u.[db_name] = cf.[db_name]
  )
  INNER JOIN powerschool.cohort_identifiers_static AS co ON (
    dli.student_school_id = co.student_number
    AND dli.create_academic_year = co.academic_year
    AND dli.[db_name] = co.[db_name]
    AND co.rn_year = 1
  )
  INNER JOIN reporting.reporting_terms AS d ON (
    co.schoolid = d.schoolid
    AND (
      CAST(dli.create_ts AS DATE) BETWEEN d.[start_date] AND d.end_date
    )
    AND d.identifier = 'RT'
    AND d._fivetran_deleted = 0
  )
WHERE
  dli.create_academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
  AND dli.category LIKE 'Home Instruction Request -%'
