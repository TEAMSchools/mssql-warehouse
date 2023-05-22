SELECT
  kt.sf_contact_id,
  kt.lastfirst,
  kt.last_name,
  kt.first_name,
  kt.ktc_cohort,
  kt.college_match_display_gpa,
  kt.highest_act_score,
  ei.ugrad_account_name,
  kt.current_college_cumulative_gpa,
  ac.type,
  ac.competitiveness_ranking_c,
  ac.x_6_yr_minority_completion_rate_c,
  ac.kipp_graduation_and_persistence_rate_c,
  kt.advising_provider,
  kt.kipp_region_name,
  kt.high_school_graduated_from,
  kt.ktc_status,
  CASE
    WHEN kt.advising_provider = 'KNYC' THEN 'KNYC'
    ELSE ct2.full_name_c
  END AS postsec_advisor,
  gpa.cumulative_credits_earned_c
FROM
  gabby.alumni.ktc_roster AS kt
  LEFT JOIN gabby.alumni.enrollment_identifiers AS ei ON ei.student_c = kt.sf_contact_id
  LEFT JOIN gabby.alumni.account AS ac ON ac.ncesid_c = ei.ugrad_ncesid
  LEFT JOIN gabby.alumni.contact AS ct ON ct.salesforce_id_c = kt.sf_contact_id
  LEFT JOIN gabby.alumni.contact AS ct2 ON ct.postsec_advisor_c = ct2.id
  LEFT JOIN gabby.alumni.gpa_c AS gpa ON gpa.student_c = kt.sf_contact_id
WHERE
  kt.actual_hs_graduation_date LIKE '2022-06-%'
  AND ei.ugrad_enrollment_id IS NOT NULL
