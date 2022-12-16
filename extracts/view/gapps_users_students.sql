CREATE OR ALTER VIEW
  extracts.gapps_users_students AS
SELECT
  sub.student_number,
  sub.suspended,
  sub.email,
  sub.group_email,
  sub.region,
  sub.changepassword,
  sub.first_name AS firstname,
  sub.last_name AS lastname,
  sub.student_web_password AS [password],
  '/Students/' + CASE
    WHEN sub.suspended = 'on' THEN 'Disabled'
    WHEN sub.school_name = 'Out of District' THEN 'Disabled'
    ELSE sub.region + '/' + sub.school_name
  END AS org
FROM
  (
    SELECT
      s.student_number,
      s.first_name,
      s.last_name,
      CASE
        WHEN s.grade_level >= 3 THEN 'on'
        ELSE 'off'
      END AS changepassword,
      CASE
        WHEN s.enroll_status = 0 THEN 'off'
        ELSE 'on'
      END AS suspended,
      CASE
        WHEN s.[db_name] = 'kippcamden' THEN 'KCNA'
        WHEN s.[db_name] = 'kippnewark' THEN 'TEAM'
        WHEN s.[db_name] = 'kippmiami' THEN 'Miami'
      END AS region,
      CASE
        WHEN s.[db_name] = 'kippnewark' THEN 'group-students-newark@teamstudents.org'
        WHEN s.[db_name] = 'kippcamden' THEN 'group-students-camden@teamstudents.org'
        WHEN s.[db_name] = 'kippmiami' THEN 'group-students-miami@teamstudents.org'
      END AS group_email,
      saa.student_web_id + '@teamstudents.org' AS email,
      saa.student_web_password,
      CASE
        WHEN sp.specprog_name IS NOT NULL THEN 'Out of District'
        WHEN sch.abbreviation = 'KHS' THEN 'KCNHS'
        WHEN sch.abbreviation = 'Hatch' THEN 'KHM'
        WHEN sch.abbreviation = 'Sumner' THEN 'KSE'
        WHEN sch.abbreviation = 'LSM' THEN 'LSM'
        WHEN sch.abbreviation = 'LSP' THEN 'LSP'
        WHEN sch.abbreviation = 'Courage' THEN 'Courage'
        WHEN sch.abbreviation = 'Liberty' THEN 'Liberty Academy'
        WHEN sch.abbreviation = 'Royalty' THEN 'Royalty Academy'
        WHEN sch.abbreviation = 'Sunrise' THEN 'Sunrise Academy'
        WHEN sch.abbreviation = 'BOLD' THEN 'BOLD'
        WHEN sch.abbreviation = 'Justice' THEN 'KJA'
        WHEN sch.abbreviation = 'Purpose' THEN 'KPA'
        WHEN sch.abbreviation = 'Truth' THEN 'KTA'
        WHEN sch.abbreviation = 'Life' THEN 'Life'
        WHEN sch.abbreviation = 'NCA' THEN 'NCA'
        WHEN sch.abbreviation = 'NCP' THEN 'Newark Community'
        WHEN sch.abbreviation = 'NLH' THEN 'Newark Lab'
        WHEN sch.abbreviation = 'Rise' THEN 'Rise'
        WHEN sch.abbreviation = 'Seek' THEN 'Seek'
        WHEN sch.abbreviation = 'SPARK' THEN 'SPARK'
        WHEN sch.abbreviation = 'TEAM' THEN 'TEAM Academy'
        WHEN sch.abbreviation = 'THRIVE' THEN 'THRIVE'
        WHEN sch.abbreviation = 'KURA' THEN 'Upper Roseville'
      END AS school_name
    FROM
      gabby.powerschool.students AS s
      INNER JOIN gabby.powerschool.student_access_accounts_static AS saa ON s.student_number = saa.student_number
      INNER JOIN gabby.powerschool.schools AS sch ON s.schoolid = sch.school_number
      AND s.[db_name] = sch.[db_name]
      LEFT JOIN gabby.powerschool.spenrollments_gen_static AS sp ON s.id = sp.studentid
      AND (
        s.exitdate BETWEEN sp.enter_date AND sp.exit_date
      )
      AND s.[db_name] = sp.[db_name]
      AND sp.specprog_name = 'Out of District'
  ) AS sub
