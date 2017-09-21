USE gabby
GO

CREATE OR ALTER VIEW tableau.gradebook_assignment_detail AS

SELECT sec.id AS sectionid
      ,(LEFT(sec.termid, 2) + 1990) AS academic_year            
      ,sec.course_number
      ,sec.section_number
      ,t.lastfirst AS teacher_name
      
      ,gb.reportingterm_name AS finalgradename
      ,LEFT(gb.reportingterm_name,1) AS finalgrade_category
      ,gb.finalgradesetuptype
      ,gb.gradingformulaweightingtype
      ,gb.category_name AS grade_category
      ,gb.category_abbreviation AS grade_category_abbreviation
      ,gb.weighting
      ,gb.includeinfinalgrades      
      
      ,a.assignmentid
      ,a.assign_date
      ,a.assign_name
      ,a.pointspossible
      ,a.weight
      ,a.extracreditpoints
      ,a.isfinalscorecalculated
      
      ,s.student_number
      ,s.schoolid
      
      ,scores.scorepoints AS score
      ,scores.islate AS turnedinlate
      ,scores.isexempt AS exempt
      ,scores.ismissing
FROM gabby.powerschool.sections sec 
JOIN gabby.powerschool.teachers t 
  ON sec.teacher = t.id
LEFT OUTER JOIN gabby.powerschool.cc cc 
  ON sec.id = cc.sectionid
LEFT OUTER JOIN gabby.powerschool.students s 
  ON cc.studentid = s.id
JOIN gabby.powerschool.gradebook_setup gb 
  ON sec.dcid = gb.sectionsdcid
 AND gb.finalgradesetuptype != 'Total_Points'
LEFT OUTER JOIN gabby.powerschool.gradebook_assignments a 
  ON sec.id = a.sectionid
 AND gb.assignmentcategoryid = a.assignmentcategoryid
 AND a.assign_date between gb.startdate and gb.enddate
LEFT OUTER JOIN gabby.powerschool.gradebook_assignments_scores scores 
  ON a.assignmentsectionid = scores.assignmentsectionid
 AND s.student_number = scores.student_number
WHERE (LEFT(sec.termid, 2) + 1990) = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

UNION ALL

SELECT sec.id AS sectionid
      ,(LEFT(sec.termid, 2) + 1990) AS academic_year            
      ,sec.course_number
      ,sec.section_number
      ,t.lastfirst AS teacher_name
      
      ,gb.reportingterm_name AS finalgradename
      ,LEFT(gb.reportingterm_name,1) AS finalgrade_category
      ,gb.finalgradesetuptype
      ,gb.gradingformulaweightingtype
      ,gb.category_name AS grade_category
      ,gb.category_abbreviation AS grade_category_abbreviation
      ,gb.weighting
      ,gb.includeinfinalgrades  
      
      ,a.assignmentid
      ,a.assign_date
      ,a.assign_name
      ,a.pointspossible
      ,a.weight
      ,a.extracreditpoints
      ,a.isfinalscorecalculated
      
      ,s.student_number
      ,s.schoolid
      
      ,scores.scorepoints AS score
      ,scores.islate AS turnedinlate
      ,scores.isexempt AS exempt
      ,scores.ismissing
FROM gabby.powerschool.sections sec 
JOIN gabby.powerschool.teachers t 
  ON sec.teacher = t.id
LEFT OUTER JOIN gabby.powerschool.cc cc 
  ON sec.id = cc.sectionid
LEFT OUTER JOIN gabby.powerschool.students s 
  ON cc.studentid = s.id
JOIN gabby.powerschool.gradebook_setup gb 
  ON sec.dcid = gb.sectionsdcid
 AND gb.finalgradesetuptype = 'Total_Points'
LEFT OUTER JOIN gabby.powerschool.gradebook_assignments a 
  ON sec.id = a.sectionid 
 AND a.assign_date between gb.startdate and gb.enddate
LEFT OUTER JOIN gabby.powerschool.gradebook_assignments_scores scores 
  ON a.assignmentsectionid = scores.assignmentsectionid
 AND s.student_number = scores.student_number
WHERE (LEFT(sec.termid, 2) + 1990) = gabby.utilities.GLOBAL_ACADEMIC_YEAR()