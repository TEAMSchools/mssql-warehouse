USE gabby GO
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
      gabby.deanslist.communication c
      JOIN gabby.deanslist.users u ON c.dluser_id = u.dluser_id
      AND c.[db_name] = u.[db_name]
      LEFT JOIN gabby.deanslist.followups f ON c.followup_id = f.followup_id
      AND c.[db_name] = f.[db_name]
    WHERE
      (
        c.reason LIKE 'Att:%'
        OR c.reason LIKE 'Chronic%'
      )
  ),
  ADA AS (
    SELECT
      psa.studentid,
      psa.[db_name],
      psa.yearid,
      ROUND(AVG(CAST(psa.attendancevalue AS FLOAT)), 2) AS ADA
    FROM
      gabby.powerschool.ps_adaadm_daily_ctod_current_static psa
    WHERE
      psa.membershipvalue = 1
      AND psa.calendardate <= CAST(SYSDATETIME() AS DATE)
    GROUP BY
      psa.studentid,
      psa.yearid,
      psa.[db_name]
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
  ADA.ada,
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
  gabby.powerschool.attendance_clean_current_static att
  JOIN gabby.powerschool.cohort_identifiers_static co ON att.studentid = co.studentid
  AND att.att_date BETWEEN co.entrydate AND co.exitdate
  AND att.[db_name] = co.[db_name]
  JOIN gabby.powerschool.attendance_code ac ON att.attendance_codeid = ac.id
  AND att.[db_name] = ac.[db_name]
  AND ac.att_code LIKE 'A%'
  LEFT JOIN gabby.reporting.reporting_terms rt ON co.schoolid = rt.schoolid
  AND att.att_date BETWEEN rt.[start_date] AND rt.end_date
  AND rt.identifier = 'RT'
  LEFT JOIN gabby.powerschool.cc ON att.studentid = cc.studentid
  AND att.att_date BETWEEN cc.dateenrolled AND cc.dateleft
  AND att.[db_name] = cc.[db_name]
  AND cc.course_number = 'HR'
  LEFT JOIN commlog cl ON co.student_number = cl.student_school_id
  AND att.att_date = cl.commlog_date
  AND co.[db_name] = cl.[db_name]
  LEFT JOIN ADA ON co.studentid = ADA.studentid
  AND co.yearid = ADA.yearid
  AND co.[db_name] = ADA.[db_name]
  LEFT JOIN gabby.powerschool.gpa_detail gpa ON co.student_number = gpa.student_number
  AND co.academic_year = gpa.academic_year
  AND gpa.is_curterm = 1
  LEFT JOIN gabby.lit.achieved_by_round_static r ON co.student_number = r.student_number
  AND co.academic_year = r.academic_year
  AND r.is_curterm = 1
WHERE
  att.att_mode_code = 'ATT_ModeDaily'
