--CREATE OR ALTER VIEW gsheets_comp_events

WITH approval_loops AS (
SELECT 
    primary_site
   ,legal_entity_name
   ,[School Leader] AS school_leader
   ,COALESCE([Director School Operations],[Director Campus Operations]) AS dso_dco 
   ,[Managing Director of Operations] AS mdo
   ,[Managing Director of Growth] AS mdg
   FROM
      ( SELECT  primary_site
               ,legal_entity_name
               ,preferred_name
               ,primary_job
         FROM gabby.people.staff_crosswalk_static x
         WHERE status <> 'TERMINATED') AS sub
         PIVOT (
         MAX(preferred_name) FOR primary_job IN (
         [School Leader]
        ,[Director School Operations]
        ,[Director Campus Operations]
        ,[Managing Director of Operations]
        ,[Managing Director of Growth]
        )
         ) AS p
)

SELECT l.primary_site
   ,l.legal_entity_name
   ,l.school_leader
   ,l.dso_dco 
   ,l.mdo
   ,l.mdg 
   
   ,b.preferred_name AS hos_ed
   
   ,c.preferred_name AS ed
   
   ,e.preferred_name AS mdso
   
   ,f.preferred_name AS mdo
   
FROM approval_loops l
--School Leaders
LEFT JOIN gabby.people.staff_crosswalk_static a
ON l.school_leader = a.preferred_name
--School Leader Managers (HsOS)
LEFT JOIN gabby.people.staff_crosswalk_static b
ON a.manager_name = b.preferred_name 
--HOS Managers (Executive Directors)
LEFT JOIN gabby.people.staff_crosswalk_static c
ON b.manager_name = c.preferred_name
--DSO/DCO
LEFT JOIN gabby.people.staff_crosswalk_static d
ON l.dso_dco = d.preferred_name
--DSO/DCO Managers (MDSOs)
LEFT JOIN gabby.people.staff_crosswalk_static e
ON d.manager_name = e.preferred_name
--MDSO Managers (MDOs)
LEFT JOIN gabby.people.staff_crosswalk_static f
ON e.manager_name = f.preferred_name