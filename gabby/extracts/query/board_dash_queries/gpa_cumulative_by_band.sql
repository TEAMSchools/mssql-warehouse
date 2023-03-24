WITH
  gpa_unpivot AS (
    SELECT
      [db_name],
      schoolid,
      studentid,
      gpa_type,
      gpa_value
    FROM
      gabby.powerschool.gpa_cumulative UNPIVOT (
        gpa_value FOR gpa_type IN (
          cumulative_y1_gpa,
          cumulative_y1_gpa_unweighted
        )
      ) AS u
  )
SELECT
  co.region,
  co.school_abbreviation,
  'Class of ' + CAST(co.cohort AS VARCHAR) AS cohort,
  co.grade_level,
  co.enroll_status,
  co.iep_status,
  gpa.gpa_type,
  gpa.gpa_value,
  CASE
    WHEN gpa.gpa_value >= 3.50 THEN '3.50+'
    WHEN gpa.gpa_value >= 3.00 THEN '3.00-3.49'
    WHEN gpa.gpa_value >= 2.50 THEN '2.50-2.99'
    WHEN gpa.gpa_value >= 2.00 THEN '2.00-2.49'
    WHEN gpa.gpa_value < 2.00 THEN '<2.00'
  END AS gpa_band
FROM
  gabby.powerschool.cohort_identifiers_static AS co
  INNER JOIN gpa_unpivot AS gpa ON (
    co.studentid = gpa.studentid
    AND co.schoolid = gpa.schoolid
    AND co.[db_name] = gpa.[db_name]
  )
WHERE
  co.rn_undergrad = 1
  AND co.grade_level != 99
  AND co.school_level = 'HS'
