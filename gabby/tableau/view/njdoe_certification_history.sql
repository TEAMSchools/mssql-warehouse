CREATE OR ALTER VIEW
  tableau.njdoe_certification_history AS
SELECT
  s.df_employee_number,
  NULL AS certificate_history_json,
  c.seq_number,
  c.certificate_id,
  c.certificate_type,
  c.is_charter_school_only,
  c.endorsement,
  c.county_code,
  c.basis_code,
  c.district_code,
  c.month_year_issued,
  c.issued_date,
  c.month_year_expiration,
  c.expiration_date,
  s.preferred_name,
  s.original_hire_date,
  s.primary_job,
  s.legal_entity_name,
  s.[status],
  s.primary_site,
  s.userprincipalname
FROM
  people.staff_crosswalk_static AS s
  LEFT JOIN njdoe.certification_certificate_history_static AS c ON (
    s.df_employee_number = c.df_employee_number
  )
