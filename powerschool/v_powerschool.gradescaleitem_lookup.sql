USE gabby
GO

ALTER VIEW powerschool.gradescaleitem_lookup AS

SELECT parent.id AS gradescaleid
      ,parent.name AS gradescale_name      
      
      ,items.name AS letter_grade
      ,items.grade_points
      ,items.cutoffpercentage AS min_cutoffpercentage       
      ,LEAD(items.cutoffpercentage, 1, 1000) OVER(PARTITION BY parent.id ORDER BY items.cutoffpercentage) - 1 AS max_cutoffpercentage 
FROM gabby.powerschool.gradescaleitem parent
JOIN gabby.powerschool.gradescaleitem items
  ON parent.id = items.gradescaleid
WHERE parent.gradescaleid = -1