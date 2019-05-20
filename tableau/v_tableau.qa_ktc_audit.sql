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
   AND r.[name] = 'College Student'
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
  FROM STRING_SPLIT('Degree Audit,Bill,Financial Aid Award Letter,Schedule,Transcript', ',')
 )

,attachments_clean AS (
  SELECT sub.contact_id
        ,sub.[name]
        ,SUBSTRING(sub.[name]
                 ,(sub.underscore_1 + 1)
                 ,(sub.underscore_2 - sub.underscore_1 - 1)) AS semester
        ,SUBSTRING(sub.[name]
                 ,(sub.underscore_2 + 1)
                 ,(sub.underscore_3 - sub.underscore_2 - 1)) AS [year]
        ,SUBSTRING(sub.[name]
                 ,(sub.underscore_3 + 1)
                 ,(sub.file_ext_dot - sub.underscore_3)) AS document_type
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

,enr_hist AS (
  SELECT eh.parent_id AS enrollment_id
        ,eh.created_date AS status_change_date
        ,ROW_NUMBER() OVER(PARTITION BY eh.parent_id ORDER BY eh.created_date DESC) AS rn

        ,u.name AS updated_by
  FROM gabby.alumni.enrollment_history eh
  JOIN gabby.alumni.[user] u
    ON eh.created_by_id = u.id
  WHERE eh.field = 'Status__c'
    AND eh.is_deleted = 0
    AND eh.old_value IN ('Attending', 'Matriculated')
    AND CONCAT(eh.old_value, eh.new_value) NOT IN ('MatriculatedDid Not Enroll', 'MatriculatedAttending')
    AND eh.new_value NOT IN ('Graduated')
 )

,enrollment_audits AS (
  SELECT u.contact_id
        ,u.status_change_date
        ,u.updated_by      
        ,u.field AS audit_name
        ,u.value AS audit_value
        ,CASE
          WHEN u.field IN ('actual_end_date_c', 'description', 'notes_c', 'transfer_reason_c')
           AND u.value != ''
                 THEN 1
          WHEN u.field = 'date_last_verified_c'
           AND  CONVERT(DATE,u.value) BETWEEN u.status_change_date AND DATEADD(DAY, 30, u.status_change_date)
                 THEN 1
          ELSE 0
         END AS audit_result
  FROM
      (
       SELECT eh.enrollment_id
             ,eh.status_change_date
             ,eh.updated_by

             ,e.student_c AS contact_id
             ,e.status_c
             ,ISNULL(CONVERT(NVARCHAR(MAX),e.actual_end_date_c), '') AS actual_end_date_c
             ,ISNULL(CONVERT(NVARCHAR(MAX),e.date_last_verified_c), '') AS date_last_verified_c
             ,ISNULL(CONVERT(NVARCHAR(MAX),e.notes_c), '') AS notes_c
             ,ISNULL(CONVERT(NVARCHAR(MAX),e.transfer_reason_c), '') AS transfer_reason_c

             ,ISNULL(CONVERT(NVARCHAR(MAX),c.description), '') AS description
       FROM enr_hist eh
       JOIN gabby.alumni.enrollment_c e
         ON eh.enrollment_id = e.id
       JOIN gabby.alumni.contact c
         ON e.student_c = c.id
       WHERE eh.rn = 1
      ) sub
  UNPIVOT(
    value
    FOR field IN (actual_end_date_c
                 ,date_last_verified_c
                 ,notes_c
                 ,transfer_reason_c
                 ,description)
   ) u
 )

SELECT r.contact_id
      ,r.contact_name
      ,r.cohort
      ,r.ktc_counselor_name

      ,'Attachment Audit' AS audit_type
      ,NULL AS status_change_date
      ,NULL AS updated_by
      ,s.semester + ' ' + s.[year] + ' ' + d.document_type AS audit_name
      ,CASE WHEN a.name IS NOT NULL THEN 1 ELSE 0 END AS audit_result
      ,a.name AS audit_value
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
      ,r.contact_name
      ,r.cohort      
      ,r.ktc_counselor_name

      ,'Enrollment Audit' AS audit_type
      ,ea.status_change_date
      ,ea.updated_by
      ,ea.audit_name
      ,ea.audit_result
      ,ea.audit_value
FROM roster r
JOIN enrollment_audits ea
  ON r.contact_id = ea.contact_id