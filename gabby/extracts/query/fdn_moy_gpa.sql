SELECT
  co.student_number AS [SIS_Student_ID],
  co.first_name AS [First_Name],
  co.middle_name AS [Middle_Name],
  co.last_name AS [Last_Name],
  co.dob AS [Birthdate],
  co.schoolid AS [SIS_School_ID],
  co.school_name AS [School_Name],
  co.grade_level AS [Grade_Level_Numeric],
  gpa.cumulative_y1_gpa_projected_s1_unweighted AS [Unweighted_Cumulative_GPA],
  gpa.cumulative_y1_gpa_projected_s1 AS [Weighted_Cumulative_GPA]
FROM
  gabby.powerschool.cohort_identifiers_static AS co
  LEFT JOIN gabby.powerschool.gpa_cumulative AS gpa ON (
    co.studentid = gpa.studentid
    AND co.schoolid = gpa.schoolid
  )
WHERE
  co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
  AND co.rn_year = 1
  AND (co.grade_level BETWEEN 9 AND 12)
  AND co.enroll_status = 0
ORDER BY
  co.school_name,
  co.grade_level,
  co.lastfirst
