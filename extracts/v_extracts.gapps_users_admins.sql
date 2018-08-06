USE gabby
GO

CREATE OR ALTER VIEW extracts.gapps_users_admins AS

SELECT CASE
        WHEN df.primary_site_schoolid = 73252 THEN '/Students/TEAM/Rise'
        WHEN df.primary_site_schoolid = 73253 THEN '/Students/TEAM/NCA'
        WHEN df.primary_site_schoolid = 179903 THEN '/Students/KCNA/WMS'
        WHEN df.primary_site_schoolid = 179901 THEN '/Students/KCNA/LSP'
        WHEN df.primary_site_schoolid = 133570965 THEN '/Students/TEAM/TEAM Academy'
        WHEN df.primary_site_schoolid = 73254 THEN '/Students/TEAM/SPARK'
        WHEN df.primary_site_schoolid = 73256 THEN '/Students/TEAM/Seek'
        WHEN df.primary_site_schoolid = 73258 THEN '/Students/TEAM/BOLD'
        WHEN df.primary_site_schoolid = 73255 THEN '/Students/TEAM/THRIVE'
        WHEN df.primary_site_schoolid = 73257 THEN '/Students/TEAM/Life'
        WHEN df.primary_site_schoolid = 179902 THEN '/Students/KCNA/LSM'
        WHEN df.primary_site_schoolid = 30200801 THEN '/Students/Miami/Sunrise Academy'
       END AS OU
      ,ad.samaccountname + '@apps.teamschools.org' AS [user]
FROM gabby.dayforce.staff_roster df
JOIN gabby.adsi.user_attributes_static ad
  ON CONVERT(VARCHAR(25),df.df_employee_number) = ad.employeenumber
WHERE df.status != 'TERMINATED'
  AND df.primary_site_schoolid != 0