USE gabby
GO

CREATE OR ALTER VIEW utilities.row_generator AS

WITH nbrs_4(n) AS (
  SELECT 1 
  UNION 
  SELECT 0
 )

,nbrs_3(n) AS (
  SELECT 1 
  FROM nbrs_4 n1 
  CROSS JOIN nbrs_4 n2
 )

,nbrs_2(n) AS (
  SELECT 1 
  FROM nbrs_3 n1 
  CROSS JOIN nbrs_3 n2
 )

,nbrs_1(n) AS (
  SELECT 1 
  FROM nbrs_2 n1 
  CROSS JOIN nbrs_2 n2
 )

,nbrs_0(n) AS (
  SELECT 1 
  FROM nbrs_1 n1 
  CROSS JOIN nbrs_1 n2
 )

,nbrs(n) AS (
  SELECT 1 
  FROM nbrs_0 n1 
  CROSS JOIN nbrs_0 n2
 )
    
SELECT 0 AS n

UNION

SELECT n
FROM
    (
     SELECT ROW_NUMBER() OVER(ORDER BY n) AS n
     FROM nbrs
    ) d