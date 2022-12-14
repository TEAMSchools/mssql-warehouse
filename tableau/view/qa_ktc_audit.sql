USE gabby GO
CREATE OR ALTER VIEW
  tableau.qa_ktc_audit AS
WITH
  roster AS (
    SELECT
      c.id AS contact_id,
      c.[name] AS contact_name,
      c.kipp_hs_class_c AS cohort,
      c.dep_post_hs_simple_admin_c,
      u.[name] AS ktc_counselor_name
    FROM
      gabby.alumni.contact c
      INNER JOIN gabby.alumni.record_type r ON c.record_type_id = r.id
      AND r.[name] IN ('College Student', 'Post-Education')
      INNER JOIN gabby.alumni.[user] u ON c.owner_id = u.id
    WHERE
      c.is_deleted = 0
      AND (
        c.kipp_hs_graduate_c = 1
        OR c.kipp_ms_graduate_c = 1
      )
  ),
  valid_semesters AS (
    SELECT
      [value] AS semester,
      CAST(RIGHT(rg.n + 1, 2) AS VARCHAR(5)) AS [year]
    FROM
      STRING_SPLIT ('FA,SP', ',') ss
      INNER JOIN gabby.utilities.row_generator rg ON rg.n
      --BETWEEN gabby.utilities.GLOBAL_ACADEMIC_YEAR () - 2 AND gabby.utilities.GLOBAL_ACADEMIC_YEAR  () + 1
  ),
  valid_documents AS (
    SELECT
      [value] AS document_type
    FROM
      STRING_SPLIT ('DA,Bill,FAAL,Schedule,Transcript', ',')
  ),
  attachments_clean AS (
    SELECT
      sub.contact_id,
      sub.[name],
      LTRIM(
        RTRIM(
          SUBSTRING(
            sub.[name],
            (sub.underscore_1 + 1),
            (sub.underscore_2 - sub.underscore_1 - 1)
          )
        )
      ) AS semester,
      LTRIM(
        RTRIM(
          SUBSTRING(
            sub.[name],
            (sub.underscore_2 + 1),
            (sub.underscore_3 - sub.underscore_2 - 1)
          )
        )
      ) AS [year],
      LTRIM(
        RTRIM(
          SUBSTRING(
            sub.[name],
            (sub.underscore_3 + 1),
            (sub.file_ext_dot - sub.underscore_3)
          )
        )
      ) AS document_type
    FROM
      (
        SELECT
          a.parent_id AS contact_id,
          a.[name],
          LEN(a.[name]) AS name_len,
          LEN(a.[name]) - CHARINDEX('.', REVERSE(a.[name])) AS file_ext_dot,
          CHARINDEX('_', a.[name]) AS underscore_1,
          CASE
            WHEN CHARINDEX('_', a.[name]) = 0 THEN NULL
            WHEN CHARINDEX('_', a.[name], CHARINDEX('_', a.[name]) + 1) = 0 THEN NULL
            ELSE CHARINDEX('_', a.[name], CHARINDEX('_', a.[name]) + 1)
          END AS underscore_2,
          CASE
            WHEN CHARINDEX('_', a.[name], CHARINDEX('_', a.[name]) + 1) = 0 THEN NULL
            WHEN CHARINDEX(
              '_',
              a.[name],
              CHARINDEX('_', a.[name], CHARINDEX('_', a.[name]) + 1) + 1
            ) = 0 THEN NULL
            ELSE CHARINDEX(
              '_',
              a.[name],
              CHARINDEX('_', a.[name], CHARINDEX('_', a.[name]) + 1) + 1
            )
          END AS underscore_3
        FROM
          gabby.alumni.attachment a
        WHERE
          a.is_deleted = 0
      ) sub
  ),
  enr_hist_attmat AS (
    SELECT
      eh.parent_id AS enrollment_id,
      CAST(eh.created_date AS DATE) AS status_change_date,
      ROW_NUMBER() OVER (
        PARTITION BY
          eh.parent_id
        ORDER BY
          eh.created_date DESC
      ) AS rn,
      e.student_c AS contact_id,
      u.[name] AS updated_by
    FROM
      gabby.alumni.enrollment_history eh
      INNER JOIN gabby.alumni.enrollment_c e ON eh.parent_id = e.id
      INNER JOIN gabby.alumni.[user] u ON eh.created_by_id = u.id
    WHERE
      eh.field = 'Status__c'
      AND eh.is_deleted = 0
      AND eh.old_value IN ('Attending', 'Matriculated')
      AND CONCAT(eh.old_value, eh.new_value) NOT IN (
        'MatriculatedDid Not Enroll',
        'MatriculatedAttending'
      )
      AND eh.new_value NOT IN ('Graduated')
  ),
  enr_hist_grad AS (
    SELECT
      eh.parent_id AS enrollment_id,
      CAST(eh.created_date AS DATE) AS status_change_date,
      ROW_NUMBER() OVER (
        PARTITION BY
          eh.parent_id
        ORDER BY
          eh.created_date DESC
      ) AS rn,
      e.student_c AS contact_id,
      u.[name] AS updated_by
    FROM
      gabby.alumni.enrollment_history eh
      INNER JOIN gabby.alumni.enrollment_c e ON eh.parent_id = e.id
      INNER JOIN gabby.alumni.[user] u ON eh.created_by_id = u.id
    WHERE
      eh.field = 'Status__c'
      AND eh.is_deleted = 0
      AND eh.new_value = 'Graduated'
  ),
  enrollment_unpivot AS (
    SELECT
      u.enrollment_id,
      u.enrollment_name,
      u.field AS audit_name,
      u.[value] AS audit_value
    FROM
      (
        SELECT
          e.id AS enrollment_id,
          e.[name] AS enrollment_name,
          e.status_c,
          ISNULL(CAST(e.actual_end_date_c AS NVARCHAR(MAX)), '') AS actual_end_date_c,
          ISNULL(CAST(e.date_last_verified_c AS NVARCHAR(MAX)), '') AS date_last_verified_c,
          ISNULL(CAST(e.date_last_verified_c AS NVARCHAR(MAX)), '') AS date_last_verified_ontime,
          ISNULL(CAST(e.notes_c AS NVARCHAR(MAX)), '') AS notes_c,
          ISNULL(CAST(e.transfer_reason_c AS NVARCHAR(MAX)), '') AS transfer_reason_c,
          ISNULL(
            CAST(COALESCE(e.major_c, e.major_area_c)),
            '' AS NVARCHAR(MAX)
          ) AS major_or_area,
          ISNULL(
            CAST(e.college_major_declared_c AS NVARCHAR(MAX)),
            ''
          ) AS college_major_declared_c,
          ISNULL(CAST(c.[description] AS NVARCHAR(MAX)), '') AS [description]
        FROM
          gabby.alumni.enrollment_c e
          INNER JOIN gabby.alumni.contact c ON e.student_c = c.id
        WHERE
          e.type_c = 'College'
      ) sub UNPIVOT (
        [value] FOR field IN (
          actual_end_date_c,
          date_last_verified_c,
          date_last_verified_ontime,
          notes_c,
          transfer_reason_c,
          [description],
          major_or_area,
          college_major_declared_c
        )
      ) u
  )
SELECT
  r.contact_id,
  r.contact_name,
  r.cohort,
  r.ktc_counselor_name,
  'Attachment Audit' AS audit_type,
  r.contact_id AS record_id,
  NULL AS status_change_date,
  NULL AS updated_by,
  s.semester + ' ' + s.[year] + ' ' + d.document_type AS audit_name,
  a.[name] AS audit_value,
  CASE
    WHEN a.[name] IS NOT NULL THEN 1
    ELSE 0
  END AS audit_result
FROM
  roster r
  CROSS JOIN valid_semesters s
  CROSS JOIN valid_documents d
  LEFT JOIN attachments_clean a ON r.contact_id = a.contact_id
  AND s.semester = a.semester
  AND s.[year] = a.[year]
  AND d.document_type = a.document_type
WHERE
  r.dep_post_hs_simple_admin_c IN ('College Persisting', 'College Grad - AA')
