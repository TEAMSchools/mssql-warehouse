CREATE OR ALTER VIEW
  tableau.attendance_comm_log AS
WITH
  commlog AS (
    SELECT
      c.student_school_id,
      c.reason AS commlog_reason,
      c.response AS commlog_notes,
      c.call_topic AS commlog_topic,
      c.call_date_time AS commlog_datetime,
      c.[db_name],
      CAST(c.call_date_time AS DATE) AS commlog_date,
      CONCAT(u.first_name, ' ', u.last_name) AS commlog_staff_name,
      f.init_notes AS followup_init_notes,
      f.followup_notes AS followup_close_notes,
      f.outstanding,
      CONCAT(f.c_first, ' ', f.c_last) AS followup_staff_name
    FROM
      deanslist.stg_communication AS c
      INNER JOIN deanslist.users AS u ON (
        c.dluser_id = u.dluser_id
        AND c.[db_name] = u.[db_name]
      )
      LEFT JOIN deanslist.followups AS f ON (
        c.followup_id = f.followup_id
        AND c.[db_name] = f.[db_name]
      )
    WHERE
      (
        c.reason LIKE 'Att:%'
        OR c.reason LIKE 'Chronic%'
      )
  ),
  [ada] AS (
    SELECT
      studentid,
      [db_name],
      yearid,
      ROUND(
        AVG(CAST(attendancevalue AS FLOAT)),
        2
      ) AS [ada]
    FROM
      powerschool.ps_adaadm_daily_ctod_current_static
    WHERE
      membershipvalue = 1
      AND calendardate <= CAST(SYSDATETIME() AS DATE)
    GROUP BY
      studentid,
      yearid,
      [db_name]
  )
SELECT
  co.student_number,
  co.lastfirst,
  co.academic_year,
  co.region,
  co.reporting_schoolid,
  co.grade_level,
  co.team,
  co.iep_status,
  co.gender,
  co.is_retained_year,
  co.enroll_status,
  att.att_date,
  att.att_comment,
  ac.att_code,
  rt.alt_name AS term,
  CASE
    WHEN att.schoolid = 73253 THEN co.advisor_name
    ELSE cc.section_number
  END AS homeroom,
  cl.commlog_staff_name,
  cl.commlog_reason,
  cl.commlog_notes,
  cl.commlog_topic,
  cl.followup_staff_name,
  cl.followup_init_notes,
  cl.followup_close_notes,
  [ada].[ada],
  r.read_lvl,
  r.goal_status,
  gpa.gpa_y1,
  gpa.n_failing_y1,
  ROW_NUMBER() OVER (
    PARTITION BY
      att.studentid,
      att.att_date
    ORDER BY
      cl.commlog_datetime DESC
  ) AS rn_date
FROM
  powerschool.attendance_clean_current_static AS att
  INNER JOIN powerschool.cohort_identifiers_static AS co ON (
    att.studentid = co.studentid
    AND (
      att.att_date BETWEEN co.entrydate AND co.exitdate
    )
    AND att.[db_name] = co.[db_name]
  )
  INNER JOIN powerschool.attendance_code AS ac ON (
    att.attendance_codeid = ac.id
    AND att.[db_name] = ac.[db_name]
    AND ac.att_code LIKE 'A%'
  )
  LEFT JOIN reporting.reporting_terms AS rt ON (
    co.schoolid = rt.schoolid
    AND (
      att.att_date BETWEEN rt.[start_date] AND rt.end_date
    )
    AND rt.identifier = 'RT'
  )
  LEFT JOIN powerschool.cc ON (
    att.studentid = cc.studentid
    AND (
      att.att_date BETWEEN cc.dateenrolled AND cc.dateleft
    )
    AND att.[db_name] = cc.[db_name]
    AND cc.course_number = 'HR'
  )
  LEFT JOIN commlog AS cl ON (
    co.student_number = cl.student_school_id
    AND att.att_date = cl.commlog_date
    AND co.[db_name] = cl.[db_name]
  )
  LEFT JOIN [ada] ON (
    co.studentid = [ada].studentid
    AND co.yearid = [ada].yearid
    AND co.[db_name] = [ada].[db_name]
  )
  LEFT JOIN powerschool.gpa_detail AS gpa ON (
    co.student_number = gpa.student_number
    AND co.academic_year = gpa.academic_year
    AND gpa.is_curterm = 1
  )
  LEFT JOIN lit.achieved_by_round_static AS r ON (
    co.student_number = r.student_number
    AND co.academic_year = r.academic_year
    AND r.is_curterm = 1
  )
WHERE
  att.att_mode_code = 'ATT_ModeDaily'
