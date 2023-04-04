CREATE OR ALTER VIEW
  tableau.hs_early_warning AS
WITH
  attendance AS (
    SELECT
      studentid,
      [db_name],
      ROUND(
        AVG(CAST(attendancevalue AS FLOAT)),
        3
      ) AS [ada]
    FROM
      powerschool.ps_adaadm_daily_ctod_current_static
    WHERE
      membershipvalue = 1
      AND calendardate <= CURRENT_TIMESTAMP
    GROUP BY
      studentid,
      [db_name]
  ),
  suspension AS (
    SELECT
      ics.student_school_id,
      ics.create_academic_year,
      ics.[db_name],
      COUNT(ips.incidentpenaltyid) AS suspension_count,
      SUM(ips.numdays) AS suspension_days
    FROM
      deanslist.stg_incidents AS ics
      INNER JOIN deanslist.incidents_penalties_static AS ips ON (
        ips.incident_id = ics.incident_id
        AND ips.[db_name] = ics.[db_name]
      )
    WHERE
      ips.issuspension = 1
    GROUP BY
      ics.student_school_id,
      ics.create_academic_year,
      ics.[db_name]
  )
SELECT
  co.studentid,
  co.student_number,
  co.lastfirst,
  co.dob,
  co.academic_year,
  co.region,
  co.school_level,
  co.schoolid,
  co.reporting_schoolid,
  co.school_name,
  co.grade_level,
  co.cohort,
  co.team,
  co.advisor_name,
  co.iep_status,
  co.lep_status,
  co.c_504_status,
  co.gender,
  co.ethnicity,
  co.enroll_status,
  co.boy_status,
  co.is_retained_year,
  co.is_retained_ever,
  co.year_in_network,
  co.[db_name],
  dt.alt_name AS term_name,
  dt.time_per_name AS reporting_term,
  dt.[start_date] AS term_start_date,
  dt.[end_date] AS term_end_date,
  gr.course_number,
  gr.potential_credit_hours AS credit_hours,
  gr.term_grade_percent_adj AS term_grade_percent_adjusted,
  gr.term_grade_letter_adj AS term_grade_letter_adjusted,
  gr.y1_grade_percent_adj AS y1_grade_percent_adjusted,
  gr.y1_grade_letter,
  gr.need_60 AS need_65,
  CASE
    WHEN (
      -- trunk-ignore(sqlfluff/LT05)
      CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN gr.termbin_start_date AND gr.termbin_end_date
    ) THEN 1
    ELSE 0
  END AS is_curterm,
  si.credittype,
  si.course_name,
  si.teacher_lastfirst AS teacher_name,
  gpa.gpa_y1,
  gpa.gpa_y1_unweighted,
  gpa.gpa_term,
  gpc.cumulative_y1_gpa,
  gpc.cumulative_y1_gpa_projected,
  gpc.earned_credits_cum,
  gpc.earned_credits_cum_projected,
  gpc.potential_credits_cum,
  att.ada,
  sus.suspension_count,
  sus.suspension_days
FROM
  powerschool.cohort_identifiers_static AS co
  INNER JOIN reporting.reporting_terms AS dt ON (
    co.academic_year = dt.academic_year
    AND co.schoolid = dt.schoolid
    AND dt.identifier = 'RT'
    AND dt._fivetran_deleted = 0
    AND dt.alt_name NOT IN ('Summer School', 'Y1')
  )
  LEFT JOIN powerschool.final_grades_static AS gr ON (
    co.studentid = gr.studentid
    AND co.yearid = gr.yearid
    AND co.[db_name] = gr.[db_name]
    AND dt.alt_name = gr.storecode
    AND gr.exclude_from_gpa = 0
  )
  LEFT JOIN powerschool.sections_identifiers AS si ON (
    gr.sectionid = si.sectionid
    AND gr.[db_name] = si.[db_name]
  )
  LEFT JOIN powerschool.gpa_detail AS gpa ON (
    co.student_number = gpa.student_number
    AND co.academic_year = gpa.academic_year
    AND co.[db_name] = gpa.[db_name]
    AND dt.time_per_name = gpa.reporting_term
  )
  LEFT JOIN powerschool.gpa_cumulative AS gpc ON (
    co.studentid = gpc.studentid
    AND co.schoolid = gpc.schoolid
    AND co.[db_name] = gpc.[db_name]
  )
  LEFT JOIN attendance AS att ON (
    co.studentid = att.studentid
    AND co.[db_name] = att.[db_name]
  )
  LEFT JOIN suspension AS sus ON (
    co.student_number = sus.student_school_id
    AND co.academic_year = sus.create_academic_year
    AND co.[db_name] = sus.[db_name]
  )
WHERE
  co.academic_year = utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.rn_year = 1
  AND co.is_enrolled_recent = 1
  AND co.grade_level >= 9
