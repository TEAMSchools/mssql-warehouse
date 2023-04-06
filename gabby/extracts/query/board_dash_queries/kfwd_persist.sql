SELECT
  sub.ktc_cohort,
  sub.ecc_pursuing_degree_type,
  sub.persist_yr1,
  sub.gpa_bands,
  COUNT(sub.sf_contact_id) AS student_count
FROM
  (
    SELECT
      kf.sf_contact_id,
      kf.ktc_cohort,
      CASE
        WHEN kf.college_match_display_gpa >= 3.00 THEN 4
        WHEN kf.college_match_display_gpa >= 2.50 THEN 3
        WHEN kf.college_match_display_gpa >= 2.00 THEN 2
        WHEN kf.college_match_display_gpa < 2.00 THEN 1
      END AS gpa_bands,
      CASE
        WHEN kf.cur_status IN ('Attending', 'Graduated') THEN 'Persisting'
        ELSE 'Not Persisting'
      END AS persist_yr1,
      kf.ecc_pursuing_degree_type
    FROM
      gabby.tableau.kippfwd_dashboard AS kf
    WHERE
      kf.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
      AND kf.is_kipp_hs_graduate = 1
      AND kf.ecc_pursuing_degree_type IS NOT NULL
  ) AS sub
GROUP BY
  sub.ktc_cohort,
  sub.ecc_pursuing_degree_type,
  sub.persist_yr1,
  sub.gpa_bands
