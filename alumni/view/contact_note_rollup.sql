USE gabby GO
CREATE OR ALTER VIEW
  alumni.contact_note_rollup AS
SELECT
  contact_id,
  academic_year,
  [AS1] AS [AS1_date],
  [AS2] AS [AS2_date],
  [AS3] AS [AS3_date],
  [AS4] AS [AS4_date],
  [AS5] AS [AS5_date],
  [AS6] AS [AS6_date],
  [AS7] AS [AS7_date],
  [AS8] AS [AS8_date],
  [AS9] AS [AS9_date],
  [AS10] AS [AS10_date],
  [AS11] AS [AS11_date],
  [AS12] AS [AS12_date],
  [AS13] AS [AS13_date],
  [AS14] AS [AS14_date],
  [AS15] AS [AS15_date],
  [AS16] AS [AS16_date],
  [AS17] AS [AS17_date],
  [AS18] AS [AS18_date],
  [AS19] AS [AS19_date],
  [AS20] AS [AS20_date],
  [AS21] AS [AS21_date],
  [AS22] AS [AS22_date],
  [AS23] AS [AS23_date],
  [AS24] AS [AS24_date],
  ISDATE(CAST([AS1] AS VARCHAR(10))) AS [AS1],
  ISDATE(CAST([AS2] AS VARCHAR(10))) AS [AS2],
  ISDATE(CAST([AS3] AS VARCHAR(10))) AS [AS3],
  ISDATE(CAST([AS4] AS VARCHAR(10))) AS [AS4],
  ISDATE(CAST([AS5] AS VARCHAR(10))) AS [AS5],
  ISDATE(CAST([AS6] AS VARCHAR(10))) AS [AS6],
  ISDATE(CAST([AS7] AS VARCHAR(10))) AS [AS7],
  ISDATE(CAST([AS8] AS VARCHAR(10))) AS [AS8],
  ISDATE(CAST([AS9] AS VARCHAR(10))) AS [AS9],
  ISDATE(CAST([AS10] AS VARCHAR(10))) AS [AS10],
  ISDATE(CAST([AS11] AS VARCHAR(10))) AS [AS11],
  ISDATE(CAST([AS12] AS VARCHAR(10))) AS [AS12],
  ISDATE(CAST([AS13] AS VARCHAR(10))) AS [AS13],
  ISDATE(CAST([AS14] AS VARCHAR(10))) AS [AS14],
  ISDATE(CAST([AS15] AS VARCHAR(10))) AS [AS15],
  ISDATE(CAST([AS16] AS VARCHAR(10))) AS [AS16],
  ISDATE(CAST([AS17] AS VARCHAR(10))) AS [AS17],
  ISDATE(CAST([AS18] AS VARCHAR(10))) AS [AS18],
  ISDATE(CAST([AS19] AS VARCHAR(10))) AS [AS19],
  ISDATE(CAST([AS20] AS VARCHAR(10))) AS [AS20],
  ISDATE(CAST([AS21] AS VARCHAR(10))) AS [AS21],
  ISDATE(CAST([AS22] AS VARCHAR(10))) AS [AS22],
  ISDATE(CAST([AS23] AS VARCHAR(10))) AS [AS23],
  ISDATE(CAST([AS24] AS VARCHAR(10))) AS [AS24],
  ISDATE(CAST([SC] AS VARCHAR(10))) AS [SC],
  ISDATE(CAST([CCDM] AS VARCHAR(10))) AS [CCDM],
  ISDATE(CAST([PSC] AS VARCHAR(10))) AS [PSC],
  ISDATE(CAST([BBB] AS VARCHAR(10))) AS [BBB],
  ISDATE(CAST([BM] AS VARCHAR(10))) AS [BM],
  ISDATE(CAST([GP] AS VARCHAR(10))) AS [GP],
  ISDATE(CAST([HV] AS VARCHAR(10))) AS [HV],
  ISDATE(CAST([MC1] AS VARCHAR(10))) AS [MC1],
  ISDATE(CAST([MC2] AS VARCHAR(10))) AS [MC2],
  ISDATE(CAST([DP_4year] AS VARCHAR(10))) AS [DP_4year],
  ISDATE(CAST([DP_2year] AS VARCHAR(10))) AS [DP_2year],
  ISDATE(CAST([DP_CTE] AS VARCHAR(10))) AS [DP_CTE],
  ISDATE(CAST([DP_Military] AS VARCHAR(10))) AS [DP_Military],
  ISDATE(CAST([DP_Workforce] AS VARCHAR(10))) AS [DP_Workforce],
  ISDATE(CAST([DP_Unknown] AS VARCHAR(10))) AS [DP_Unknown],
  ISDATE(CAST([BGP_4year] AS VARCHAR(10))) AS [BGP_4year],
  ISDATE(CAST([BGP_2year] AS VARCHAR(10))) AS [BGP_2year],
  ISDATE(CAST([BGP_CTE] AS VARCHAR(10))) AS [BGP_CTE],
  ISDATE(CAST([BGP_Military] AS VARCHAR(10))) AS [BGP_Military],
  ISDATE(CAST([BGP_Workforce] AS VARCHAR(10))) AS [BGP_Workforce],
  ISDATE(CAST([BGP_Unknown] AS VARCHAR(10))) AS [BGP_Unknown],
  ISDATE(CAST([HD_P] AS VARCHAR(10))) AS [HD_P],
  ISDATE(CAST([HD_NR] AS VARCHAR(10))) AS [HD_NR],
  ISDATE(CAST([TD_P] AS VARCHAR(10))) AS [TD_P],
  ISDATE(CAST([TD_NR] AS VARCHAR(10))) AS [TD_NR]
FROM
  (
    SELECT
      sub.contact_id,
      sub.academic_year,
      sub.contact_subject + sub.contact_term AS contact_type,
      sub.contact_date
    FROM
      (
        SELECT
          contact_c AS contact_id,
          date_c AS contact_date,
          CASE
            WHEN subject_c LIKE 'SC[0-9]%' THEN 'SC'
            WHEN subject_c LIKE 'Advising Session%' THEN 'AS'
            WHEN subject_c = 'Summer AAS' THEN 'AS'
            WHEN subject_c LIKE 'Grad Plan%' THEN 'GP'
            WHEN subject_c LIKE 'Q%SM%' THEN 'SM' + SUBSTRING(subject_c, 7, 1)
            WHEN subject_c LIKE '%HV' THEN 'HV'
            WHEN subject_c LIKE 'DP%' THEN REPLACE(
              gabby.utilities.STRIP_CHARACTERS (subject_c, ':-'),
              ' ',
              '_'
            )
            WHEN subject_c LIKE 'BGP%' THEN REPLACE(
              gabby.utilities.STRIP_CHARACTERS (subject_c, ':-'),
              ' ',
              '_'
            )
            WHEN subject_c = 'Housing Deposit Paid' THEN 'HD_P'
            WHEN subject_c = 'Housing Deposit Not Required' THEN 'HD_NR'
            WHEN subject_c = 'Tuition Deposit Paid' THEN 'TD_P'
            WHEN subject_c = 'Tuition Deposit Not Required' THEN 'TD_NR'
            ELSE subject_c
          END AS contact_subject,
          CASE
            WHEN subject_c LIKE 'Q[0-9]%' THEN 'Q' + SUBSTRING(subject_c, 2, 1)
            ELSE ''
          END AS contact_term,
          gabby.utilities.DATE_TO_SY (date_c) AS academic_year
        FROM
          gabby.alumni.contact_note_c
        WHERE
          is_deleted = 0
        UNION ALL
        SELECT
          contact_c,
          benchmark_date_c AS contact_date,
          'BM' AS contact_subject,
          '' AS contact_term,
          gabby.utilities.DATE_TO_SY (benchmark_date_c) AS academic_year
        FROM
          gabby.alumni.college_persistence_c
        WHERE
          benchmark_status_c = 'Complete'
          AND benchmark_period_c <> 'Pre-College'
          AND is_deleted = 0
      ) AS sub
  ) AS sub PIVOT (
    MIN(contact_date) FOR contact_type IN (
      [AS1],
      [AS2],
      [AS3],
      [AS4],
      [AS5],
      [AS6],
      [AS7],
      [AS8],
      [AS9],
      [AS10],
      [AS11],
      [AS12],
      [AS13],
      [AS14],
      [AS15],
      [AS16],
      [AS17],
      [AS18],
      [AS19],
      [AS20],
      [AS21],
      [AS22],
      [AS23],
      [AS24],
      [SC],
      [CCDM],
      [HV],
      [PSC],
      [BBB],
      [BM],
      [GP],
      [MC1],
      [MC2],
      [DP_4year],
      [DP_2year],
      [DP_CTE],
      [DP_Military],
      [DP_Workforce],
      [DP_Unknown],
      [BGP_4year],
      [BGP_2year],
      [BGP_CTE],
      [BGP_Military],
      [BGP_Workforce],
      [BGP_Unknown],
      [HD_P],
      [HD_NR],
      [TD_P],
      [TD_NR]
    )
  ) AS p
