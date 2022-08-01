CREATE OR ALTER VIEW powerschool.gpa_cumulative AS

WITH grades_union AS (
  SELECT sg.studentid
        ,sg.academic_year
        ,sg.schoolid
        ,sg.course_number
        ,sg.potentialcrhrs
        ,sg.earnedcrhrs
        ,sg.gpa_points
        ,sg.potentialcrhrs AS potentialcrhrs_projected
        ,sg.earnedcrhrs AS earnedcrhrs_projected
        ,sg.gpa_points AS gpa_points_projected
        ,sg.potentialcrhrs AS potentialcrhrs_projected_s1
        ,sg.earnedcrhrs AS earnedcrhrs_projected_s1
        ,sg.gpa_points AS gpa_points_projected_s1
        ,CASE WHEN sg.credit_type IN ('MATH','SCI','ENG','SOC') THEN sg.potentialcrhrs END AS potentialcrhrs_core
        ,CASE WHEN sg.credit_type IN ('MATH','SCI','ENG','SOC') THEN sg.gpa_points END AS gpa_points_core

        ,su.grade_points AS unweighted_grade_points
  FROM powerschool.storedgrades sg
  LEFT JOIN powerschool.gradescaleitem_lookup_static su 
    ON sg.[percent] BETWEEN su.min_cutoffpercentage AND su.max_cutoffpercentage
   AND gabby.utilities.PS_UNWEIGHTED_GRADESCALE_NAME(sg.academic_year, sg.gradescale_name) = su.gradescale_name
  WHERE sg.storecode = 'Y1'
    AND sg.excludefromgpa = 0

  UNION ALL

  SELECT fg.studentid
        ,fg.academic_year
        ,fg.schoolid
        ,fg.course_number
        ,NULL AS potentialcrhrs
        ,NULL AS earnedcrhrs
        ,NULL AS gpa_points
        ,CASE WHEN fg.y1_grade_letter IS NULL THEN NULL ELSE fg.credit_hours END AS potentialcrhrs_projected
        ,CASE WHEN fg.y1_grade_letter NOT LIKE 'F%' THEN fg.credit_hours ELSE 0.0 END AS earnedcrhrs_projected
        ,fg.y1_gpa_points AS gpa_points_projected
        ,NULL AS potentialcrhrs_projected_s1
        ,NULL AS earnedcrhrs_projected_s1
        ,NULL AS gpa_points_projected_s1
        ,NULL AS potentialcrhrs_core
        ,NULL AS gpa_points_core
        ,NULL AS unweighted_grade_points
  FROM powerschool.final_grades_static fg
  LEFT JOIN powerschool.storedgrades sg 
     ON fg.studentid = sg.studentid
    AND fg.course_number = sg.course_number
    AND fg.academic_year = sg.academic_year
    AND sg.storecode = 'Y1'
  WHERE fg.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
    AND fg.is_curterm = 1
    AND fg.excludefromgpa = 0
    AND sg.studentid IS NULL /* ensures already stored grades are excluded */

  UNION ALL

  SELECT fg.studentid
        ,fg.academic_year
        ,fg.schoolid
        ,fg.course_number
        ,NULL AS potentialcrhrs
        ,NULL AS earnedcrhrs
        ,NULL AS gpa_points
        ,NULL AS potentialcrhrs_projected
        ,NULL AS earnedcrhrs_projected
        ,NULL AS gpa_points_projected
        ,fg.credit_hours AS potentialcrhrs_projected_s1
        ,CASE WHEN fg.y1_grade_letter NOT LIKE 'F%' THEN fg.credit_hours ELSE 0 END AS earnedcrhrs_projected_s1
        ,fg.y1_gpa_points AS gpa_points_projected_s1
        ,NULL AS potentialcrhrs_core
        ,NULL AS gpa_points_core
        ,NULL AS unweighted_grade_points
  FROM powerschool.final_grades_static fg
  LEFT JOIN powerschool.storedgrades sg 
    ON fg.studentid = sg.studentid
   AND fg.course_number = sg.course_number
   AND fg.academic_year = sg.academic_year
   AND sg.storecode = 'Y1'
  WHERE fg.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
    AND fg.term_name = 'Q2' /* Y1 as of Q2 (aka Semester 1) */
    AND fg.excludefromgpa = 0
    AND sg.studentid IS NULL /* ensures already stored grades are excluded */
 )

,weighted_pts AS (
  SELECT studentid
        ,academic_year
        ,schoolid
        ,potentialcrhrs
        ,earnedcrhrs
        ,potentialcrhrs_projected
        ,earnedcrhrs_projected
        ,potentialcrhrs_projected_s1
        ,earnedcrhrs_projected_s1
        ,potentialcrhrs_core
        ,gpa_points_core
        ,potentialcrhrs * gpa_points AS weighted_points
        ,potentialcrhrs * unweighted_grade_points AS unweighted_points
        ,potentialcrhrs_core * gpa_points_core AS weighted_points_core
        ,potentialcrhrs_projected * gpa_points_projected AS weighted_points_projected
        ,potentialcrhrs_projected_s1 * gpa_points_projected_s1 AS weighted_points_projected_s1
  FROM grades_union
 )

,pts_rollup AS (
  SELECT studentid
        ,schoolid
        ,SUM(weighted_points) AS weighted_points
        ,SUM(earnedcrhrs) AS earned_credits_cum
        ,SUM(unweighted_points) AS unweighted_points
        ,SUM(weighted_points_core) AS weighted_points_core
        ,SUM(gpa_points_core) AS gpa_points_core
        ,SUM(weighted_points_projected) AS weighted_points_projected
        ,SUM(earnedcrhrs_projected) AS earned_credits_cum_projected
        ,SUM(weighted_points_projected_s1) AS weighted_points_projected_s1
        ,SUM(earnedcrhrs_projected_s1) AS earned_credits_cum_projected_s1
        ,CASE WHEN SUM(potentialcrhrs) = 0 THEN NULL ELSE SUM(potentialcrhrs) END AS potentialcrhrs
        ,CASE WHEN SUM(potentialcrhrs_core) = 0 THEN NULL ELSE SUM(potentialcrhrs_core) END AS potentialcrhrs_core
        ,CASE WHEN SUM(potentialcrhrs_projected) = 0 THEN NULL ELSE SUM(potentialcrhrs_projected) END AS potentialcrhrs_projected
        ,CASE WHEN SUM(potentialcrhrs_projected_s1) = 0 THEN NULL ELSE SUM(potentialcrhrs_projected_s1) END AS potentialcrhrs_projected_s1
        ,SUM(CASE WHEN academic_year < gabby.utilities.GLOBAL_ACADEMIC_YEAR() THEN earnedcrhrs ELSE potentialcrhrs END) AS potential_credits_cum
  FROM weighted_pts
  GROUP BY studentid, schoolid
 )

SELECT studentid
      ,schoolid
      ,earned_credits_cum
      ,potential_credits_cum
      ,earned_credits_cum_projected
      ,earned_credits_cum_projected_s1
      ,ROUND(CAST((weighted_points / potentialcrhrs) AS DECIMAL(4,3)), 2) AS cumulative_Y1_gpa
      ,ROUND(CAST((unweighted_points / potentialcrhrs) AS DECIMAL(4,3)), 2) AS cumulative_Y1_gpa_unweighted
      ,ROUND(CAST((weighted_points_projected / potentialcrhrs_projected) AS DECIMAL(4,3)), 2) AS cumulative_Y1_gpa_projected
      ,ROUND(CAST((weighted_points_projected_s1 / potentialcrhrs_projected_s1) AS DECIMAL(4,3)), 2) AS cumulative_Y1_gpa_projected_s1
      ,ROUND(CAST((weighted_points_core / potentialcrhrs_core) AS DECIMAL(4,3)), 2) AS core_cumulative_Y1_gpa
FROM pts_rollup
