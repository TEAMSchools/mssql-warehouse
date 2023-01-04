CREATE OR ALTER VIEW
  powerschool.gpa_cumulative AS
WITH
  grades_union AS (
    SELECT
      sg.studentid,
      sg.schoolid,
      sg.course_number,
      CAST(LEFT(sg.termid, 2) AS INT) + 1990 AS academic_year,
      CASE
        WHEN sg.excludefromgpa = 0 THEN sg.potentialcrhrs
      END AS potentialcrhrs,
      CASE
        WHEN sg.excludefromgraduation = 0 THEN sg.earnedcrhrs
      END AS earnedcrhrs,
      CASE
        WHEN sg.excludefromgpa = 0 THEN sg.gpa_points
      END AS gpa_points,
      CASE
        WHEN sg.excludefromgpa = 0 THEN sg.potentialcrhrs
      END AS potentialcrhrs_projected,
      CASE
        WHEN sg.excludefromgraduation = 0 THEN sg.earnedcrhrs
      END AS earnedcrhrs_projected,
      CASE
        WHEN sg.excludefromgpa = 0 THEN sg.gpa_points
      END AS gpa_points_projected,
      CASE
        WHEN sg.excludefromgpa = 0 THEN sg.potentialcrhrs
      END AS potentialcrhrs_projected_s1,
      CASE
        WHEN sg.excludefromgraduation = 0 THEN sg.earnedcrhrs
      END AS earnedcrhrs_projected_s1,
      CASE
        WHEN sg.excludefromgpa = 0 THEN sg.gpa_points
      END AS gpa_points_projected_s1,
      CASE
        WHEN (
          sg.excludefromgpa = 0
          AND sg.credit_type IN ('MATH', 'SCI', 'ENG', 'SOC')
        ) THEN sg.potentialcrhrs
      END AS potentialcrhrs_core,
      CASE
        WHEN (
          sg.excludefromgpa = 0
          AND sg.credit_type IN ('MATH', 'SCI', 'ENG', 'SOC')
        ) THEN sg.gpa_points
      END AS gpa_points_core,
      CASE
        WHEN sg.excludefromgpa = 0 THEN su.grade_points
      END AS unweighted_grade_points
    FROM
      powerschool.storedgrades AS sg
      LEFT JOIN powerschool.gradescaleitem_lookup_static AS su ON (
        (
          sg.[percent] BETWEEN su.min_cutoffpercentage AND su.max_cutoffpercentage
        )
        AND gabby.utilities.PS_UNWEIGHTED_GRADESCALE_NAME (
          (
            CAST(LEFT(sg.termid, 2) AS INT) + 1990
          ),
          sg.gradescale_name
        ) = su.gradescale_name
      )
    WHERE
      sg.storecode = 'Y1'
    UNION ALL
    SELECT
      fg.studentid,
      co.schoolid,
      fg.course_number,
      rt.academic_year,
      NULL AS potentialcrhrs,
      NULL AS earnedcrhrs,
      NULL AS gpa_points,
      CASE
        WHEN fg.y1_grade_letter IS NULL THEN NULL
        ELSE fg.potential_credit_hours
      END AS potentialcrhrs_projected,
      CASE
        WHEN fg.y1_grade_letter NOT LIKE 'F%' THEN fg.potential_credit_hours
        ELSE 0.0
      END AS earnedcrhrs_projected,
      fg.y1_grade_pts AS gpa_points_projected,
      NULL AS potentialcrhrs_projected_s1,
      NULL AS earnedcrhrs_projected_s1,
      NULL AS gpa_points_projected_s1,
      NULL AS potentialcrhrs_core,
      NULL AS gpa_points_core,
      NULL AS unweighted_grade_points
    FROM
      powerschool.final_grades_static AS fg
      INNER JOIN powerschool.cohort_static AS co ON (
        fg.studentid = co.studentid
        AND fg.yearid = co.yearid
        AND co.rn_year = 1
      )
      INNER JOIN gabby.reporting.reporting_terms AS rt ON (
        fg.yearid = rt.yearid
        AND (
          fg.storecode = rt.alt_name
          COLLATE LATIN1_GENERAL_BIN
        )
        AND co.schoolid = rt.schoolid
        AND rt.identifier = 'RT'
        AND rt.is_curterm = 1
      )
      LEFT JOIN powerschool.storedgrades AS sg ON (
        fg.studentid = sg.studentid
        AND fg.course_number = sg.course_number
        AND rt.academic_year = (
          CAST(LEFT(sg.termid, 2) AS INT) + 1990
        )
        AND sg.storecode = 'Y1'
      )
    WHERE
      fg.yearid = (
        gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1990
      )
      AND fg.exclude_from_gpa = 0
      /* ensures already stored grades are excluded */
      AND sg.studentid IS NULL
    UNION ALL
    SELECT
      fg.studentid,
      co.schoolid,
      fg.course_number,
      co.academic_year,
      NULL AS potentialcrhrs,
      NULL AS earnedcrhrs,
      NULL AS gpa_points,
      NULL AS potentialcrhrs_projected,
      NULL AS earnedcrhrs_projected,
      NULL AS gpa_points_projected,
      fg.potential_credit_hours AS potentialcrhrs_projected_s1,
      CASE
        WHEN fg.y1_grade_letter NOT LIKE 'F%' THEN fg.potential_credit_hours
        ELSE 0
      END AS earnedcrhrs_projected_s1,
      fg.y1_grade_pts AS gpa_points_projected_s1,
      NULL AS potentialcrhrs_core,
      NULL AS gpa_points_core,
      NULL AS unweighted_grade_points
    FROM
      powerschool.final_grades_static AS fg
      INNER JOIN powerschool.cohort_static AS co ON (
        fg.studentid = co.studentid
        AND fg.yearid = co.yearid
        AND co.rn_year = 1
      )
      LEFT JOIN powerschool.storedgrades AS sg ON (
        fg.studentid = sg.studentid
        AND fg.course_number = sg.course_number
        AND (
          CAST(LEFT(sg.termid, 2) AS INT) + 1990
        ) = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
        AND sg.storecode = 'Y1'
      )
    WHERE
      fg.yearid = (
        gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 1990
      )
      /* Y1 AS of Q2 (aka Semester 1) */
      AND fg.storecode = 'Q2'
      AND fg.exclude_from_gpa = 0
      /* ensures already stored grades are excluded */
      AND sg.studentid IS NULL
  ),
  weighted_pts AS (
    SELECT
      studentid,
      academic_year,
      schoolid,
      CAST(potentialcrhrs AS DECIMAL(5, 2)) AS potentialcrhrs,
      CAST(earnedcrhrs AS DECIMAL(5, 2)) AS earnedcrhrs,
      CAST(
        potentialcrhrs_projected AS DECIMAL(5, 2)
      ) AS potentialcrhrs_projected,
      CAST(
        potentialcrhrs_projected_s1 AS DECIMAL(5, 2)
      ) AS potentialcrhrs_projected_s1,
      CAST(
        potentialcrhrs_core AS DECIMAL(5, 2)
      ) AS potentialcrhrs_core,
      CAST(
        earnedcrhrs_projected AS DECIMAL(5, 2)
      ) AS earnedcrhrs_projected,
      CAST(
        earnedcrhrs_projected_s1 AS DECIMAL(5, 2)
      ) AS earnedcrhrs_projected_s1,
      (
        CAST(potentialcrhrs AS DECIMAL(5, 2)) * CAST(gpa_points AS DECIMAL(3, 2))
      ) AS weighted_points,
      CAST(potentialcrhrs AS DECIMAL(5, 2)) * CAST(
        unweighted_grade_points AS DECIMAL(3, 2)
      ) AS unweighted_points,
      CAST(
        potentialcrhrs_core AS DECIMAL(5, 2)
      ) * CAST(gpa_points_core AS DECIMAL(3, 2)) AS weighted_points_core,
      CAST(
        potentialcrhrs_projected AS DECIMAL(5, 2)
      ) * CAST(
        gpa_points_projected AS DECIMAL(3, 2)
      ) AS weighted_points_projected,
      CAST(
        potentialcrhrs_projected_s1 AS DECIMAL(5, 2)
      ) * CAST(
        gpa_points_projected_s1 AS DECIMAL(3, 2)
      ) AS weighted_points_projected_s1
    FROM
      grades_union
  ),
  pts_rollup AS (
    SELECT
      studentid,
      schoolid,
      SUM(weighted_points) AS weighted_points,
      SUM(weighted_points_core) AS weighted_points_core,
      SUM(weighted_points_projected) AS weighted_points_projected,
      SUM(weighted_points_projected_s1) AS weighted_points_projected_s1,
      SUM(unweighted_points) AS unweighted_points,
      SUM(earnedcrhrs) AS earned_credits_cum,
      SUM(earnedcrhrs_projected) AS earned_credits_cum_projected,
      SUM(earnedcrhrs_projected_s1) AS earned_credits_cum_projected_s1,
      CASE
        WHEN SUM(potentialcrhrs) > 0 THEN SUM(potentialcrhrs)
      END AS potentialcrhrs,
      CASE
        WHEN SUM(potentialcrhrs_core) > 0 THEN SUM(potentialcrhrs_core)
      END AS potentialcrhrs_core,
      CASE
        WHEN SUM(potentialcrhrs_projected) > 0 THEN SUM(potentialcrhrs_projected)
      END AS potentialcrhrs_projected,
      CASE
        WHEN SUM(potentialcrhrs_projected_s1) > 0 THEN SUM(potentialcrhrs_projected_s1)
      END AS potentialcrhrs_projected_s1,
      SUM(
        CASE
          WHEN academic_year < gabby.utilities.GLOBAL_ACADEMIC_YEAR () THEN earnedcrhrs
          ELSE potentialcrhrs
        END
      ) AS potential_credits_cum
    FROM
      weighted_pts
    GROUP BY
      studentid,
      schoolid
  )
SELECT
  studentid,
  schoolid,
  earned_credits_cum,
  potential_credits_cum,
  earned_credits_cum_projected,
  earned_credits_cum_projected_s1,
  CAST(
    ROUND(
      (weighted_points / potentialcrhrs),
      2
    ) AS DECIMAL(3, 2)
  ) AS cumulative_y1_gpa,
  CAST(
    ROUND(
      (
        unweighted_points / potentialcrhrs
      ),
      2
    ) AS DECIMAL(3, 2)
  ) AS cumulative_y1_gpa_unweighted,
  CAST(
    ROUND(
      (
        weighted_points_projected / potentialcrhrs_projected
      ),
      2
    ) AS DECIMAL(3, 2)
  ) AS cumulative_y1_gpa_projected,
  CAST(
    ROUND(
      (
        weighted_points_projected_s1 / potentialcrhrs_projected_s1
      ),
      2
    ) AS DECIMAL(3, 2)
  ) AS cumulative_y1_gpa_projected_s1,
  CAST(
    ROUND(
      (
        weighted_points_core / potentialcrhrs_core
      ),
      2
    ) AS DECIMAL(3, 2)
  ) AS core_cumulative_y1_gpa
FROM
  pts_rollup
