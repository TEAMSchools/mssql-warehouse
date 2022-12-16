SELECT
  'H1' AS cola,
  /* account number */
  '601193' AS colb,
  '00' AS colc,
  /* organization name */
  'KIPP THROUGH COLLEGE NEW JERSEY' AS cold,
  /* file creation date */
  /* inquiry purpose */
  CAST(
    REPLACE(CAST(CURRENT_TIMESTAMP AS DATE), '-', '') AS VARCHAR
  ) AS cole,
  'DA' AS colf,
  'S' AS colg,
  NULL AS colh,
  NULL AS coli,
  NULL AS colj,
  NULL AS colk,
  NULL AS coll
UNION ALL
SELECT
  'D1' AS cola,
  /* leave blank */
  NULL AS colb,
  first_name AS colc,
  /* middle initial */
  NULL AS cold,
  last_name AS cole,
  /* name suffix */
  NULL AS colf,
  /* date of birth */
  /* search begin date */
  CAST(
    REPLACE(CAST(dob AS DATE), '-', '') AS VARCHAR
  ) AS colg,
  /* leave blank */
  CAST(
    REPLACE(CAST(exitdate AS DATE), '-', '') AS VARCHAR
  ) AS colh,
  NULL AS coli,
  /* leave blank */
  NULL AS colj,
  '00' AS colk,
  /* requestor return field */
  CAST(student_number AS VARCHAR) AS coll
FROM
  gabby.powerschool.cohort_identifiers_static
WHERE
  rn_undergrad = 1
  AND exitcode = 'G1'
  AND grade_level != 99
  AND cohort <= gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
UNION ALL
SELECT
  'T1',
  CAST(COUNT(student_number) + 2 AS VARCHAR),
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
FROM
  gabby.powerschool.cohort_identifiers_static
WHERE
  rn_undergrad = 1
  AND exitcode = 'G1'
  AND grade_level != 99
  AND cohort <= gabby.utilities.GLOBAL_ACADEMIC_YEAR ()
