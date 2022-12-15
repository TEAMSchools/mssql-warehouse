USE gabby GO
CREATE OR ALTER VIEW
  extracts.deanslist_transcript_gpas AS
SELECT
  student_number,
  academic_year,
  CAST(
    ROUND((weighted_points / credit_hours), 2) AS DECIMAL(3, 2)
  ) AS GPA_Y1_weighted,
  CAST(
    ROUND((unweighted_points / credit_hours), 2) AS DECIMAL(3, 2)
  ) AS GPA_Y1_unweighted
FROM
  (
    SELECT
      student_number,
      academic_year,
      SUM(weighted_points) AS weighted_points,
      SUM(unweighted_points) AS unweighted_points,
      CASE
        WHEN SUM(potentialcrhrs) = 0 THEN NULL
        ELSE SUM(potentialcrhrs)
      END AS credit_hours
    FROM
      (
        SELECT
          sg.academic_year,
          CAST(sg.potentialcrhrs AS DECIMAL(5, 2)) AS potentialcrhrs,
          (
            CAST(sg.potentialcrhrs AS DECIMAL(5, 2)) * CAST(sg.gpa_points AS DECIMAL(3, 2))
          ) AS weighted_points,
          s.student_number,
          (
            CAST(sg.potentialcrhrs AS DECIMAL(5, 2)) * CAST(
              scale_unweighted.grade_points AS DECIMAL(3, 2)
            )
          ) AS unweighted_points
        FROM
          gabby.powerschool.storedgrades AS sg
          INNER JOIN gabby.powerschool.students AS s ON sg.studentid = s.id
          AND sg.[db_name] = s.[db_name]
          LEFT OUTER JOIN gabby.powerschool.gradescaleitem_lookup_static AS scale_unweighted ON sg.[db_name] = scale_unweighted.[db_name]
          AND sg.[percent] (
            BETWEEN scale_unweighted.min_cutoffpercentage AND scale_unweighted.max_cutoffpercentage
          )
          AND gabby.utilities.PS_UNWEIGHTED_GRADESCALE_NAME (sg.academic_year, sg.gradescale_name) = scale_unweighted.gradescale_name
        WHERE
          sg.storecode = 'Y1'
          AND sg.excludefromgpa = 0
      ) sub
    GROUP BY
      student_number,
      academic_year
  ) sub
UNION ALL
SELECT
  co.student_number,
  NULL AS academic_year,
  sg.cumulative_y1_gpa AS GPA_Y1_weighted,
  sg.cumulative_y1_gpa_unweighted AS GPA_Y1_unweighted
FROM
  gabby.powerschool.cohort_identifiers_static AS co
  INNER JOIN gabby.powerschool.gpa_cumulative AS sg ON co.studentid = sg.studentid
  AND co.schoolid = sg.schoolid
  AND co.[db_name] = sg.[db_name]
WHERE
  co.rn_undergrad = 1
