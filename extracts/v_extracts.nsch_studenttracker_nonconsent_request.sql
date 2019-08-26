USE gabby
GO

CREATE OR ALTER VIEW extracts.nsch_studenttracker_nonconsent_request AS

SELECT 'H1' AS ColA
      ,'601193' AS ColB /* account number */
      ,'00' AS ColC
      ,'KIPP THROUGH COLLEGE NEW JERSEY' AS ColD /* organization name */
      ,CONVERT(VARCHAR,REPLACE(CONVERT(DATE,GETDATE()), '-', '')) AS ColE /* file creation date */
      ,'DA' AS ColF /* inquiry purpose */
      ,'S' AS ColG
      ,NULL AS ColH
      ,NULL AS ColI
      ,NULL AS ColJ
      ,NULL AS ColK
      ,NULL AS ColL

UNION ALL

SELECT 'D1' AS ColA
      ,NULL AS ColB /* leave blank */
      ,first_name AS ColC
      ,NULL AS ColD /* middle initial */
      ,last_name AS ColE
      ,NULL AS ColF /* name suffix */
      ,CONVERT(VARCHAR,REPLACE(CONVERT(DATE,dob), '-', '')) AS ColG /* date of birth */
      ,CONVERT(VARCHAR,REPLACE(CONVERT(DATE,exitdate), '-', '')) AS ColH /* search begin date */
      ,NULL AS ColI /* leave blank */
      ,NULL AS ColJ /* leave blank */
      ,'00' AS ColK
      ,CONVERT(VARCHAR,student_number) AS ColL /* requestor return field */
FROM gabby.powerschool.cohort_identifiers_static
WHERE rn_undergrad = 1
  AND exitcode = 'G1'
  AND grade_level != 99
  AND cohort <= gabby.utilities.GLOBAL_ACADEMIC_YEAR()

UNION ALL

SELECT 'T1'
      ,CONVERT(VARCHAR,COUNT(student_number) + 2)
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
FROM gabby.powerschool.cohort_identifiers_static
WHERE rn_undergrad = 1
  AND exitcode = 'G1'
  AND grade_level != 99
  AND cohort <= gabby.utilities.GLOBAL_ACADEMIC_YEAR()