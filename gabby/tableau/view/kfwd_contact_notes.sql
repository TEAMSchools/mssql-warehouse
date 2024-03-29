CREATE OR ALTER VIEW
  tableau.kfwd_contact_notes AS
SELECT
  ktc.sf_contact_id,
  ktc.first_name,
  ktc.last_name,
  ktc.current_kipp_student,
  ktc.kipp_region_name,
  ktc.college_match_display_gpa,
  ktc.currently_enrolled_school,
  ktc.latest_fafsa_date,
  ktc.latest_state_financial_aid_app_date,
  ktc.last_successful_advisor_contact_date,
  ktc.last_successful_contact_date,
  ktc.last_outreach_date,
  ktc.counselor_name,
  cn.created_by_id,
  cn.subject_c,
  cn.date_c,
  cn.comments_c,
  cn.next_steps_c,
  cn.status_c,
  cn.type_c
FROM
  alumni.contact_note_c AS cn
  INNER JOIN alumni.ktc_roster AS ktc ON (cn.contact_c = ktc.sf_contact_id)
WHERE
  cn.is_deleted = 0
