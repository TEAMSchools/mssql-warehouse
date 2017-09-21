USE gabby
GO

CREATE OR ALTER VIEW utilities.row_generator AS

WITH Nbrs_4(n) AS (
  SELECT 1 
  UNION 
  SELECT 0
 )

,Nbrs_3(n) AS (
  SELECT 1 
  FROM Nbrs_4 n1 
  CROSS JOIN Nbrs_4 n2
 )

,Nbrs_2(n) AS (
  SELECT 1 
  FROM Nbrs_3 n1 
  CROSS JOIN Nbrs_3 n2
 )

,Nbrs_1(n) AS (
  SELECT 1 
  FROM Nbrs_2 n1 
  CROSS JOIN Nbrs_2 n2
 )

,Nbrs_0(n) AS (
  SELECT 1 
  FROM Nbrs_1 n1 
  CROSS JOIN Nbrs_1 n2
 )

,Nbrs(n) AS (
  SELECT 1 
  FROM Nbrs_0 n1 
  CROSS JOIN Nbrs_0 n2
 )
    
SELECT 0 AS n
UNION
SELECT n
FROM
    (
     SELECT ROW_NUMBER() OVER(ORDER BY n)
     FROM Nbrs
    ) D(n)