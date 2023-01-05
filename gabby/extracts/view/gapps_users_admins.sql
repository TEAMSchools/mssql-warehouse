CREATE OR ALTER VIEW
  extracts.gapps_users_admins AS
SELECT
  df.google_email AS [user],
  df.primary_site_schoolid,
  CASE
    WHEN df.[db_name] = 'kippnewark' THEN 'team'
    WHEN df.[db_name] = 'kippcamden' THEN 'kcna'
    WHEN df.[db_name] = 'kippmiami' THEN 'miami'
  END AS region,
  CASE
  /* TEAM */
    WHEN df.primary_site_schoolid = 133570965 THEN '/Students/TEAM/TEAM Academy'
    WHEN df.primary_site_schoolid = 73252 THEN '/Students/TEAM/Rise'
    WHEN df.primary_site_schoolid = 73253 THEN '/Students/TEAM/NCA'
    WHEN df.primary_site_schoolid = 73254 THEN '/Students/TEAM/SPARK'
    WHEN df.primary_site_schoolid = 73255 THEN '/Students/TEAM/THRIVE'
    WHEN df.primary_site_schoolid = 73256 THEN '/Students/TEAM/Seek'
    WHEN df.primary_site_schoolid = 73257 THEN '/Students/TEAM/Life'
    WHEN df.primary_site_schoolid = 73258 THEN '/Students/TEAM/BOLD'
    WHEN df.primary_site_schoolid = 73259 THEN '/Students/TEAM/Upper Roseville'
    WHEN df.primary_site_schoolid = 732510 THEN '/Students/TEAM/Newark Community'
    WHEN df.primary_site_schoolid = 732511 THEN '/Students/TEAM/Newark Lab'
    WHEN df.primary_site_schoolid = 732512 THEN '/Students/TEAM/KTA'
    WHEN df.primary_site_schoolid = 732513 THEN '/Students/TEAM/KJA'
    WHEN df.primary_site_schoolid = 732514 THEN '/Students/TEAM/KPA'
    /* KCNA */
    WHEN df.primary_site_schoolid = 179901 THEN '/Students/KCNA/LSP'
    WHEN df.primary_site_schoolid = 179902 THEN '/Students/KCNA/LSM'
    WHEN df.primary_site_schoolid = 179903 THEN '/Students/KCNA/KHM'
    WHEN df.primary_site_schoolid = 179904 THEN '/Students/KCNA/KCNHS'
    WHEN df.primary_site_schoolid = 179905 THEN '/Students/KCNA/KSE'
    /* KMS */
    WHEN df.primary_site_schoolid = 30200801 THEN '/Students/Miami/Sunrise Academy'
    WHEN df.primary_site_schoolid = 30200802 THEN '/Students/Miami/Liberty Academy'
    WHEN df.primary_site_schoolid = 30200803 THEN '/Students/Miami/Courage'
    WHEN df.primary_site_schoolid = 30200804 THEN '/Students/Miami/Royalty Academy'
  END AS [OU]
FROM
  people.staff_crosswalk_static AS df
WHERE
  df.userprincipalname IS NOT NULL
  AND df.[status] != 'TERMINATED'
  AND df.primary_site_schoolid != 0
