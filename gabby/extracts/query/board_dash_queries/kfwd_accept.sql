SELECT
  sub.ktc_cohort,
  sub.gpa_bands,
  COUNT(sub.sf_contact_id) AS student_count,
  ROUND(
    AVG(
      CAST(sub.is_accepted_ba AS FLOAT)
    ),
    2
  ) pct_enrolled_ba,
  ROUND(
    AVG(
      CAST(sub.is_accepted_aa AS FLOAT)
    ),
    2
  ) pct_enrolled_aa,
  ROUND(
    AVG(
      CAST(sub.is_accepted_cert AS FLOAT)
    ),
    2
  ) pct_enrolled_cte
FROM
  (
    SELECT
      kf.ktc_cohort,
      kf.sf_contact_id,
      kf.college_match_display_gpa,
      CASE
        WHEN kf.college_match_display_gpa >= 3.00 THEN 4
        WHEN kf.college_match_display_gpa >= 2.50 THEN 3
        WHEN kf.college_match_display_gpa >= 2.00 THEN 2
        WHEN kf.college_match_display_gpa < 2.00 THEN 1
      END AS gpa_bands,
      CASE
        WHEN kf.is_accepted_ba IS NULL THEN 0
        ELSE kf.is_accepted_ba
      END AS is_accepted_ba,
      CASE
        WHEN kf.is_accepted_aa IS NULL THEN 0
        ELSE kf.is_accepted_aa
      END AS is_accepted_aa,
      CASE
        WHEN kf.is_accepted_cert IS NULL THEN 0
        ELSE kf.is_accepted_cert
      END AS is_accepted_cert
    FROM
      gabby.tableau.kippfwd_dashboard AS kf
    WHERE
      kf.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
      AND kf.ktc_cohort IN (2020, 2021, 2022)
      AND kf.current_kipp_student != 'Not Enrolled at a KIPP School'
  ) AS sub
GROUP BY
  sub.ktc_cohort,
  sub.gpa_bands
ORDER BY
  sub.ktc_cohort ASC,
  sub.gpa_bands ASC
