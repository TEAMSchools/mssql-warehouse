CREATE OR ALTER VIEW powerschool.gradebook_assignments AS

SELECT assignmentsectionid
      ,sectionsdcid
      ,assignmentid
      ,assign_date
      ,assign_name        
      ,pointspossible
      ,weight
      ,extracreditpoints
      ,isfinalscorecalculated
      ,categoryid
      ,category_name
FROM powerschool.gradebook_assignments_current_static

UNION ALL

SELECT assignmentsectionid
      ,sectionsdcid
      ,assignmentid
      ,assign_date
      ,assign_name        
      ,pointspossible
      ,weight
      ,extracreditpoints
      ,isfinalscorecalculated
      ,categoryid
      ,category_name
FROM powerschool.gradebook_assignments_archive