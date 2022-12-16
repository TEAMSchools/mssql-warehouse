CREATE OR ALTER VIEW
  recruiting.hired_referrals AS
SELECT
  c.created_date,
  c.name AS cultivation_number,
  c.contact_name_c,
  c.cultivation_stage_c,
  c.referred_by_c,
  c.regional_source_detail_c,
  c.regional_source_c,
  c.cultivation_notes_c,
  pa.name AS profile_id,
  a.name AS job_app,
  a.hired_status_date_c AS hire_date,
  a.stage_c AS selection_stage,
  a.selection_status_c AS selection_status,
  a.cultivation_owner_c AS recruiter,
  p.name AS position_number,
  p.status_c AS position_status,
  p.position_name_c AS position_name,
  df.df_employee_number,
  COALESCE(df.rehire_date, df.original_hire_date) AS most_recent_hire_date,
  df.termination_date,
  df.status,
  DATEDIFF(
    DAY,
    COALESCE(df.rehire_date, df.original_hire_date),
    COALESCE(df.termination_date, CURRENT_TIMESTAMP)
  ) AS days_at_kipp,
  CASE
    WHEN df.df_employee_number IS NULL THEN 'Not matched in Dayforce - need to look up manually to verify'
  END AS dayforce_notes
FROM
  gabby.recruiting.cultivation_c AS c
  LEFT JOIN gabby.recruiting.job_application_c AS a ON LEFT(c.contact_c, LEN(c.contact_c) - 3) = a.contact_id_c
  AND a.stage_c = 'Hired'
  LEFT JOIN gabby.recruiting.profile_application_c AS pa ON a.profile_application_c = pa.id
  LEFT JOIN gabby.recruiting.job_position_c AS p ON a.job_position_c = p.id
  LEFT JOIN gabby.dayforce.staff_roster AS df ON p.name = df.salesforce_id
WHERE
  c.regional_source_c = 'Referral'
  AND (
    c.cultivation_stage_c = 'Hired'
    OR a.stage_c = 'Hired'
  )
