USE gabby GO
CREATE OR ALTER VIEW
  extracts.njdoe_bgcheck_audit AS
SELECT
  employee_number,
  associate_oid,
  is_approved,
  is_approved_district
  --,business_unit_code
  --,approvaldate
  --,approved_districtcode
  --,approved_business_unit_code
  --,rn_emp
FROM
  (
    SELECT
      employee_number,
      associate_oid,
      is_approved,
      CASE
        WHEN business_unit_code = approved_business_unit_code THEN 1
        WHEN business_unit_code = 'KIPP_TAF'
        AND is_approved = 1 THEN 1
        ELSE 0
      END AS is_approved_district,
      ROW_NUMBER() OVER (
        PARTITION BY
          employee_number
        ORDER BY
          approvaldate DESC,
          approved_business_unit_code DESC
      ) AS rn_emp
      --,business_unit_code
      --,approvaldate
      --,approved_districtcode
      --,approved_business_unit_code
    FROM
      (
        SELECT
          sr.employee_number,
          sr.associate_oid,
          sr.business_unit_code
          --,sr.preferred_name
          --,sr.position_status
,
          bg.approvaldate,
          bg.districtcode AS approved_districtcode,
          CASE
            WHEN bg.districtcode = 7325 THEN 'TEAM'
            WHEN bg.districtcode = 1799 THEN 'KCNA'
          END AS approved_business_unit_code,
          CASE
            WHEN bg.approvaldate IS NOT NULL THEN 1
            ELSE 0
          END AS is_approved
          --,bg.pcn
          --,bg.countycode
          --,bg.schoolcode
          --,bg.contractorcode
          --,bg.jobposition
        FROM
          gabby.people.staff_roster AS sr
          LEFT JOIN gabby.njdoe.background_check_approval_history AS bg ON sr.employee_number = bg.employee_number
        WHERE
          sr.position_status != 'Terminated'
          AND sr.business_unit != 'KIPP Miami'
      ) sub
  ) sub
WHERE
  rn_emp = 1
