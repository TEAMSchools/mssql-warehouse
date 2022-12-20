CREATE OR ALTER VIEW
  tableau.gradebook_setup AS
SELECT
  enr.sectionid,
  enr.academic_year,
  enr.schoolid,
  enr.section_number,
  enr.expression AS [period],
  enr.teachernumber,
  enr.teacher_name,
  enr.credittype,
  enr.course_number,
  enr.course_name,
  gb.term_abbreviation,
  gb.storecode AS finalgradename,
  LEFT(gb.storecode, 1) AS finalgrade_category,
  gb.finalgradesetuptype,
  gb.gradingformulaweightingtype,
  gb.category_name AS grade_category,
  gb.category_abbreviation AS grade_category_abbreviation,
  CASE
    WHEN gb.finalgradesetuptype LIKE 'Total%Points' THEN 100
    ELSE gb.[weight]
  END AS weighting,
  CASE
    WHEN gb.finalgradesetuptype LIKE 'Total%Points' THEN 1
    ELSE gb.includeinfinalgrades
  END AS includeinfinalgrades,
  gb.defaultscoretype,
  a.assignmentid,
  a.assign_date,
  a.assign_name,
  a.pointspossible,
  a.[weight],
  a.extracreditpoints,
  a.isfinalscorecalculated,
  NULL AS rn_category
FROM
  gabby.powerschool.gradebook_setup_static AS gb
  INNER JOIN gabby.powerschool.course_enrollments_current_static AS enr ON gb.sectionsdcid = enr.sections_dcid
  AND gb.[db_name] = enr.[db_name]
  LEFT JOIN gabby.powerschool.gradebook_assignments_current_static AS a ON gb.sectionsdcid = a.sectionsdcid
  AND gb.assignmentcategoryid = a.categoryid
  AND gb.[db_name] = a.[db_name]
  AND (
    a.assign_date BETWEEN gb.term_start_date AND gb.term_end_date
  )
WHERE
  gb.term_start_date >= DATEFROMPARTS(
    gabby.utilities.GLOBAL_ACADEMIC_YEAR (),
    7,
    1
  )
UNION ALL
SELECT
  NULL AS sectionid,
  gabby.utilities.GLOBAL_ACADEMIC_YEAR () AS academic_year,
  NULL AS schoolid,
  NULL AS section_number,
  NULL AS [period],
  NULL AS teachernumber,
  NULL AS teacher_name,
  NULL AS credittype,
  NULL AS course_number,
  NULL AS course_name,
  NULL AS term_abbreviation,
  NULL AS finalgradename,
  NULL AS finalgrade_category,
  NULL AS finalgradesetuptype,
  NULL AS gradingformulaweightingtype,
  NULL AS grade_category,
  NULL AS grade_category_abbreviation,
  NULL AS weighting,
  NULL AS includeinfinalgrades,
  NULL AS defaultscoretype,
  NULL AS assignmentid,
  NULL AS assign_date,
  NULL AS assign_name,
  NULL AS pointspossible,
  NULL AS [weight],
  NULL AS extracreditpoints,
  NULL AS isfinalscorecalculated,
  NULL AS rn_category
