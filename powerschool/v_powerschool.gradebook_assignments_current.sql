CREATE OR ALTER VIEW powerschool.gradebook_assignments_current AS

SELECT CAST(asec.assignmentsectionid AS INT) AS assignmentsectionid
      ,CAST(asec.sectionsdcid AS INT) AS sectionsdcid
      ,CAST(asec.assignmentid AS INT) AS assignmentid
      ,asec.duedate AS assign_date
      ,CAST(asec.[name] AS VARCHAR(125)) AS assign_name
      ,asec.totalpointvalue AS pointspossible
      ,asec.[weight]
      ,asec.extracreditpoints
      ,CAST(asec.iscountedinfinalgrade AS INT) AS isfinalscorecalculated

      ,CAST(COALESCE(tc.districtteachercategoryid, tc.teachercategoryid) AS INT) AS categoryid

      ,CAST(COALESCE(dtc.[name], tc.[name]) AS VARCHAR(125)) AS category_name
FROM powerschool.assignmentsection asec
LEFT JOIN powerschool.assignmentcategoryassoc aca
  ON asec.assignmentsectionid = aca.assignmentsectionid
LEFT JOIN powerschool.teachercategory tc
  ON aca.teachercategoryid = tc.teachercategoryid
LEFT JOIN powerschool.districtteachercategory dtc
  ON tc.districtteachercategoryid = dtc.districtteachercategoryid
WHERE asec.duedate >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)
