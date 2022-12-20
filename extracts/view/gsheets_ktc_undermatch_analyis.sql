CREATE OR ALTER VIEW
  extracts.gsheets_ktc_undermatch_analyis AS
WITH
  apps AS (
    SELECT
      a.applicant_c AS contact_id,
      a.application_status_c AS application_status,
      ac.[name] AS school_name,
      ac.[type] AS school_type,
      ac.[description] AS school_description,
      ac.adjusted_6_year_minority_graduation_rate_c,
      rt.[name] AS record_type_name,
      ROW_NUMBER() OVER (
        PARTITION BY
          a.applicant_c
        ORDER BY
          ac.adjusted_6_year_minority_graduation_rate_c DESC
      ) AS rn_grad_rate
    FROM
      gabby.alumni.application_c AS a
      LEFT JOIN gabby.alumni.account AS ac ON (
        a.school_c = ac.id
        AND ac.is_deleted = 0
      )
      INNER JOIN gabby.alumni.record_type AS rt ON (
        ac.record_type_id = rt.id
        AND rt.[name] != 'High School'
      )
    WHERE
      a.is_deleted = 0
      AND a.application_status_c = 'Accepted'
  )
SELECT
  c.sf_contact_id AS salesforce_contact_id,
  CONCAT(c.first_name, ' ', c.last_name) AS student_name,
  c.ktc_cohort AS kipp_hs_class,
  c.kipp_region_name,
  c.currently_enrolled_school,
  c.current_kipp_student,
  c.expected_hs_graduation_date AS expected_hs_graduation,
  c.college_match_display_gpa,
  c.highest_act_score,
  a.school_name,
  a.school_type,
  a.application_status,
  /* trunk-ignore(sqlfluff/L016) */
  a.adjusted_6_year_minority_graduation_rate_c AS adjusted_6_year_minority_graduation_rate,
  a.school_description,
  a.record_type_name
FROM
  gabby.alumni.ktc_roster AS c
  LEFT JOIN apps AS a ON (
    c.sf_contact_id = a.contact_id
    AND a.rn_grad_rate = 1
  )
