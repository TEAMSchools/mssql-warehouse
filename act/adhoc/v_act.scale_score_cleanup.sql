WITH key_clean AS (
  SELECT subject
        ,CASE        
          WHEN raw_score LIKE '%-%' THEN CAST(LEFT(raw_score, CHARINDEX('-',raw_score)-1) AS INT)
          WHEN ISNUMERIC(raw_score) = 0 THEN NULL
          ELSE CAST(raw_score AS INT)
         END AS raw_score
        ,scale AS scale_score
  FROM gabby.act.key_cleanup
  UNPIVOT(
    raw_score
    FOR subject IN (english
                   ,mathematics
                   ,reading
                   ,science)
   ) u
 )

,scaffold AS (
  SELECT subject
        ,MAX(raw_score) AS max_raw_score
  FROM key_clean
  GROUP BY subject
  UNION ALL
  SELECT subject
        ,max_raw_score - 1 
  FROM scaffold 
  WHERE max_raw_score > 0
)

SELECT DISTINCT 
       gabby.utilities.GLOBAL_ACADEMIC_YEAR() AS academic_year
      ,'ACT1' AS administration_round /* UPDATE */      
      ,UPPER(LEFT(s.subject,1)) + SUBSTRING(s.subject,2,LEN(s.subject)) AS subject
      ,s.max_raw_score AS raw_score                  
      ,MAX(a.scale_score) OVER(PARTITION BY s.subject ORDER BY s.max_raw_score) AS scale_score
      ,n AS grade_level 
FROM scaffold s
LEFT OUTER JOIN key_clean a
  ON s.subject = a.subject
 AND s.max_raw_score = a.raw_score
JOIN gabby.utilities.row_generator r
  ON r.n BETWEEN 9 AND 11 /* UPDATE */