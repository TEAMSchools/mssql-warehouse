WITH key_clean AS (
  SELECT subject
        ,CASE        
          WHEN raw_score LIKE '%-%' THEN CONVERT(INT,LEFT(raw_score, CHARINDEX('-',raw_score)-1))
          WHEN ISNUMERIC(raw_score) = 0 THEN NULL
          ELSE CONVERT(INT,raw_score)
         END AS raw_score
        ,score AS scale_score
  FROM KIPP_NJ..AUTOLOAD$GDOCS_ACT_key_cleanup
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

SELECT KIPP_NJ.dbo.fn_Global_Academic_Year() AS academic_year
      ,11 AS grade_level /* UPDATE */
      ,'ACT5' AS administration_round /* UPDATE */
      ,UPPER(LEFT(s.subject,1)) + SUBSTRING(s.subject,2,LEN(s.subject)) AS subject
      ,s.max_raw_score AS raw_score                  
      ,MAX(a.scale_score) OVER(PARTITION BY s.subject ORDER BY s.max_raw_score) AS scale_score
FROM scaffold s
LEFT OUTER JOIN key_clean a
  ON s.subject = a.subject
 AND s.max_raw_score = a.raw_score