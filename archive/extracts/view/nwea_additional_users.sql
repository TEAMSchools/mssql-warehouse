CREATE OR ALTER VIEW
  extracts.nwea_additional_users AS
SELECT
  CASE
    WHEN sr.primary_site_schoolid = 0 THEN NULL
    ELSE CAST(
      sr.primary_site_schoolid AS VARCHAR(25)
    )
  END AS [School State Code],
  CASE
    WHEN sr.primary_site_schoolid = 0 THEN NULL
    WHEN sr.primary_site = 'KIPP Pathways at Bragaw' THEN 'Life Academy'
    WHEN sr.primary_site = 'KIPP Pathways at 18th Ave' THEN 'BOLD Academy'
    WHEN sr.primary_site IN (
      'KIPP Liberty Academy',
      'KIPP Sunrise Academy'
    ) THEN sr.primary_site
    ELSE REPLACE(
      REPLACE(sr.primary_site, 'KIPP ', ''),
      'Square',
      'Sq'
    )
  END AS [School Name],
  sr.ps_teachernumber AS [Instructor ID],
  sr.df_employee_number AS [Instructor State ID],
  sr.preferred_last_name AS [Last Name],
  sr.preferred_first_name AS [First Name],
  NULL AS [Middle Name],
  sr.userprincipalname AS [User Name],
  sr.userprincipalname AS [Email Address],
  'Y' AS [Role = School Proctor?],
  NULL AS [Role = School Assessment Coordinator?],
  NULL AS [Role = Administrator?],
  CASE
    WHEN sr.primary_job IN (
      'Academic Operations Manager',
      'Associate Director of School Operations',
      'Director Campus Operations',
      'Director of Campus Operations',
      'Director School Operations',
      'Fellow School Operations Director',
      'Managing Director of Operations',
      'Managing Director of School Operations',
      'Managing Director of School Operations in Residence',
      'School Operations Manager'
    ) THEN 'Y'
    ELSE NULL
  END AS [Role = District Proctor?] -- DSOs/ADSOs
,
  NULL AS [Role = Data Administrator?],
  NULL AS [Role = District Assessment Coordinator?],
  NULL AS [Role = Interventionist?],
  NULL AS [Role = SN Administrator?]
FROM
  gabby.people.staff_crosswalk_static AS sr
WHERE
  sr.[status] != 'TERMINATED'
  AND sr.userprincipalname IS NOT NULL
  AND sr.legal_entity_name != 'KIPP New Jersey'
  AND (
    sr.primary_site_schoolid != 0
    OR sr.primary_job IN (
      'Academic Operations Manager',
      'Associate Director of School Operations',
      'Director Campus Operations',
      'Director of Campus Operations',
      'Director School Operations',
      'Fellow School Operations Director',
      'Managing Director of Operations',
      'Managing Director of School Operations',
      'Managing Director of School Operations in Residence',
      'School Operations Manager'
    )
  )
