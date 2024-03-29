CREATE OR ALTER VIEW
  tableau.attendance_chronic_absenteeism_log AS
WITH
  commlog AS (
    SELECT
      c.student_school_id,
      c.reason AS commlog_reason,
      c.response AS commlog_notes,
      c.call_topic AS commlog_topic,
      c.[db_name],
      CAST(c.call_date_time AS DATE) AS commlog_date,
      CONCAT(u.first_name, ' ', u.last_name) AS commlog_staff_name,
      f.init_notes AS followup_init_notes,
      f.followup_notes AS followup_close_notes,
      f.outstanding AS followup_outstanding,
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
      c.reason LIKE 'Chronic%'
  )
SELECT
  sub.student_number,
  sub.lastfirst,
  sub.grade_level,
  sub.team,
  sub.region,
  sub.reporting_schoolid,
  sub.homeroom,
  sub.n_absences,
  cl.commlog_staff_name,
  cl.commlog_reason,
  cl.commlog_notes,
  cl.commlog_topic,
  cl.followup_staff_name,
  cl.followup_init_notes,
  cl.followup_close_notes,
  cl.followup_outstanding
FROM
  (
    SELECT
      co.student_number,
      co.lastfirst,
      co.grade_level,
      co.team,
      co.region,
      co.reporting_schoolid,
      co.[db_name],
      CASE
        WHEN co.schoolid = 73253 THEN co.advisor_name
        ELSE cc.section_number
      END AS homeroom,
      COUNT(att.id) AS n_absences
    FROM
      powerschool.attendance_clean_current_static AS att
      INNER JOIN powerschool.attendance_code AS ac ON (
        att.attendance_codeid = ac.id
        AND att.[db_name] = ac.[db_name]
        AND ac.att_code IN ('A', 'AD')
      )
      LEFT JOIN powerschool.cc ON (
        att.studentid = cc.studentid
        AND att.[db_name] = cc.[db_name]
        AND (
          CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN cc.dateenrolled AND cc.dateleft
        )
        AND cc.course_number = 'HR'
      )
      INNER JOIN powerschool.cohort_identifiers_static AS co ON (
        att.studentid = co.studentid
        AND att.[db_name] = co.[db_name]
        AND (
          att.att_date BETWEEN co.entrydate AND co.exitdate
        )
        AND co.enroll_status = 0
      )
    WHERE
      att.att_mode_code = 'ATT_ModeDaily'
    GROUP BY
      co.student_number,
      co.lastfirst,
      co.grade_level,
      co.team,
      co.region,
      co.reporting_schoolid,
      co.[db_name],
      CASE
        WHEN co.schoolid = 73253 THEN co.advisor_name
        ELSE cc.section_number
      END
  ) AS sub
  LEFT JOIN commlog AS cl ON (
    sub.student_number = cl.student_school_id
    AND sub.[db_name] = cl.[db_name]
  )
