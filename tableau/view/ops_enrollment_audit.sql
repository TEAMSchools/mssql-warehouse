USE gabby GO
CREATE OR ALTER VIEW
  tableau.ops_enrollment_audit AS
WITH
  residency_verification AS (
    SELECT
      s.student_number,
      COALESCE(rv.doc_1, x.residency_proof_1)
    COLLATE Latin1_General_BIN AS residency_proof_1,
    COALESCE(rv.doc_2, x.residency_proof_2)
    COLLATE Latin1_General_BIN AS residency_proof_2,
    COALESCE(rv.doc_3, x.residency_proof_3)
    COLLATE Latin1_General_BIN AS residency_proof_3,
    COALESCE(rv.age, x.birth_certificate_proof)
    COLLATE Latin1_General_BIN AS birth_certificate_proof,
    ROW_NUMBER() OVER (
      PARTITION BY
        s.student_number
      ORDER BY
        rv.[timestamp] DESC
    ) AS rn
    FROM
      gabby.powerschool.u_def_ext_students x
      JOIN gabby.powerschool.students s ON x.studentsdcid = s.dcid
      AND x.[db_name] = s.[db_name]
      AND s.enroll_status = 0
      LEFT JOIN gabby.enrollment.residency_verification rv ON s.student_number = rv.id
      AND rv.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
      AND rv._fivetran_deleted = 0
  ),
  all_data AS (
    SELECT
      sub.student_number,
      sub.newark_enrollment_number,
      sub.lastfirst,
      sub.region,
      sub.reporting_schoolid,
      sub.grade_level,
      sub.academic_year,
      sub.is_pathways,
      sub.entry_status,
      sub.registration_status,
      CAST(sub.lunch_app_status AS VARCHAR(500))
    COLLATE Latin1_General_BIN AS lunch_app_status,
    CAST(sub.lunch_balance AS VARCHAR(500))
    COLLATE Latin1_General_BIN AS lunch_balance,
    CAST(sub.iep_registration_followup AS VARCHAR(500))
    COLLATE Latin1_General_BIN AS iep_registration_followup_required,
    CAST(sub.lep_registration_followup AS VARCHAR(500))
    COLLATE Latin1_General_BIN AS lep_registration_followup_required,
    CAST(sub.birth_certificate_proof AS VARCHAR(500))
    COLLATE Latin1_General_BIN AS birth_certificate_proof,
    CAST(sub.residency_proof_1 AS VARCHAR(500))
    COLLATE Latin1_General_BIN AS residency_proof_1,
    CAST(sub.residency_proof_2 AS VARCHAR(500))
    COLLATE Latin1_General_BIN AS residency_proof_2,
    CAST(sub.residency_proof_3 AS VARCHAR(500))
    COLLATE Latin1_General_BIN AS residency_proof_3,
    CAST(sub.region + sub.city AS VARCHAR(500))
    COLLATE Latin1_General_BIN AS region_city,
    CONVERT(
      VARCHAR(500),
      CASE
        WHEN sub.iep_registration_followup = '1'
        AND sub.specialed_classification <> '' THEN 'Y'
        WHEN sub.iep_registration_followup = '1'
        AND sub.specialed_classification = '' THEN 'N'
        ELSE ''
      END
    )
    COLLATE Latin1_General_BIN AS iep_registration_followup_complete,
    CONVERT(
      VARCHAR(500),
      CASE
        WHEN sub.lep_registration_followup = '1'
        AND sub.lep_status <> '' THEN 'Y'
        WHEN sub.lep_registration_followup = '1'
        AND sub.lep_status = '' THEN 'N'
        ELSE ''
      END
    )
    COLLATE Latin1_General_BIN AS lep_registration_followup_complete,
    CONVERT(
      VARCHAR(500),
      CASE
        WHEN CONCAT(sub.residency_proof_1, sub.residency_proof_2, sub.residency_proof_3) NOT LIKE '%Missing%' THEN 'Y'
        ELSE 'N'
      END
    )
    COLLATE Latin1_General_BIN AS residency_proof_all
    FROM
      (
        SELECT
          s.student_number,
          s.lastfirst,
          s.grade_level,
          s.enroll_status,
          s.city,
          CASE
            WHEN s.[db_name] = 'kippcamden' THEN 'KCNA'
            WHEN s.[db_name] = 'kippnewark' THEN 'TEAM'
            WHEN s.[db_name] = 'kippmiami' THEN 'KMS'
          END AS region,
          COALESCE(co.reporting_schoolid, s.next_school) AS reporting_schoolid,
          COALESCE(co.is_pathways, 0) AS is_pathways,
          ISNULL(co.specialed_classification, '') AS specialed_classification,
          ISNULL(co.lep_status, '') AS lep_status,
          ISNULL(co.lunch_app_status, '') AS lunch_app_status,
          CAST(ISNULL(co.lunch_balance, 0) AS MONEY) AS lunch_balance,
          CASE
            WHEN s.enroll_status = -1 THEN 'Pre-Registered'
            WHEN COALESCE(co.year_in_network, 1) = 1 THEN 'New to KIPP NJ'
            WHEN COALESCE(co.year_in_school, 1) = 1 THEN 'New to School'
            ELSE 'Returning Student'
          END AS entry_status,
          suf.newark_enrollment_number,
          suf.registration_status,
          ISNULL(uxs.iep_registration_followup, '') AS iep_registration_followup,
          ISNULL(uxs.lep_registration_followup, '') AS lep_registration_followup,
          ISNULL(rv.residency_proof_1, 'Missing') AS residency_proof_1,
          CASE
            WHEN (
              s.enroll_status = -1
              OR COALESCE(co.year_in_network, 1) = 1
            ) THEN ISNULL(rv.residency_proof_2, 'Missing')
          END AS residency_proof_2,
          CASE
            WHEN (
              s.enroll_status = -1
              OR COALESCE(co.year_in_network, 1) = 1
            ) THEN ISNULL(rv.residency_proof_3, 'Missing')
          END AS residency_proof_3,
          ISNULL(rv.birth_certificate_proof, 'N') AS birth_certificate_proof,
          gabby.utilities.GLOBAL_ACADEMIC_YEAR () AS academic_year
        FROM
          gabby.powerschool.students s
          LEFT JOIN gabby.powerschool.cohort_identifiers_static co ON s.student_number = co.student_number
          AND s.[db_name] = co.[db_name]
          AND co.rn_undergrad = 1
          LEFT JOIN gabby.powerschool.u_studentsuserfields suf ON s.dcid = suf.studentsdcid
          AND s.[db_name] = suf.[db_name]
          LEFT JOIN gabby.powerschool.u_def_ext_students uxs ON s.dcid = uxs.studentsdcid
          AND s.[db_name] = uxs.[db_name]
          LEFT JOIN residency_verification rv ON s.student_number = rv.student_number
          AND rv.rn = 1
        WHERE
          s.enroll_status IN (-1, 0)
      ) sub
  ),
  unpivoted AS (
    SELECT
      student_number,
      academic_year,
      field,
      [value]
    FROM
      all_data UNPIVOT (
        [value] FOR field IN (
          region_city,
          iep_registration_followup_required,
          iep_registration_followup_complete,
          lep_registration_followup_required,
          lep_registration_followup_complete,
          lunch_app_status,
          lunch_balance,
          residency_proof_1,
          residency_proof_2,
          residency_proof_3,
          birth_certificate_proof,
          residency_proof_all
        )
      ) u
  )
SELECT
  a.student_number,
  a.newark_enrollment_number,
  a.lastfirst,
  a.academic_year,
  a.region,
  a.reporting_schoolid,
  a.grade_level,
  a.is_pathways,
  a.entry_status,
  a.lunch_app_status,
  a.lunch_balance,
  a.residency_proof_1,
  a.residency_proof_2,
  a.residency_proof_3,
  a.residency_proof_all,
  NULL AS reverification_date,
  a.birth_certificate_proof,
  a.iep_registration_followup_required,
  a.iep_registration_followup_complete,
  a.lep_registration_followup_required,
  a.lep_registration_followup_complete,
  a.registration_status,
  CASE
    WHEN a.region_city IN ('TEAMNewark', 'KCNACamden', 'KMSMiami') THEN 'Resident'
    ELSE 'Non-Resident'
  END AS residency_status,
  u.field AS audit_field,
  u.[value] AS audit_value,
  CASE
  /* 0 = FLAG || -1 = BAD || 1 = OK */
    WHEN u.field = 'region_city'
    AND u.[value] NOT IN ('TEAMNewark', 'KCNACamden', 'KMSMiami') THEN 0
    WHEN u.field = 'region_city'
    AND u.[value] IN ('TEAMNewark', 'KCNACamden', 'KMSMiami') THEN 1
    WHEN u.field = 'iep_registration_followup_required'
    AND a.iep_registration_followup_complete = 'Y' THEN 1
    WHEN u.field = 'iep_registration_followup_required'
    AND u.[value] = '1' THEN 0
    WHEN u.field = 'iep_registration_followup_complete'
    AND u.[value] = 'Y' THEN 1
    WHEN u.field = 'iep_registration_followup_complete'
    AND u.[value] = 'N' THEN -1
    WHEN u.field = 'lep_registration_followup_required'
    AND a.lep_registration_followup_complete = 'Y' THEN 1
    WHEN u.field = 'lep_registration_followup_required'
    AND u.[value] = '1' THEN 0
    WHEN u.field = 'lep_registration_followup_complete'
    AND u.[value] = 'Y' THEN 1
    WHEN u.field = 'lep_registration_followup_complete'
    AND u.[value] = 'N' THEN -1
    WHEN u.field = 'lunch_app_status'
    AND u.[value] NOT IN ('No Application', '') THEN 1
    WHEN u.field = 'lunch_app_status'
    AND u.[value] IN ('No Application', '') THEN -1
    WHEN u.field = 'lunch_balance'
    AND CAST(u.[value] AS MONEY) > 0 THEN 1
    WHEN u.field = 'lunch_balance'
    AND CAST(u.[value] AS MONEY) = 0 THEN 0
    WHEN u.field = 'lunch_balance'
    AND CAST(u.[value] AS MONEY) < 0 THEN -1
    WHEN u.field = 'birth_certificate_proof'
    AND u.[value] NOT IN ('', 'N') THEN 1
    WHEN u.field = 'birth_certificate_proof'
    AND u.[value] IN ('', 'N') THEN -1
    WHEN u.field = 'residency_proof_1'
    AND u.[value] NOT IN ('', 'Missing') THEN 1
    WHEN u.field = 'residency_proof_1'
    AND u.[value] IN ('', 'Missing') THEN -1
    WHEN u.field = 'residency_proof_2'
    AND u.[value] NOT IN ('', 'Missing') THEN 1
    WHEN u.field = 'residency_proof_2'
    AND u.[value] IN ('', 'Missing') THEN -1
    WHEN u.field = 'residency_proof_3'
    AND u.[value] NOT IN ('', 'Missing') THEN 1
    WHEN u.field = 'residency_proof_3'
    AND u.[value] IN ('', 'Missing') THEN -1
    WHEN u.field = 'residency_proof_all'
    AND u.[value] = 'Y' THEN 1
    WHEN u.field = 'residency_proof_all'
    AND u.[value] = 'N' THEN -1
  END AS audit_status
FROM
  all_data a
  JOIN unpivoted u ON a.student_number = u.student_number
  AND a.academic_year = u.academic_year
