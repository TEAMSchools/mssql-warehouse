WITH sections AS (
  SELECT CONCAT(CASE
                 WHEN s.[db_name] = 'kippnewark' THEN 'nwk'
                 WHEN s.[db_name] = 'kippcamden' THEN 'cmd'
                 WHEN s.[db_name] = 'kippmiami' THEN 'mia'
                END
               ,s.teacher
               ,s.course_number_clean) AS alias
        ,s.section_number AS section
        ,s.schoolid

        ,c.course_number_clean
        ,c.course_name AS [name]

        ,t.lastfirst

        ,CASE
          WHEN scw.legal_entity_name = 'KIPP Miami' THEN LOWER(LEFT(scw.userprincipalname, CHARINDEX('@', scw.userprincipalname))) + 'kippmiami.org'
          ELSE LOWER(LEFT(scw.userprincipalname, CHARINDEX('@', scw.userprincipalname))) + 'apps.teamschools.org' 
         END AS teacher
  FROM gabby.powerschool.sections s
  JOIN gabby.powerschool.courses c
    ON s.course_number_clean = c.course_number_clean
   AND s.[db_name] = c.[db_name] 
   AND c.credittype != 'LOG'
  JOIN gabby.powerschool.teachers_static t
    ON s.teacher = t.id
   AND s.[db_name] = t.[db_name]
  LEFT JOIN gabby.people.staff_crosswalk_static scw
    ON t.teachernumber = scw.ps_teachernumber COLLATE Latin1_General_BIN
  WHERE s.yearid = (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1990)
 )

/* HR by teacher */
SELECT hr.alias
      ,hr.course_number_clean
      ,hr.section
      ,hr.[name]
      ,hr.teacher
      ,hr.lastfirst
      ,hr.schoolid
FROM sections hr
WHERE hr.course_number_clean = 'HR'

UNION ALL

SELECT MIN(s.alias) AS alias
      ,s.course_number_clean
      ,'all' AS section
      ,s.[name]
      ,s.teacher
      ,s.lastfirst
      ,s.schoolid
FROM sections s
WHERE s.course_number_clean != 'HR'
GROUP BY s.course_number_clean
        ,s.[name]
        ,s.teacher
        ,s.lastfirst
        ,s.schoolid