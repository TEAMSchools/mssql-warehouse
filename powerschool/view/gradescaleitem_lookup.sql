CREATE OR ALTER VIEW
  powerschool.gradescaleitem_lookup AS
SELECT
  parent.id AS gradescaleid,
  parent.[name] AS gradescale_name,
  items.[name] AS letter_grade,
  items.grade_points,
  items.cutoffpercentage AS min_cutoffpercentage,
  LEAD(items.cutoffpercentage, 1, 1000) OVER (
    PARTITION BY
      parent.id
    ORDER BY
      items.cutoffpercentage
  ) - 0.1 AS max_cutoffpercentage
FROM
  powerschool.gradescaleitem AS parent
  INNER JOIN powerschool.gradescaleitem AS items ON (parent.id = items.gradescaleid)
WHERE
  parent.gradescaleid = -1
