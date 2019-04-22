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
      ,enr.db_name
      
      ,gb.reportingterm_name AS finalgradename
      ,LEFT(gb.reportingterm_name,1) AS finalgrade_category
      ,gb.finalgradesetuptype
      ,gb.gradingformulaweightingtype
      ,gb.category_name AS grade_category
      ,gb.category_abbreviation AS grade_category_abbreviation
      ,gb.weighting
      ,gb.includeinfinalgrades  
      
      ,a1.assignmentid
      ,a1.assign_date
      ,a1.assign_name
      ,a1.pointspossible
      ,a1.weight
      ,a1.extracreditpoints
      ,a1.isfinalscorecalculated
      
      ,s1.scorepoints
      ,s1.islate
      ,s1.isexempt
      ,s1.ismissing
FROM gabby.powerschool.course_enrollments_static enr
JOIN gabby.powerschool.gradebook_setup_static gb
  ON enr.sections_dcid = gb.sectionsdcid
 AND enr.db_name = gb.db_name
 AND gb.finalgradesetuptype = 'Total_Points'
LEFT JOIN gabby.powerschool.gradebook_assignments_current_static a1 WITH(NOLOCK)
  ON gb.sectionsdcid = a1.sectionsdcid 
 AND a1.assign_date BETWEEN gb.startdate and gb.enddate 
 AND gb.db_name = a1.db_name 
LEFT JOIN gabby.powerschool.gradebook_assignments_scores_current_static s1 WITH(NOLOCK)
  ON a1.assignmentsectionid = s1.assignmentsectionid
 AND a1.db_name = s1.db_name
 AND enr.students_dcid = s1.studentsdcid
WHERE enr.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()

UNION ALL

SELECT enr.sectionid
      ,enr.academic_year
      ,enr.course_number
      ,enr.course_name
      ,enr.section_number
      ,enr.teacher_name
      ,enr.student_number
      ,enr.schoolid
      ,enr.db_name
      
      ,gb.reportingterm_name AS finalgradename
      ,LEFT(gb.reportingterm_name,1) AS finalgrade_category
      ,gb.finalgradesetuptype
      ,gb.gradingformulaweightingtype
      ,gb.category_name AS grade_category
      ,gb.category_abbreviation AS grade_category_abbreviation
      ,gb.weighting
      ,gb.includeinfinalgrades  
      
      ,a2.assignmentid
      ,a2.assign_date
      ,a2.assign_name
      ,a2.pointspossible
      ,a2.weight
      ,a2.extracreditpoints
      ,a2.isfinalscorecalculated
      
      ,s2.scorepoints
      ,s2.islate
      ,s2.isexempt
      ,s2.ismissing
FROM gabby.powerschool.course_enrollments_static enr
JOIN gabby.powerschool.gradebook_setup_static gb
  ON enr.sections_dcid = gb.sectionsdcid
 AND enr.db_name = gb.db_name
 AND gb.finalgradesetuptype != 'Total_Points'
LEFT JOIN gabby.powerschool.gradebook_assignments_current_static a2 WITH(NOLOCK)
  ON gb.sectionsdcid = a2.sectionsdcid 
 AND gb.assignmentcategoryid = a2.categoryid
 AND a2.assign_date BETWEEN gb.startdate and gb.enddate 
 AND gb.db_name = a2.db_name 
LEFT JOIN gabby.powerschool.gradebook_assignments_scores_current_static s2 WITH(NOLOCK)
  ON a2.assignmentsectionid = s2.assignmentsectionid
 AND a2.db_name = s2.db_name
 AND enr.students_dcid = s2.studentsdcid 
WHERE enr.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()