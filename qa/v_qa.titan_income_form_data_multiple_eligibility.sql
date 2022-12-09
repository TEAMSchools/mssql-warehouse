USE gabby GO
CREATE OR ALTER VIEW
  qa.titan_income_form_data_multiple_eligibility AS
SELECT
  ti.student_identifier,
  ti.date_signed,
  gabby.dbo.GROUP_CONCAT (ti.reference_code) AS reference_codes,
  COUNT(DISTINCT ti.eligibility_result) AS N,
  ROW_NUMBER() OVER (
    PARTITION BY
      ti.student_identifier
    ORDER BY
      ti.date_signed DESC
  ) AS rn,
  s.lastfirst,
  s.schoolid,
  s.grade_level,
  s.enroll_status
FROM
  gabby.titan.income_form_data_clean ti
  JOIN gabby.powerschool.students s ON ti.student_identifier = s.student_number
  AND ti.[db_name] = s.[db_name]
GROUP BY
  ti.student_identifier,
  ti.date_signed,
  s.lastfirst,
  s.schoolid,
  s.grade_level,
  s.enroll_status
HAVING
  COUNT(DISTINCT ti.eligibility_result) > 1
