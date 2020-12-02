USE gabby
GO

CREATE OR ALTER VIEW extracts.parentsquare_staff AS

SELECT df.ps_teachernumber AS [staff_id]
      ,df.preferred_first_name AS [first_name]
      ,df.preferred_last_name AS [last_name]
      ,df.userprincipalname AS [login]
      ,df.mail AS [email]
      ,df.mobile_number AS [mobile]
      ,df.primary_job AS [title]
      ,CASE 
        WHEN df.primary_site = 'Room 9 - 60 Park Pl' THEN 1000
        WHEN df.primary_site = 'Room 10 - 121 Market St' THEN 1001
        WHEN df.primary_site = '18th Ave Campus' THEN 1002
        WHEN df.primary_site = 'KIPP Lanning Sq Campus' THEN 1003
        WHEN df.primary_site = 'Norfolk St Campus' THEN 1004
        ELSE df.primary_site_schoolid
       END AS [school_id]
FROM gabby.people.staff_crosswalk_static df
WHERE df.[status] NOT IN ('TERMINATED', 'PRESTART')
  AND df.legal_entity_name <> 'KIPP Miami'
  AND df.primary_site <> 'Room 11 - 1951 NW 7th Ave'
