CREATE OR ALTER VIEW
  alumni.ktc_persistence AS
SELECT
  sub.student_number,
  sub.sf_contact_id,
  sub.lastfirst,
  sub.ktc_cohort,
  sub.ktc_status,
  sub.kipp_region_name,
  sub.current_kipp_student,
  sub.post_hs_simple_admin,
  sub.college_match_display_gpa,
  sub.current_college_cumulative_gpa,
  sub.current_college_semester_gpa,
  sub.highest_act_score,
  sub.academic_year,
  sub.middle_school_attended,
  e.id AS enrollment_id,
  e.pursuing_degree_type_c AS pursuing_degree_type,
  e.status_c AS enrollment_status,
  e.start_date_c AS [start_date],
  e.actual_end_date_c AS actual_end_date,
  a.[name] AS account_name,
  a.[type] AS account_type,
  CASE
    WHEN (
      DATEFROMPARTS(sub.academic_year, 10, 31) > CAST(CURRENT_TIMESTAMP AS DATE)
    ) THEN NULL
    WHEN e.actual_end_date_c >= DATEFROMPARTS(sub.academic_year, 10, 31) THEN 1
    WHEN e.actual_end_date_c < DATEFROMPARTS(sub.academic_year, 10, 31)
    AND e.status_c = 'Graduated' THEN 1
    WHEN e.actual_end_date_c IS NULL
    AND ei.ugrad_status IN ('Graduated', 'Attending') THEN 1
    ELSE 0
  END AS is_persisting
FROM
  (
    SELECT
      r.student_number,
      r.sf_contact_id,
      r.lastfirst,
      r.ktc_cohort,
      r.kipp_region_name,
      r.current_kipp_student,
      r.post_hs_simple_admin,
      r.college_match_display_gpa,
      r.current_college_cumulative_gpa,
      r.current_college_semester_gpa,
      r.highest_act_score,
      r.ktc_status,
      r.middle_school_attended,
      r.ktc_cohort + n.n AS academic_year
    FROM
      gabby.alumni.ktc_roster AS r
      INNER JOIN gabby.utilities.row_generator AS n ON (n.n <= 5)
  ) AS sub
  LEFT JOIN gabby.alumni.enrollment_c AS e ON (
    sub.sf_contact_id = e.student_c
    AND (
      DATEFROMPARTS(sub.academic_year, 10, 31) BETWEEN e.start_date_c AND COALESCE(
        e.actual_end_date_c,
        DATEFROMPARTS(
          (
            gabby.utilities.GLOBAL_ACADEMIC_YEAR () + 1
          ),
          6,
          30
        )
      )
    )
    AND e.is_deleted = 0
    AND e.pursuing_degree_type_c IN (
      'Bachelor''s (4-year)',
      'Associate''s (2 year)'
    )
    AND e.status_c NOT IN ('Did Not Enroll', 'Deferred')
  )
  LEFT JOIN gabby.alumni.account AS a ON (e.school_c = a.id)
  LEFT JOIN gabby.alumni.enrollment_identifiers AS ei ON (sub.sf_contact_id = ei.student_c)
