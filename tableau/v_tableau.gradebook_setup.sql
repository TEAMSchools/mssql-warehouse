USE gabby
GO

ALTER VIEW tableau.gradebook_setup AS

SELECT sec.id AS sectionid
      ,(LEFT(sec.termid, 2) + 1990) AS academic_year            
      ,sec.schoolid
      ,sec.section_number
      ,sec.expression AS period
      
      ,t.teachernumber
      ,t.lastfirst AS teacher_name
      
      ,cou.credittype
      ,cou.course_number
      ,cou.course_name
      
      ,gb.reportingterm_name AS finalgradename
      ,LEFT(gb.reportingterm_name, 1) AS finalgrade_category
      ,gb.finalgradesetuptype
      ,gb.gradingformulaweightingtype
      ,gb.category_name AS grade_category
      ,gb.category_abbreviation AS grade_category_abbreviation
      ,CASE WHEN gb.finalgradesetuptype LIKE 'Total%Points' THEN 100 ELSE gb.weighting END AS weighting
      ,CASE WHEN gb.finalgradesetuptype LIKE 'Total%Points' THEN 1 ELSE gb.includeinfinalgrades END AS includeinfinalgrades
      ,gb.defaultscoretype            
      
      ,a.assignmentid
      ,a.assign_date
      ,a.assign_name
      ,a.pointspossible
      ,a.weight
      ,a.extracreditpoints
      ,a.isfinalscorecalculated

      ,ROW_NUMBER() OVER(
         PARTITION BY sec.id, gb.reportingterm_name, gb.assignmentcategoryid
           ORDER BY a.assign_date ASC) AS rn_category
FROM gabby.powerschool.sections sec WITH(NOLOCK)
JOIN gabby.powerschool.teachers t WITH(NOLOCK)
  ON sec.teacher = t.id
JOIN gabby.powerschool.courses cou WITH(NOLOCK)
  ON sec.course_number = cou.course_number
JOIN gabby.powerschool.gradebook_setup gb WITH(NOLOCK)
  ON sec.dcid = gb.sectionsdcid  
 AND gb.startdate <= CONVERT(DATE,GETDATE())
LEFT OUTER JOIN gabby.powerschool.gradebook_assignments a WITH(NOLOCK)
  ON sec.id = a.sectionid
 AND gb.assignmentcategoryid = a.assignmentcategoryid
 AND a.assign_date between gb.startdate and gb.enddate

UNION ALL

SELECT NULL AS sectionid
      ,gabby.utilities.GLOBAL_ACADEMIC_YEAR() AS academic_year            
      ,NULL AS schoolid
      ,NULL AS section_number
      ,NULL AS period
      
      ,NULL AS teachernumber
      ,NULL AS teacher_name
      
      ,NULL AS credittype
      ,NULL AS course_number
      ,NULL AS course_name

      ,NULL AS finalgradename
      ,NULL AS finalgrade_category
      ,NULL AS finalgradesetuptype
      ,NULL AS gradingformulaweightingtype
      ,NULL AS grade_category
      ,NULL AS grade_category_abbreviation
      ,NULL AS weighting
      ,NULL AS includeinfinalgrades                   
      ,NULL AS defaultscoretype            
      
      ,NULL AS assignmentid
      ,NULL AS assign_date
      ,NULL AS assign_name
      ,NULL AS pointspossible
      ,NULL AS weight
      ,NULL AS extracreditpoints
      ,NULL AS isfinalscorecalculated

      ,NULL AS rn_category