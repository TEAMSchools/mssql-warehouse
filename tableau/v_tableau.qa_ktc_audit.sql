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
    AND c.post_hs_simple_admin_c = 'College Persisting'
    AND (c.kipp_hs_graduate_c = 1 OR c.kipp_ms_graduate_c = 1)
 )

,valid_semesters AS (
  SELECT [value] AS semester
        ,CASE 
          WHEN [value] = 'SP' THEN '19'
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

SELECT r.contact_id
      ,r.contact_name
      ,r.cohort
      ,r.ktc_counselor_name

      ,'Attachment Audit' AS audit_type
      ,s.semester + ' ' + s.[year] + ' ' + d.document_type AS audit_name
      ,CASE WHEN a.name IS NOT NULL THEN 1 ELSE 0 END AS audit_result
FROM roster r
CROSS JOIN valid_semesters s
CROSS JOIN valid_documents d
LEFT JOIN attachments_clean a
  ON r.contact_id = a.contact_id
 AND s.semester = a.semester
 AND s.[year] = a.[year] 
 AND d.document_type = a.document_type