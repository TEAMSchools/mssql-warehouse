WITH
  approval_history AS (
    SELECT
      bg.employee_number,
      CAST(
        JSON_VALUE(ah.[value], '$.approvaldate') AS DATE
      ) AS approvaldate,
      CAST(
        JSON_VALUE(ah.[value], '$.countycode') AS NVARCHAR(256)
      ) AS countycode,
      CAST(
        JSON_VALUE(ah.[value], '$.districtcode') AS NVARCHAR(256)
      ) AS districtcode,
      CAST(
        JSON_VALUE(ah.[value], '$.schoolcode') AS NVARCHAR(256)
      ) AS schoolcode,
      CAST(
        JSON_VALUE(ah.[value], '$.contractorcode') AS NVARCHAR(256)
      ) AS contractorcode,
      CAST(
        JSON_VALUE(ah.[value], '$.jobposition') AS NVARCHAR(256)
      ) AS jobposition,
      CAST(
        JSON_VALUE(ah.[value], '$.pcn') AS NVARCHAR(256)
      ) AS pcn,
      CAST(
        JSON_VALUE(ah.[value], '$.transferind') AS DATE
      ) AS transferind
    FROM
      njdoe.background_check AS bg
      CROSS APPLY OPENJSON (bg.approval_history, '$') AS ah
    WHERE
      bg.approval_history != '[]'
  )
SELECT
  ah.employee_number,
  ah.approvaldate,
  ah.countycode,
  ah.districtcode,
  ah.schoolcode,
  CASE
    WHEN ah.contractorcode = '' THEN NULL
    ELSE ah.contractorcode
  END AS contractorcode,
  ah.jobposition,
  CAST(
    CONVERT(
      FLOAT,
      CASE
        WHEN ah.pcn != '' THEN ah.pcn
      END
    ) AS BIGINT
  ) AS pcn,
  CASE
    WHEN ah.transferind = '' THEN NULL
    ELSE ah.transferind
  END AS transferind,
  s.primary_job,
  s.legal_entity_name,
  s.primary_site,
  s.original_hire_date,
  s.[status],
  s.preferred_name,
  s.userprincipalname
FROM
  approval_history AS ah
  LEFT JOIN people.staff_crosswalk_static AS s ON (
    ah.employee_number = s.df_employee_number
  )
