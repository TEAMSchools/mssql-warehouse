WITH
  foo AS (
    SELECT
      kt.sf_contact_id,
      kt.sf_email,
      c.secondary_email_c AS sf_email2,
      MAX(
        CASE
          WHEN ei.ugrad_status = 'Graduated' THEN 1
          WHEN ei.cte_status = 'Graduated' THEN 1
        END
      ) OVER (
        PARTITION BY
          kt.sf_contact_id
      ) AS is_graduated,
      MIN(
        CASE
          WHEN ei.ugrad_status = 'Graduated' THEN ei.ugrad_actual_end_date
          WHEN ei.cte_status = 'Graduated' THEN ei.cte_actual_end_date
        END
      ) OVER (
        PARTITION BY
          kt.sf_contact_id
      ) AS graduated_end_date
    FROM
      alumni.ktc_roster AS kt
      INNER JOIN alumni.contact AS c ON (kt.sf_contact_id = c.id)
      INNER JOIN alumni.enrollment_identifiers AS ei ON (
        ei.student_c = kt.sf_contact_id
        AND (
          ei.ugrad_status != 'Attending'
          OR ei.ugrad_status IS NULL
        )
        AND (
          ei.cte_status != 'Attending'
          OR ei.cte_status IS NULL
        )
      )
    WHERE
      kt.ktc_status = 'HSG'
  )
SELECT
  sf_contact_id,
  sf_email,
  sf_email2,
  graduated_end_date,
  is_graduated,
  CASE
    WHEN (
      (
        DATEPART(MONTH, graduated_end_date) BETWEEN 8 AND 12
        OR DATEPART(MONTH, graduated_end_date) = 1
      )
      AND graduated_end_date >= '2021-08-01'
      AND is_graduated = 1
    ) THEN (
      CONCAT(
        'Fall ',
        utilities.DATE_TO_SY (graduated_end_date),
        '-',
        RIGHT(
          utilities.DATE_TO_SY (graduated_end_date),
          2
        ) + 1,
        ' Grads'
      )
    )
    WHEN (
      (
        DATEPART(MONTH, graduated_end_date) BETWEEN 2 AND 7
        OR DATEPART(MONTH, graduated_end_date) = 1
      )
      AND graduated_end_date >= '2021-08-01'
      AND is_graduated = 1
    ) THEN (
      CONCAT(
        'Spring ',
        utilities.DATE_TO_SY (graduated_end_date),
        '-',
        RIGHT(
          utilities.DATE_TO_SY (graduated_end_date),
          2
        ) + 1,
        ' Grads'
      )
    )
    WHEN is_graduated IS NULL THEN 'Older Alum - No Degree/Certificate'
    WHEN (
      graduated_end_date < '2021-08-01'
      AND is_graduated = 1
    ) THEN 'Older Alum - Pre 2021 Grad'
  END AS survey_round
FROM
  foo
