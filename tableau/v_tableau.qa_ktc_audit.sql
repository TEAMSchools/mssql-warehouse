USE gabby
GO

CREATE OR ALTER VIEW tableau.qa_ktc_audit AS

WITH roster AS (
  SELECT c.id AS contact_id
        ,c.[name] AS contact_name
        ,c.kipp_hs_class_c AS cohort
        ,c.post_hs_simple_admin_c

        ,u.[name] AS ktc_counselor_name
  FROM gabby.alumni.contact c
  JOIN gabby.alumni.record_type r
    ON c.record_type_id = r.id
   AND r.[name] IN ('College Student', 'Post-Education')
  JOIN gabby.alumni.[user] u
    ON c.owner_id = u.id
  WHERE c.is_deleted = 0
    AND (c.kipp_hs_graduate_c = 1 OR c.kipp_ms_graduate_c = 1)
 )

,valid_semesters AS (
  SELECT [value] AS semester
        ,CASE 
          WHEN [value] = 'FA' THEN '19'
          WHEN [value] = 'SP' THEN '19'
         END AS [year]
  FROM STRING_SPLIT('FA,SP', ',')
 )

,valid_documents AS (
  SELECT [value] AS document_type
  FROM STRING_SPLIT('DA,Bill,FAAL,Schedule,Transcript', ',')
 )

,attachments_clean AS (
  SELECT sub.contact_id
        ,sub.[name]
        ,LTRIM(RTRIM(SUBSTRING(sub.[name]
                 ,(sub.underscore_1 + 1)
                 ,(sub.underscore_2 - sub.underscore_1 - 1)))) AS semester
        ,LTRIM(RTRIM(SUBSTRING(sub.[name]
                 ,(sub.underscore_2 + 1)
                 ,(sub.underscore_3 - sub.underscore_2 - 1)))) AS [year]
        ,LTRIM(RTRIM(SUBSTRING(sub.[name]
                 ,(sub.underscore_3 + 1)
                 ,(sub.file_ext_dot - sub.underscore_3)))) AS document_type
  FROM
      (
       SELECT a.parent_id AS contact_id
             ,a.[name]
             ,LEN(a.[name]) AS name_len
             ,LEN(a.[name]) - CHARINDEX('.', REVERSE(a.[name])) AS file_ext_dot
             ,CHARINDEX('_', a.[name]) AS underscore_1
             ,CASE 
               WHEN CHARINDEX('_', a.[name]) = 0 THEN NULL
               WHEN CHARINDEX('_', a.[name], CHARINDEX('_', a.[name]) + 1) = 0 THEN NULL
               ELSE CHARINDEX('_', a.[name], CHARINDEX('_', a.[name]) + 1) 
              END AS underscore_2
             ,CASE 
               WHEN CHARINDEX('_', a.[name], CHARINDEX('_', a.[name]) + 1) = 0 THEN NULL
               WHEN CHARINDEX('_', a.[name], CHARINDEX('_', a.[name], CHARINDEX('_', a.[name]) + 1) + 1) = 0 THEN NULL
               ELSE CHARINDEX('_', a.[name], CHARINDEX('_', a.[name], CHARINDEX('_', a.[name]) + 1) + 1) 
              END AS underscore_3
       FROM gabby.alumni.attachment a
       WHERE a.is_deleted = 0
      ) sub
 )

,enr_hist_attmat AS (
  SELECT eh.parent_id AS enrollment_id
        ,CONVERT(DATE,eh.created_date) AS status_change_date
        ,ROW_NUMBER() OVER(PARTITION BY eh.parent_id ORDER BY eh.created_date DESC) AS rn

        ,e.student_c AS contact_id

        ,u.name AS updated_by
  FROM gabby.alumni.enrollment_history eh
  JOIN gabby.alumni.enrollment_c e
    ON eh.parent_id = e.id
  JOIN gabby.alumni.[user] u
    ON eh.created_by_id = u.id
  WHERE eh.field = 'Status__c'
    AND eh.is_deleted = 0
    AND eh.old_value IN ('Attending', 'Matriculated')
    AND CONCAT(eh.old_value, eh.new_value) NOT IN ('MatriculatedDid Not Enroll', 'MatriculatedAttending')
    AND eh.new_value NOT IN ('Graduated')
 )

,enr_hist_grad AS (
  SELECT eh.parent_id AS enrollment_id
        ,CONVERT(DATE,eh.created_date) AS status_change_date
        ,ROW_NUMBER() OVER(PARTITION BY eh.parent_id ORDER BY eh.created_date DESC) AS rn

        ,e.student_c AS contact_id

        ,u.name AS updated_by
  FROM gabby.alumni.enrollment_history eh
  JOIN gabby.alumni.enrollment_c e
    ON eh.parent_id = e.id
  JOIN gabby.alumni.[user] u
    ON eh.created_by_id = u.id
  WHERE eh.field = 'Status__c'
    AND eh.is_deleted = 0
    AND eh.new_value = 'Graduated'
 )

,enrollment_unpivot AS (
  SELECT u.enrollment_id
        ,u.enrollment_name
        ,u.field AS audit_name
        ,u.value AS audit_value
  FROM
      (
       SELECT e.id AS enrollment_id
             ,e.name AS enrollment_name
             ,e.status_c
             ,ISNULL(CONVERT(NVARCHAR(MAX),e.actual_end_date_c), '') AS actual_end_date_c
             ,ISNULL(CONVERT(NVARCHAR(MAX),e.date_last_verified_c), '') AS date_last_verified_c
             ,ISNULL(CONVERT(NVARCHAR(MAX),e.date_last_verified_c), '') AS date_last_verified_ontime
             ,ISNULL(CONVERT(NVARCHAR(MAX),e.notes_c), '') AS notes_c
             ,ISNULL(CONVERT(NVARCHAR(MAX),e.transfer_reason_c), '') AS transfer_reason_c
             ,ISNULL(CONVERT(NVARCHAR(MAX),COALESCE(e.major_c, e.major_area_c)), '') AS major_or_area
             ,ISNULL(CONVERT(NVARCHAR(MAX),e.college_major_declared_c), '') AS college_major_declared_c

             ,ISNULL(CONVERT(NVARCHAR(MAX),c.description), '') AS description
       FROM gabby.alumni.enrollment_c e
       JOIN gabby.alumni.contact c
         ON e.student_c = c.id
       WHERE e.type_c = 'College'
      ) sub
  UNPIVOT(
    value
    FOR field IN (actual_end_date_c
                 ,date_last_verified_c
                 ,date_last_verified_ontime
                 ,notes_c
                 ,transfer_reason_c
                 ,description
                 ,major_or_area
                 ,college_major_declared_c)
   ) u
 )

SELECT r.contact_id
      ,r.contact_name
      ,r.cohort
      ,r.ktc_counselor_name

      ,'Attachment Audit' AS audit_type
      ,r.contact_id AS record_id
      ,NULL AS status_change_date
      ,NULL AS updated_by
      ,s.semester + ' ' + s.[year] + ' ' + d.document_type AS audit_name
      ,a.name AS audit_value
      ,CASE WHEN a.name IS NOT NULL THEN 1 ELSE 0 END AS audit_result
FROM roster r
CROSS JOIN valid_semesters s
CROSS JOIN valid_documents d
LEFT JOIN attachments_clean a
  ON r.contact_id = a.contact_id
 AND s.semester = a.semester
 AND s.[year] = a.[year] 
 AND d.document_type = a.document_type
WHERE r.post_hs_simple_admin_c IN ('College Persisting', 'College Grad - AA')

UNION ALL

SELECT r.contact_id
      ,ea.enrollment_name
      ,r.cohort      
      ,r.ktc_counselor_name

      ,'Enrollment Audit' AS audit_type
      ,eh.enrollment_id AS record_id
      ,eh.status_change_date
      ,eh.updated_by
      
      ,ea.audit_name
      ,ea.audit_value
      ,CASE
        WHEN ea.audit_name IN ('actual_end_date_c', 'description', 'notes_c', 'transfer_reason_c')
         AND ea.audit_value != ''
               THEN 1
        WHEN ea.audit_name = 'date_last_verified_c'
         AND CONVERT(DATE, ea.audit_value) >= eh.status_change_date 
               THEN 1
        WHEN ea.audit_name = 'date_last_verified_ontime'
         AND CONVERT(DATE, ea.audit_value) >= DATEADD(DAY, 30, eh.status_change_date)
               THEN 1
        ELSE 0
       END AS audit_result
FROM roster r
JOIN enr_hist_attmat eh
  ON r.contact_id = eh.contact_id
 AND eh.rn = 1
JOIN enrollment_unpivot ea
  ON eh.enrollment_id = ea.enrollment_id
 AND ea.audit_name NOT IN ('major_or_area', 'college_major_declared_c')

UNION ALL

SELECT r.contact_id
      ,ea.enrollment_name
      ,r.cohort      
      ,r.ktc_counselor_name

      ,'Graduation Audit' AS audit_type
      ,eh.enrollment_id AS record_id
      ,eh.status_change_date
      ,eh.updated_by
      
      ,ea.audit_name
      ,ea.audit_value
      ,CASE
        WHEN ea.audit_name = 'college_major_declared_c' 
         AND ea.audit_value = '1'
               THEN 1
        WHEN ea.audit_name IN ('actual_end_date_c', 'major_or_area')
         AND ea.audit_value != ''
               THEN 1
        WHEN ea.audit_name = 'date_last_verified_c'
         AND CONVERT(DATE, ea.audit_value) >= eh.status_change_date 
               THEN 1
        WHEN ea.audit_name = 'date_last_verified_ontime'
         AND CONVERT(DATE, ea.audit_value) >= DATEADD(DAY, 30, eh.status_change_date)
               THEN 1
        ELSE 0
       END AS audit_result
FROM roster r
JOIN enr_hist_grad eh
  ON r.contact_id = eh.contact_id
 AND eh.rn = 1
JOIN enrollment_unpivot ea
  ON eh.enrollment_id = ea.enrollment_id
 AND ea.audit_name NOT IN ('description', 'notes_c', 'transfer_reason_c')