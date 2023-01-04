CREATE OR ALTER VIEW
  tableau.bus_tool AS
SELECT
  s.student_number,
  s.schoolid,
  s.grade_level,
  s.lastfirst,
  s.home_phone,
  DB_NAME() AS [db_name],
  scw.contact_1_name AS mother,
  scw.contact_1_phone_mobile AS mother_cell,
  scw.contact_2_name AS father,
  scw.contact_2_phone_mobile AS father_cell,
  scw.pickup_1_name AS release_1_name,
  scw.pickup_1_phone_primary AS release_1_phone,
  scw.pickup_2_name AS release_2_name,
  scw.pickup_2_phone_primary AS release_2_phone,
  scw.pickup_3_name AS release_3_name,
  scw.pickup_3_phone_primary AS release_3_phone,
  NULL AS release_4_name,
  NULL AS release_4_phone,
  NULL AS release_5_name,
  NULL AS release_5_phone,
  suf.bus_info_am,
  suf.bus_info_pm,
  suf.bus_info_fridays AS bus_info_pm_early,
  suf.bus_notes,
  CAST(suf._modified AS DATETIME2) AS last_modified,
  CASE
    WHEN suf.bus_info_am NOT LIKE '%-%-%' THEN suf.bus_info_am
    ELSE SUBSTRING(
      suf.bus_info_am,
      (
        CHARINDEX('-', suf.bus_info_am) + 2
      ),
      (
        CHARINDEX(
          '-',
          suf.bus_info_am,
          (
            CHARINDEX('-', suf.bus_info_am) + 1
          )
        ) - (
          CHARINDEX('-', suf.bus_info_am) + 2
        )
      ) - 1
    )
  END AS bus_name_am,
  SUBSTRING(
    suf.bus_info_am,
    CHARINDEX(
      '-',
      suf.bus_info_am,
      (
        CHARINDEX('-', suf.bus_info_am) + 1
      )
    ) + 2,
    LEN(suf.bus_info_am)
  ) AS bus_stop_am,
  CASE
    WHEN suf.bus_info_pm NOT LIKE '%-%-%' THEN suf.bus_info_pm
    ELSE SUBSTRING(
      suf.bus_info_pm,
      (
        CHARINDEX('-', suf.bus_info_pm) + 2
      ),
      (
        CHARINDEX(
          '-',
          suf.bus_info_pm,
          (
            CHARINDEX('-', suf.bus_info_pm) + 1
          )
        ) - (
          CHARINDEX('-', suf.bus_info_pm) + 2
        )
      ) - 1
    )
  END AS bus_name_pm,
  SUBSTRING(
    suf.bus_info_pm,
    CHARINDEX(
      '-',
      suf.bus_info_pm,
      (
        CHARINDEX('-', suf.bus_info_pm) + 1
      )
    ) + 2,
    LEN(suf.bus_info_pm)
  ) AS bus_stop_pm,
  CASE
    WHEN suf.bus_info_fridays NOT LIKE '%-%-%' THEN suf.bus_info_fridays
    ELSE SUBSTRING(
      suf.bus_info_fridays,
      (
        CHARINDEX('-', suf.bus_info_fridays) + 2
      ),
      (
        CHARINDEX(
          '-',
          suf.bus_info_fridays,
          (
            CHARINDEX('-', suf.bus_info_fridays) + 1
          )
        ) - (
          CHARINDEX('-', suf.bus_info_fridays) + 2
        )
      ) - 1
    )
  END AS bus_name_pm_early,
  SUBSTRING(
    suf.bus_info_fridays,
    CHARINDEX(
      '-',
      suf.bus_info_fridays,
      (
        CHARINDEX('-', suf.bus_info_fridays) + 1
      )
    ) + 2,
    LEN(suf.bus_info_fridays)
  ) AS bus_stop_pm_early,
  cc.section_number AS hr_section_number,
  [log].studentid AS log_studentid,
  [log].subtype,
  code.att_code,
  SYSDATETIME() AS systimestamp
FROM
  powerschool.students AS s
  LEFT JOIN powerschool.student_contacts_wide_static AS scw ON (
    s.student_number = scw.student_number
  )
  LEFT JOIN powerschool.u_studentsuserfields AS suf ON (s.dcid = suf.studentsdcid)
  LEFT JOIN powerschool.cc ON (
    s.id = cc.studentid
    AND cc.course_number = 'HR'
    AND (
      CASE
        WHEN (
          cc.dateenrolled > CAST(CURRENT_TIMESTAMP AS DATE)
        ) THEN cc.dateenrolled
        ELSE CAST(CURRENT_TIMESTAMP AS DATE)
      END BETWEEN cc.dateenrolled AND cc.dateleft
    )
  )
  LEFT JOIN powerschool.[log] ON (
    s.id = [log].studentid
    AND [log].logtypeid = 1582
    AND [log].discipline_incidentdate = CAST(CURRENT_TIMESTAMP AS DATE)
  )
  LEFT JOIN powerschool.attendance_clean_current_static AS att ON (
    s.id = att.studentid
    AND att.att_mode_code = 'ATT_ModeDaily'
    AND CAST(att.att_date AS DATE) = CAST(CURRENT_TIMESTAMP AS DATE)
  )
  LEFT JOIN powerschool.attendance_code AS code ON (
    att.attendance_codeid = code.id
    AND (
      code.att_code LIKE 'A%'
      OR code.att_code = 'OSS'
    )
  )
WHERE
  s.enroll_status = 0
