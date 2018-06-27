CREATE OR ALTER VIEW powerschool.gradebook_assignments AS

SELECT asec.assignmentsectionid
      ,asec.sectionsdcid
      ,asec.assignmentid
      ,asec.duedate AS assign_date
      ,asec.name AS assign_name        
      ,asec.totalpointvalue AS pointspossible
      ,asec.weight
      ,asec.extracreditpoints
      ,asec.iscountedinfinalgrade AS isfinalscorecalculated        

      ,COALESCE(tc.districtteachercategoryid, tc.teachercategoryid) AS categoryid

      ,COALESCE(dtc.name, tc.name) AS category_name
FROM gabby.powerschool.assignmentsection asec
LEFT JOIN gabby.powerschool.assignmentcategoryassoc aca
  ON asec.assignmentsectionid = aca.assignmentsectionid      
LEFT JOIN gabby.powerschool.teachercategory tc
  ON aca.teachercategoryid = tc.teachercategoryid
LEFT JOIN gabby.powerschool.districtteachercategory dtc
  ON tc.districtteachercategoryid = dtc.districtteachercategoryid