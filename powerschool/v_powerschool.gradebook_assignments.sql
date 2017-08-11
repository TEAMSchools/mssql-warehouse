USE gabby
GO

ALTER VIEW powerschool.gradebook_assignments AS

SELECT sec.schoolid
      ,sec.id AS sectionid
      ,sec.section_number

      ,asec.assignmentsectionid
      ,asec.sectionsdcid
      ,asec.assignmentid
      ,asec.duedate AS assign_date
      ,asec.name AS assign_name        
      ,asec.totalpointvalue AS pointspossible
      ,asec.weight
      ,asec.extracreditpoints
      ,asec.iscountedinfinalgrade AS isfinalscorecalculated        

      ,COALESCE(tc.districtteachercategoryid, tc.teachercategoryid) AS assignmentcategoryid
      ,COALESCE(dtc.name, tc.name) AS category
FROM gabby.powerschool.assignmentsection asec
JOIN gabby.powerschool.sections sec
  ON asec.sectionsdcid = sec.dcid
LEFT OUTER JOIN gabby.powerschool.assignmentcategoryassoc aca
  ON asec.assignmentsectionid = aca.assignmentsectionid      
LEFT OUTER JOIN gabby.powerschool.teachercategory tc
  ON aca.teachercategoryid = tc.teachercategoryid
LEFT OUTER JOIN gabby.powerschool.districtteachercategory dtc
  ON tc.districtteachercategoryid = dtc.districtteachercategoryid