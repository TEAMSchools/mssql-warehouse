SELECT
  'PH3' AS cola,
  /* account code */
  '10046698' AS colb,
  /* account name */
  'KIPP NEWARK COLLEGIATE ACADEMY' AS colc,
  'P' AS cold,
  /* file transmission date */
  /* diploma period */
  CAST(
    REPLACE(CAST(CURRENT_TIMESTAMP AS DATE), '-', '') AS VARCHAR
  ) AS cole,
  CONCAT(MIN(cohort), '-', MAX(cohort)) AS colf,
  NULL AS colg,
  NULL AS colh,
  NULL AS coli,
  NULL AS colj,
  NULL AS colk,
  NULL AS coll,
  NULL AS colm,
  NULL AS coln,
  NULL AS colo,
  NULL AS colp,
  NULL AS colq,
  NULL AS colr,
  NULL AS cols,
  NULL AS colt,
  NULL AS colu,
  NULL AS colv,
  NULL AS colw,
  NULL AS colx,
  NULL AS coly,
  NULL AS colz,
  NULL AS colaa,
  NULL AS colab
FROM
  gabby.powerschool.cohort_identifiers_static AS co
WHERE
  co.grade_level = 12
  AND co.exitcode = 'G1'
UNION ALL
SELECT
  'PD3' AS cola,
  'NO SSN' AS colb,
  /* first name */
  co.first_name colc,
  /* middle name */
  NULL AS cold,
  /* last name */
  co.last_name AS cole,
  /* name suffix */
  NULL AS colf,
  /* prev last name */
  NULL AS colg,
  /* prev first name */
  NULL AS colh,
  /* date of birth */
  CAST(
    REPLACE(CAST(co.dob AS DATE), '-', '') AS VARCHAR
  ) AS coli,
  /* student ID */
  co.student_number AS colj,
  /* diploma type */
  'Regular Diploma' AS colk,
  /* HS graduation date */
  /* FERPA block */
  CAST(
    REPLACE(CAST(co.exitdate AS DATE), '-', '') AS VARCHAR
  ) AS coll,
  'N' AS colm,
  /* high school name */
  'KIPP NEWARK COLLEGIATE ACADEMY' AS coln,
  /* ACT code */
  '310986' AS colo,
  /* gender */
  NULL AS colp,
  /* ethnicity */
  NULL AS colq,
  /* econ disadvantaged */
  NULL AS colr, -- 8th gr state assessment - math
  NULL AS cols, -- 8th gr state assessment - ela
  NULL AS colt, -- HS state assessment - math
  NULL AS colu, -- HS gr state assessment - ela
  NULL AS colv,
  /* ELL */
  NULL AS colw, -- # semseters of math
  NULL AS colx,
  /* dual enrollment */
  NULL AS coly,
  /* disability code */
  NULL AS colz,
  /* program code */
  NULL AS colaa,
  'ED' AS colab
FROM
  gabby.powerschool.cohort_identifiers_static AS co
WHERE
  co.school_level = 'HS'
  AND co.exitcode = 'G1'
UNION ALL
SELECT
  'PT3' AS cola,
  CAST(COUNT(student_number) + 2 AS VARCHAR) AS colb,
  NULL AS colc,
  NULL AS cold,
  NULL AS cole,
  NULL AS colf,
  NULL AS colg,
  NULL AS colh,
  NULL AS coli,
  NULL AS colj,
  NULL AS colk,
  NULL AS coll,
  NULL AS colm,
  NULL AS coln,
  NULL AS colo,
  NULL AS colp,
  NULL AS colq,
  NULL AS colr,
  NULL AS cols,
  NULL AS colt,
  NULL AS colu,
  NULL AS colv,
  NULL AS colw,
  NULL AS colx,
  NULL AS coly,
  NULL AS colz,
  NULL AS colaa,
  NULL AS colab
FROM
  gabby.powerschool.cohort_identifiers_static AS co
WHERE
  co.school_level = 'HS'
  AND co.exitcode = 'G1'
