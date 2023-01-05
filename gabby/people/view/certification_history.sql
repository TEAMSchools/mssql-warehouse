CREATE OR ALTER VIEW
  people.certification_history AS
SELECT
  employee_number,
  seq_number,
  certificate_id,
  certificate_type,
  is_charter_school_only,
  endorsement_or_rank,
  county_code,
  basis_code,
  district_code,
  month_year_issued,
  academic_year,
  issued_date,
  month_year_expiration,
  expiration_date,
  cert_status,
  valid_cert,
  cert_state,
  schoolstate,
  CASE
    WHEN schoolstate = cert_state THEN MAX(valid_cert) OVER (
      PARTITION BY
        employee_number
    )
  END AS is_certified
FROM
  (
    SELECT
      s.df_employee_number AS employee_number,
      pss.schoolstate,
      c.seq_number,
      c.certificate_id,
      c.certificate_type,
      c.is_charter_school_only,
      c.endorsement AS endorsement_or_rank,
      c.county_code,
      c.basis_code,
      c.district_code,
      c.month_year_issued,
      c.issued_date,
      c.month_year_expiration,
      c.expiration_date,
      CASE
        WHEN c.certificate_type IS NULL THEN 0
        WHEN c.certificate_type IN (
          'CE - Charter School - Temp',
          'CE - Temp',
          'Provisional - Temp'
        ) THEN 0
        ELSE 1
      END AS valid_cert,
      utilities.DATE_TO_SY (c.issued_date) AS academic_year,
      NULL AS cert_status,
      'NJ' AS cert_state
    FROM
      people.staff_crosswalk_static AS s
      LEFT JOIN powerschool.schools AS pss ON (
        s.primary_site_schoolid = pss.school_number
        AND s.[db_name] = pss.[db_name]
      )
      LEFT JOIN njdoe.certification_certificate_history_static AS c ON (
        s.df_employee_number = c.df_employee_number
      )
  ) AS sub
