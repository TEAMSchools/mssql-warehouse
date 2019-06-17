USE gabby
GO

CREATE OR ALTER VIEW extracts.nwea_additional_users AS

SELECT CASE WHEN sr.primary_site_schoolid = 0 THEN NULL ELSE CONVERT(VARCHAR(25),sr.primary_site_schoolid) END AS [School State Code]
      ,CASE 
        WHEN sr.primary_site_schoolid = 0 THEN NULL 
        WHEN sr.primary_site = 'KIPP BOLD Academy' THEN 'BOLD Academy'
        WHEN sr.primary_site = 'KIPP Lanning Square Middle' THEN 'Lanning Sq Middle'
        WHEN sr.primary_site = 'KIPP Lanning Square Primary' THEN 'Lanning Sq Primary'
        WHEN sr.primary_site = 'KIPP Life Academy' THEN 'Life Academy'
        WHEN sr.primary_site = 'KIPP Newark Collegiate Academy' THEN 'Newark Collegiate Academy'
        WHEN sr.primary_site = 'KIPP Pathways at 18th Ave' THEN 'BOLD Academy'
        WHEN sr.primary_site = 'KIPP Pathways at Bragaw' THEN 'Life Academy'
        WHEN sr.primary_site = 'KIPP Rise Academy' THEN 'Rise Academy'
        WHEN sr.primary_site = 'KIPP Seek Academy' THEN 'Seek Academy'
        WHEN sr.primary_site = 'KIPP SPARK Academy' THEN 'SPARK Academy'
        WHEN sr.primary_site = 'KIPP Sunrise Academy' THEN 'KIPP Sunrise Academy'
        WHEN sr.primary_site = 'KIPP TEAM Academy' THEN 'TEAM Academy'
        WHEN sr.primary_site = 'KIPP THRIVE Academy' THEN 'THRIVE Academy'
        WHEN sr.primary_site = 'KIPP Whittier Middle' THEN 'Whittier Middle'
       END AS [School Name]
      ,sr.ps_teachernumber AS [Instructor ID]
      ,sr.df_employee_number AS [Instructor State ID]
      ,sr.preferred_last_name AS [Last Name]
      ,sr.preferred_first_name AS [First Name]
      ,NULL AS [Middle Name]
      ,sr.userprincipalname AS [User Name]
      ,sr.userprincipalname AS [Email Address]

      ,'Y' AS [Role = School Proctor?]
      ,NULL AS [Role = School Assessment Coordinator?]
      ,NULL AS [Role = Administrator?]
      ,CASE 
        WHEN sr.primary_job IN ('Academic Operations Manager', 'Associate Director of School Operations', 'Director Campus Operations'
                               ,'Director of Campus Operations', 'Director School Operations', 'Fellow School Operations Director', 'Managing Director of Operations'
                               ,'Managing Director of School Operations', 'Managing Director of School Operations in Residence', 'School Operations Manager')
               THEN 'Y'
        ELSE NULL
       END AS [Role = District Proctor?] -- DSOs/ADSOs
      ,NULL AS [Role = Data Administrator?]
      ,NULL AS [Role = District Assessment Coordinator?]
      ,NULL AS [Role = Interventionist?]
      ,NULL AS [Role = SN Administrator?]
FROM gabby.people.staff_crosswalk_static sr
WHERE sr.is_active = 1
  AND sr.legal_entity_name != 'KIPP New Jersey'
  AND (sr.primary_site_schoolid != 0
         OR sr.primary_job IN ('Academic Operations Manager', 'Associate Director of School Operations', 'Director Campus Operations'
                              ,'Director of Campus Operations', 'Director School Operations', 'Fellow School Operations Director', 'Managing Director of Operations'
                              ,'Managing Director of School Operations', 'Managing Director of School Operations in Residence', 'School Operations Manager'))