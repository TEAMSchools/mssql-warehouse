USE gabby
GO

CREATE OR ALTER VIEW utilities.dependent_objects AS

WITH dependentobjects AS (
  SELECT DISTINCT
         b.[object_id] AS usedbyobjectid
        ,b.[type] AS usedbyobjecttype
        ,b.[name] AS usedbyobjectname
        ,SCHEMA_NAME(b.[schema_id]) AS usedbyschemaname

        ,c.[object_id] AS dependentobjectid
        ,c.[type] AS dependentobjecttype
        ,c.[name] AS dependentobjectname
        ,SCHEMA_NAME(c.[schema_id]) AS dependentschemaname
  FROM [sys].[sysdepends] a
  INNER JOIN [sys].[objects] b 
     ON a.id = b.[object_id]
  INNER JOIN [sys].[objects] c 
     ON a.depid = c.[object_id]
    AND c.[type] IN ('U', 'P', 'V', 'FN')
  WHERE b.[type] IN ('P','V', 'FN')
 )
 
,dependentobjects2 AS (
   SELECT usedbyobjectid
         ,usedbyobjecttype
         ,usedbyschemaname
         ,usedbyobjectname
         ,dependentobjectid
         ,dependentobjecttype
         ,dependentschemaname
         ,dependentobjectname
         ,1 AS [level]
   FROM dependentobjects a

   UNION ALL

   SELECT b.usedbyobjectid
         ,b.usedbyobjecttype
         ,b.usedbyschemaname
         ,b.usedbyobjectname

         ,a.dependentobjectid
         ,a.dependentobjecttype
         ,a.dependentschemaname
         ,a.dependentobjectname

         ,(b.[level] + 1) AS [level]
   FROM dependentobjects a
   INNER JOIN dependentobjects2 b 
      ON a.usedbyobjectid = b.dependentobjectid
 )

SELECT DISTINCT 
       dependentschemaname AS [schema_name]
      ,dependentobjectname AS table_name
      ,usedbyobjectname
      ,usedbyschemaname
FROM dependentobjects2
WHERE dependentobjecttype = 'U'
  AND dependentobjectname NOT LIKE '%_static'
  AND dependentobjectname NOT LIKE '%_archive'
