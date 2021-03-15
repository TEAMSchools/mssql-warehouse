CREATE OR ALTER VIEW powerschool.gradescaleitem_lookup AS

SELECT CONVERT(INT, parent.id) AS gradescaleid
      ,CONVERT(VARCHAR(125), parent.[name]) AS gradescale_name

      ,CONVERT(VARCHAR(125), items.[name]) AS letter_grade
      ,items.grade_points
      ,items.cutoffpercentage AS min_cutoffpercentage
      ,LEAD(items.cutoffpercentage, 1, 1000) OVER(
         PARTITION BY parent.id 
           ORDER BY items.cutoffpercentage) - 1 AS max_cutoffpercentage
FROM powerschool.gradescaleitem parent
JOIN powerschool.gradescaleitem items
  ON parent.id = items.gradescaleid
WHERE parent.gradescaleid = -1
