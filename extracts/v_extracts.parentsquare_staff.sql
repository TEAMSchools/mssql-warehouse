USE gabby
GO

CREATE OR ALTER VIEW extracts.parentsquare_staff AS

SELECT sub.staff_id
      ,sub.first_name
      ,sub.last_name
      ,sub.[login]
      ,sub.email
      ,sub.mobile
      ,sub.title
      ,sub.school_id
FROM
    (
     SELECT df.ps_teachernumber AS [staff_id]
           ,df.preferred_first_name AS [first_name]
           ,df.preferred_last_name AS [last_name]
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

           ,ad.userprincipalname AS [login]
           ,ad.mail AS [email]
     FROM gabby.people.staff_crosswalk_static df
     JOIN gabby.adsi.user_attributes ad
       ON df.df_employee_number = ad.employeenumber
      AND ISNUMERIC(ad.employeenumber) = 1
     WHERE df.[status] NOT IN ('TERMINATED', 'PRESTART')
       AND df.mail NOT LIKE '%kippmiami.org'

     UNION

     SELECT ad.employeeid AS [staff_id]
           ,ad.givenname AS [first_name]
           ,ad.sn AS [last_name]
           ,ad.mobile AS [mobile]
           ,ad.title AS [title]
           ,CASE 
             WHEN ad.physicaldeliveryofficename = 'Room 9 - 60 Park Pl' THEN 1000
             WHEN ad.physicaldeliveryofficename IN ('Room 10 - 121 Market St', 'Room 10 - 740 Chestnut St') THEN 1001
             WHEN ad.physicaldeliveryofficename = '18th Ave Campus' THEN 1002
             WHEN ad.physicaldeliveryofficename = 'KIPP Lanning Sq Campus' THEN 1003
             WHEN ad.physicaldeliveryofficename = 'Norfolk St Campus' THEN 1004
             ELSE scw.ps_school_id
            END AS [school_id]

           ,ad.userprincipalname AS [login]
           ,ad.mail AS [email]
     FROM gabby.adsi.user_attributes ad
     JOIN gabby.people.school_crosswalk scw
       ON ad.physicaldeliveryofficename = scw.site_name
     WHERE ad.is_active = 1
       AND ad.mail NOT LIKE '%kippmiami.org'
       AND ad.employeeid LIKE 'TMP%'
    ) sub
WHERE sub.school_id IS NOT NULL
