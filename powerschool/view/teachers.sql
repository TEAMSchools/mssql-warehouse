CREATE OR ALTER VIEW
  powerschool.teachers AS
SELECT
  CAST(
    u.lastfirst AS VARCHAR(125)
  ) AS lastfirst,
  u.first_name,
  u.middle_name,
  u.last_name,
  u.photo,
  u.title,
  u.homeroom,
  u.email_addr,
  u.[password],
  u.numlogins,
  u.allowloginstart,
  u.allowloginend,
  u.psaccess,
  u.homepage,
  u.loginid,
  u.defaultstudscrn,
  u.groupvalue,
  CAST(
    u.teachernumber AS VARCHAR(25)
  ) AS teachernumber,
  u.lunch_id,
  u.ssn,
  u.home_phone,
  u.school_phone,
  u.street,
  u.city,
  u.[state],
  u.zip,
  u.periodsavail,
  u.powergradepw,
  u.canchangeschool,
  u.teacherloginpw,
  u.nameasimported,
  u.teacherloginid,
  u.teacherloginip,
  u.supportcontact,
  u.wm_tier,
  u.wm_createtime,
  u.wm_exclude,
  u.ethnicity,
  u.preferredname,
  u.staffpers_guid,
  u.adminldapenabled,
  u.teacherldapenabled,
  u.sif_stateprid,
  u.maximum_load,
  u.gradebooktype,
  u.fedethnicity,
  u.fedracedecline,
  CAST(u.homeschoolid AS INT) AS homeschoolid,
  u.ptaccess,
  s.dcid,
  CAST(s.id AS INT) AS id,
  CAST(s.schoolid AS INT) AS schoolid,
  s.[status],
  s.noofcurclasses,
  s.[log],
  s.staffstatus,
  s.sched_classroom,
  s.sched_department,
  s.sched_maximumcourses,
  s.sched_maximumduty,
  s.sched_maximumfree,
  s.sched_totalcourses,
  s.sched_maximumconsecutive,
  s.sched_isteacherfree,
  s.sched_teachermoreoneschool,
  s.sched_substitute,
  s.sched_scheduled,
  s.sched_usebuilding,
  s.sched_usehouse,
  s.sched_lunch,
  s.sched_maxpers,
  s.sched_maxpreps,
  s.sched_housecode,
  s.users_dcid
  --,s.classpua
  --,s.custom
  --,s.balance1
  --,s.balance2
  --,s.balance3
  --,s.balance4
  --,s.notes
  --,s.sched_gender
  --,s.sched_homeroom
  --,s.sched_buildingcode
  --,s.sched_activitystatuscode
  --,s.sched_primaryschoolcode
  --,s.sched_team
  --,u.wm_ta_flag
  --,u.wm_ta_date
  --,u.wm_status
  --,u.wm_statusdate
  --,u.wm_address
  --,u.wm_password
  --,u.wm_createdate
  --,u.ipaddrrestrict
  --,u.accessvalue
  --,u.lastmeal
  --,u.wm_alias
FROM
  powerschool.users AS u
  INNER JOIN powerschool.schoolstaff AS s ON u.dcid = s.users_dcid
