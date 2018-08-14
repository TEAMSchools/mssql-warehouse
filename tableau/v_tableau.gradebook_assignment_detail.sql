USE gabby
GO

CREATE OR ALTER VIEW tableau.gradebook_assignment_detail AS

SELECT enr.sectionid
      ,enr.academic_year
      ,enr.course_number
      ,enr.course_name
      ,enr.section_number
      ,enr.teacher_name
      ,enr.student_number
      ,enr.schoolid
      
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
      
      ,scores.scorepoints AS score
      ,scores.islate AS turnedinlate
      ,scores.isexempt AS exempt
      ,scores.ismissing
FROM gabby.powerschool.course_enrollments_static enr
JOIN gabby.powerschool.gradebook_setup_static gb
  ON enr.sections_dcid = gb.sectionsdcid
 AND enr.db_name = gb.db_name
LEFT JOIN gabby.powerschool.gradebook_assignments a WITH(NOLOCK)
  ON gb.sectionsdcid = a.sectionsdcid
 AND gb.db_name = a.db_name
 AND a.assign_date BETWEEN gb.startdate and gb.enddate 
 AND ((gb.finalgradesetuptype = 'Total_Points') OR
      (gb.finalgradesetuptype != 'Total_Points' AND gb.assignmentcategoryid = a.categoryid))
LEFT JOIN gabby.powerschool.gradebook_assignments_scores scores WITH(NOLOCK)
  ON a.assignmentsectionid = scores.assignmentsectionid
 AND a.db_name = scores.db_name
 AND enr.students_dcid = scores.studentsdcid 
WHERE enr.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()