USE gabby
GO

CREATE OR ALTER VIEW utilities.dependent_objects AS

WITH dependentobjects AS (
  SELECT DISTINCT 
         b.object_id AS usedbyobjectid        
        ,SCHEMA_NAME(b.schema_id) AS usedbyschemaname
        ,b.name AS usedbyobjectname
        ,b.type AS usedbyobjecttype
        ,c.object_id AS dependentobjectid
        ,SCHEMA_NAME(c.schema_id) AS dependentschemaname
        ,c.name AS dependentobjectname
        ,c.type AS dependentobjecttype        
  FROM  sys.sysdepends a
  INNER JOIN sys.objects b 
     ON a.id = b.object_id
  INNER JOIN sys.objects c 
     ON a.depid = c.object_id
    AND c.type IN ('U', 'P', 'V', 'FN')
  WHERE b.type IN ('P','V', 'FN')
 )
 
,dependentobjects2 AS (
   SELECT usedbyschemaname
         ,usedbyobjectid         
         ,usedbyobjectname
         ,usedbyobjecttype
         ,dependentobjectid
         ,dependentobjectname
         ,dependentobjecttype 
         ,1 AS Level
   FROM dependentobjects a   

   UNION ALL 

   SELECT b.usedbyschemaname
         ,b.usedbyobjectid
         ,b.usedbyobjectname
         ,b.usedbyobjecttype
         ,a.dependentobjectid
         ,a.dependentobjectname
         ,a.dependentobjecttype
         ,(b.Level + 1) AS Level
   FROM dependentobjects a
   INNER JOIN dependentobjects2 b 
      ON a.usedbyobjectid = b.dependentobjectid
)

SELECT DISTINCT 
       dependentobjectname AS table_name  
      ,usedbyobjectname
      ,usedbyschemaname
FROM dependentobjects2
WHERE dependentobjecttype = 'U'
  AND dependentobjectname NOT LIKE '%_static'
  AND dependentobjectname NOT LIKE '%_archive'