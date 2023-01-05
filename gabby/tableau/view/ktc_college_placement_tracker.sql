CREATE OR ALTER VIEW
  tableau.ktc_college_placement_tracker AS
WITH
  nav_applications AS (
    SELECT
      hs_student_id,
      SUM(
        CASE
          WHEN result_code = 'accepted' THEN award
          ELSE 0
        END
      ) AS n_award_letters_collected,
      MAX(
        CASE
          WHEN result_code = 'accepted' THEN decis
          ELSE 0
        END
      ) AS is_acceptance_letter_collected
    FROM
      naviance.college_applications
    WHERE
      stage != 'cancelled'
    GROUP BY
      hs_student_id
  ),
  act_month AS (
    SELECT
      student_number,
      academic_year,
      [act_jan],
      [act_feb],
      [act_mar],
      [act_apr],
      [act_may],
      [act_jun],
      [act_jul],
      [act_aug],
      [act_sep],
      [act_oct],
      [act_nov],
      [act_dec],
      [sat_jan],
      [sat_feb],
      [sat_mar],
      [sat_apr],
      [sat_may],
      [sat_jun],
      [sat_jul],
      [sat_aug],
      [sat_sep],
      [sat_oct],
      [sat_nov],
      [sat_dec],
      [sat2_ch],
      [sat2_fl],
      [sat2_lr],
      [sat2_m1],
      [sat2_m2],
      [sat2_sp]
    FROM
      (
        SELECT
          student_number,
          academic_year,
          'act_' + LOWER(
            LEFT(DATENAME(MONTH, test_date), 3)
          ) AS test_month,
          composite
        FROM
          naviance.act_scores_clean
        UNION ALL
        SELECT
          student_number,
          academic_year,
          'sat_' + LOWER(
            LEFT(DATENAME(MONTH, test_date), 3)
          ) AS test_month,
          all_tests_total
        FROM
          naviance.sat_scores_clean
        UNION ALL
        SELECT
          student_number,
          academic_year,
          'sat2_' + LOWER(test_code) AS test_month,
          score
        FROM
          naviance.sat_2_scores_clean
      ) AS sub PIVOT (
        MAX(composite) FOR test_month IN (
          [act_jan],
          [act_feb],
          [act_mar],
          [act_apr],
          [act_may],
          [act_jun],
          [act_jul],
          [act_aug],
          [act_sep],
          [act_oct],
          [act_nov],
          [act_dec],
          [sat_jan],
          [sat_feb],
          [sat_mar],
          [sat_apr],
          [sat_may],
          [sat_jun],
          [sat_jul],
          [sat_aug],
          [sat_sep],
          [sat_oct],
          [sat_nov],
          [sat_dec],
          [sat2_ch],
          [sat2_fl],
          [sat2_lr],
          [sat2_m1],
          [sat2_m2],
          [sat2_sp]
        )
      ) AS p
  ),
  act_presenior AS (
    SELECT
      a.student_number,
      a.composite,
      ROW_NUMBER() OVER (
        PARTITION BY
          a.student_number
        ORDER BY
          a.composite DESC
      ) AS rn_highest_presenior
    FROM
      naviance.act_scores_clean AS a
      INNER JOIN powerschool.cohort_identifiers_static AS co ON (
        a.student_number = co.student_number
        AND a.academic_year = co.academic_year
        AND co.grade_level < 12
        AND co.rn_year = 1
      )
  ),
  college_apps AS (
    SELECT
      applicant_c,
      application_submission_status_c,
      COUNT(id) AS n_applications_submitted,
      SUM(is_ltr_match) AS n_ltr_applications,
      SUM(is_closed_application) AS n_closed_applications,
      SUM(is_efc_entered) AS n_efc_entered,
      MAX(is_eaed_application) AS is_eaed_applicant,
      SUM(is_accepted) AS n_accepted,
      MAX(is_accepted_4yr) AS is_accepted_4yr,
      MAX(is_award_information_entered) AS is_award_information_entered,
      AVG(unmet_need_c) AS avg_unmet_need,
      SUM(
        accepted_app_closed_with_reason_not_attending
      ) AS n_closed_with_reason
    FROM
      (
        SELECT
          a.id,
          a.applicant_c,
          a.name,
          a.application_status_c,
          a.application_submission_status_c,
          a.application_admission_type_c,
          a.match_type_c,
          a.matriculation_decision_c,
          a.starting_application_status_c,
          a.financial_aid_eligibility_c,
          a.efc_from_fafsa_c,
          a.primary_reason_for_not_attending_c,
          a.unmet_need_c,
          CASE
            WHEN a.match_type_c = 'Unable to Calculate' THEN NULL
            WHEN a.match_type_c IN ('Likely Plus', 'Target', 'Reach') THEN 1.0
            WHEN a.match_type_c NOT IN ('Likely Plus', 'Target', 'Reach') THEN 0.0
          END AS is_ltr_match,
          CASE
            WHEN (
              a.application_admission_type_c IN ('Early Action', 'Early Decision')
            ) THEN 1.0
            ELSE 0.0
          END AS is_eaed_application,
          CASE
            WHEN a.application_status_c != 'Unknown' THEN 1.0
            ELSE 0.0
          END AS is_closed_application,
          CASE
            WHEN a.efc_from_fafsa_c IS NOT NULL THEN 1.0
            ELSE 0.0
          END AS is_efc_entered,
          CASE
            WHEN (
              a.matriculation_decision_c = 'Matriculated (Intent to Enroll)'
              AND a.unmet_need_c IS NOT NULL
            ) THEN 1.0
            ELSE 0.0
          END AS is_award_information_entered,
          CASE
            WHEN a.application_status_c = 'Accepted' THEN 1.0
            ELSE 0.0
          END AS is_accepted,
          CASE
            WHEN (
              a.application_status_c = 'Accepted'
              AND SUBSTRING(
                s.type,
                PATINDEX('%[24] yr%', s.type),
                1
              ) = '4'
            ) THEN 1.0
            ELSE 0.0
          END AS is_accepted_4yr,
          CASE
            WHEN a.application_status_c != 'Accepted' THEN NULL
            WHEN (
              a.application_status_c = 'Accepted'
              AND a.matriculation_decision_c = 'Matriculated (Intent to Enroll)'
            ) THEN 1
            WHEN (
              a.application_status_c = 'Accepted'
              AND a.matriculation_decision_c != 'Matriculated (Intent to Enroll)'
              AND a.primary_reason_for_not_attending_c IS NOT NULL
            ) THEN 1
            WHEN (
              a.application_status_c = 'Accepted'
              AND a.matriculation_decision_c != 'Matriculated (Intent to Enroll)'
              AND a.primary_reason_for_not_attending_c IS NULL
            ) THEN 0
          END AS accepted_app_closed_with_reason_not_attending,
          s.type
        FROM
          alumni.application_c AS a
          INNER JOIN alumni.account AS s ON (
            a.school_c = s.id
            AND s.is_deleted = 0
          )
        WHERE
          a.is_deleted = 0
      ) AS sub
    GROUP BY
      applicant_c,
      application_submission_status_c
  )
SELECT
  co.student_number,
  co.lastfirst,
  co.exit_schoolid AS reporting_schoolid,
  co.exit_grade_level AS grade_level,
  NULL AS enroll_status,
  co.counselor_name,
  CASE
    WHEN co.ktc_status = 'TAF' THEN 1
    ELSE 0
  END AS is_taf,
  co.ktc_cohort AS cohort,
  co.is_informed_consent AS informed_consent_c,
  co.latest_fafsa_date AS latest_fafsa_date_c,
  co.latest_state_financial_aid_app_date AS latest_state_financial_aid_app_date_c,
  co.latest_transcript_date AS latest_transcript_c,
  co.exit_db_name AS [db_name],
  CASE
    WHEN (
      co.ktc_status = 'TAF'
      AND co.exit_grade_level = 12
    ) THEN gpa.cumulative_y1_gpa
    WHEN (
      co.ktc_status = 'TAF'
      AND co.exit_grade_level = 11
    ) THEN gpa.cumulative_y1_gpa_projected
    WHEN co.ktc_status = 'TAF' THEN co.college_match_display_gpa
  END AS cumulative_y1_gpa,
  ctcs.attended_2018_junior_kickoff,
  ctcs.fafsa_4_caster_complete,
  ctcs.matriculation_checklist_complete_transfer_to_persistence_counselor,
  ctcs.college_decision_meeting_complete_with_parent_and_persistence_,
  ctcs.submit_most_recent_taxes_income,
  ctcs.submit_most_recent_tax_transcripts,
  ctcs.submit_previous_year_s_taxes,
  ctcs.submit_previous_year_s_tax_transcripts,
  ctcs.counselor_lor_submitted_to_naviance,
  ctcs.counselor_lor_common_app_eval_uploaded_to_naviance,
  ctcs.teacher_lor_1_submitted_to_naviance,
  ctcs.teacher_lor_2_submitted_to_naviance,
  ctcs.teacher_ca_eval_1_submitted_to_naviance,
  ctcs.teacher_ca_eval_2_submitted_to_naviance,
  ctcs.common_app_complete_and_synced_to_naviance,
  ctcs.personal_statement_complete_and_submitted_to_counselor,
  ctcs.first_1_1_meeting_with_counselor_junior_year_,
  ctcs.q_1_counselor_1_1_meeting_complete,
  ctcs.q_2_counselor_meeting_1_of_2_complete,
  ctcs.q_2_counselor_meeting_2_of_2_complete,
  ctcs._3_q_counselor_meeting_1_of_2,
  ctcs._3_q_counselor_meeting_2_of_2,
  ctcs._4_q_counselor_meeting_1_of_2,
  ctcs._4_q_counselor_meeting_2_of_2,
  ctcs.senior_parent_meeting_1_of_2,
  ctcs.senior_parent_meeting_2_of_2,
  ctcs.registered_for_october_act,
  ctcs.scholarship_1_submitted,
  ctcs.scholarship_2_submitted,
  ctcs.cte_survey_complete,
  ctcs.resume_complete,
  ctcs.brag_sheet_complete,
  ctcs.lor_requests_complete_2_,
  ctcs.parent_attended_q_3_parent_night,
  ctcs.parent_attended_q_4_parent_conferences,
  ctcs.registered_for_july_act,
  ctcs.registered_for_december_act,
  ctcs.registered_for_april_act,
  ctcs.act_test_release_report_submitted,
  NULL AS registered_for_may_subject_tests,
  na.n_award_letters_collected,
  na.is_acceptance_letter_collected,
  COALESCE(
    act.composite,
    co.highest_act_score
  ) AS act_composite_highest,
  ap.composite AS act_composite_highest_presenior_year,
  am.act_dec,
  am.act_oct,
  am.act_apr,
  CASE
    WHEN CONCAT(
      am.sat2_ch,
      am.sat2_fl,
      am.sat2_lr,
      am.sat2_m1,
      am.sat2_m2,
      am.sat2_sp
    ) != '' THEN 1.0
    ELSE 0.0
  END AS took_sat2,
  ca.n_applications_submitted,
  ca.n_ltr_applications,
  ca.n_efc_entered,
  ca.n_closed_applications,
  ca.n_accepted,
  ca.is_accepted_4yr,
  ca.is_award_information_entered,
  ca.avg_unmet_need,
  ca.n_closed_with_reason,
  COALESCE(ca.is_eaed_applicant, 0) AS is_eaed_applicant,
  ei.ecc_adjusted_6_year_minority_graduation_rate AS ecc_rate,
  CASE
    WHEN SUBSTRING(
      ei.ecc_pursuing_degree_type,
      PATINDEX(
        '%[24]%year%',
        ei.ecc_pursuing_degree_type
      ),
      1
    ) = '4' THEN 1.0
    ELSE 0.0
  END AS is_matriculating_4yr,
  CASE
    WHEN SUBSTRING(
      ei.ecc_pursuing_degree_type,
      PATINDEX(
        '%[24]%year%',
        ei.ecc_pursuing_degree_type
      ),
      1
    ) = '2' THEN 1.0
    ELSE 0.0
  END AS is_matriculating_2yr,
  CASE
    WHEN SUBSTRING(
      ei.ugrad_pursuing_degree_type,
      PATINDEX(
        '%[24]%year%',
        ei.ugrad_pursuing_degree_type
      ),
      1
    ) = '4' THEN 1.0
    ELSE 0.0
  END AS is_attending_4yr
FROM
  alumni.ktc_roster AS co
  LEFT JOIN powerschool.gpa_cumulative AS gpa ON (
    co.studentid = gpa.studentid
    AND co.exit_schoolid = gpa.schoolid
    AND co.exit_db_name = gpa.[db_name]
  )
  LEFT JOIN naviance.current_task_completion_status AS ctcs ON (
    co.student_number = ctcs.student_id
  )
  LEFT JOIN nav_applications AS na ON (
    co.student_number = na.hs_student_id
  )
  LEFT JOIN naviance.act_scores_clean AS act ON (
    co.student_number = act.student_number
    AND act.rn_highest = 1
  )
  LEFT JOIN act_presenior AS ap ON (
    co.student_number = ap.student_number
    AND ap.rn_highest_presenior = 1
  )
  LEFT JOIN act_month AS am ON (
    co.student_number = am.student_number
    AND co.exit_academic_year = am.academic_year
  )
  LEFT JOIN college_apps AS ca ON (
    co.sf_contact_id = ca.applicant_c
    AND ca.application_submission_status_c = 'Submitted'
  )
  LEFT JOIN alumni.enrollment_identifiers AS ei ON co.sf_contact_id = ei.student_c
WHERE
  co.ktc_status IN ('HS11', 'HS12')
