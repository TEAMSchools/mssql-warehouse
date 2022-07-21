USE gabby
GO

CREATE OR ALTER VIEW alumni.contact_note_rollup AS

SELECT contact_id
      ,academic_year

      ,[AS1] AS [AS1_date]
      ,[AS2] AS [AS2_date]
      ,[AS3] AS [AS3_date]
      ,[AS4] AS [AS4_date]
      ,[AS5] AS [AS5_date]
      ,[AS6] AS [AS6_date]
      ,[AS7] AS [AS7_date]
      ,[AS8] AS [AS8_date]
      ,[AS9] AS [AS9_date]
      ,[AS10] AS [AS10_date]
      ,[AS11] AS [AS11_date]
      ,[AS12] AS [AS12_date]
      ,[AS13] AS [AS13_date]
      ,[AS14] AS [AS14_date]
      ,[AS15] AS [AS15_date]
      ,[AS16] AS [AS16_date]
      ,[AS17] AS [AS17_date]
      ,[AS18] AS [AS18_date]
      ,[AS19] AS [AS19_date]
      ,[AS20] AS [AS20_date]
      ,[AS21] AS [AS21_date]
      ,[AS22] AS [AS22_date]
      ,[AS23] AS [AS23_date]
      ,[AS24] AS [AS24_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS1])) AS [AS1]
      ,ISDATE(CONVERT(VARCHAR(10), [AS2])) AS [AS2]
      ,ISDATE(CONVERT(VARCHAR(10), [AS3])) AS [AS3]
      ,ISDATE(CONVERT(VARCHAR(10), [AS4])) AS [AS4]
      ,ISDATE(CONVERT(VARCHAR(10), [AS5])) AS [AS5]
      ,ISDATE(CONVERT(VARCHAR(10), [AS6])) AS [AS6]
      ,ISDATE(CONVERT(VARCHAR(10), [AS7])) AS [AS7]
      ,ISDATE(CONVERT(VARCHAR(10), [AS8])) AS [AS8]
      ,ISDATE(CONVERT(VARCHAR(10), [AS9])) AS [AS9]
      ,ISDATE(CONVERT(VARCHAR(10), [AS10])) AS [AS10]
      ,ISDATE(CONVERT(VARCHAR(10), [AS11])) AS [AS11]
      ,ISDATE(CONVERT(VARCHAR(10), [AS12])) AS [AS12]
      ,ISDATE(CONVERT(VARCHAR(10), [AS13])) AS [AS13]
      ,ISDATE(CONVERT(VARCHAR(10), [AS14])) AS [AS14]
      ,ISDATE(CONVERT(VARCHAR(10), [AS15])) AS [AS15]
      ,ISDATE(CONVERT(VARCHAR(10), [AS16])) AS [AS16]
      ,ISDATE(CONVERT(VARCHAR(10), [AS17])) AS [AS17]
      ,ISDATE(CONVERT(VARCHAR(10), [AS18])) AS [AS18]
      ,ISDATE(CONVERT(VARCHAR(10), [AS19])) AS [AS19]
      ,ISDATE(CONVERT(VARCHAR(10), [AS20])) AS [AS20]
      ,ISDATE(CONVERT(VARCHAR(10), [AS21])) AS [AS21]
      ,ISDATE(CONVERT(VARCHAR(10), [AS22])) AS [AS22]
      ,ISDATE(CONVERT(VARCHAR(10), [AS23])) AS [AS23]
      ,ISDATE(CONVERT(VARCHAR(10), [AS24])) AS [AS24]

      ,ISDATE(CONVERT(VARCHAR(10), [SC])) AS [SC]
      ,ISDATE(CONVERT(VARCHAR(10), [CCDM])) AS [CCDM]
      ,ISDATE(CONVERT(VARCHAR(10), [PSC])) AS [PSC]
      ,ISDATE(CONVERT(VARCHAR(10), [BBB])) AS [BBB]
      ,ISDATE(CONVERT(VARCHAR(10), [BM])) AS [BM]
      ,ISDATE(CONVERT(VARCHAR(10), [GP])) AS [GP]
      ,ISDATE(CONVERT(VARCHAR(10), [HV])) AS [HV]
      ,ISDATE(CONVERT(VARCHAR(10), [MC1])) AS [MC1]
      ,ISDATE(CONVERT(VARCHAR(10), [MC2])) AS [MC2]

      ,ISDATE(CONVERT(VARCHAR(10), [DP_4year])) AS [DP_4year]
      ,ISDATE(CONVERT(VARCHAR(10), [DP_2year])) AS [DP_2year]
      ,ISDATE(CONVERT(VARCHAR(10), [DP_CTE])) AS [DP_CTE]
      ,ISDATE(CONVERT(VARCHAR(10), [DP_Military])) AS [DP_Military]
      ,ISDATE(CONVERT(VARCHAR(10), [DP_Workforce])) AS [DP_Workforce]
      ,ISDATE(CONVERT(VARCHAR(10), [DP_Unknown])) AS [DP_Unknown]

      ,ISDATE(CONVERT(VARCHAR(10), [BGP_4year])) AS [BGP_4year]
      ,ISDATE(CONVERT(VARCHAR(10), [BGP_2year])) AS [BGP_2year]
      ,ISDATE(CONVERT(VARCHAR(10), [BGP_CTE])) AS [BGP_CTE]
      ,ISDATE(CONVERT(VARCHAR(10), [BGP_Military])) AS [BGP_Military]
      ,ISDATE(CONVERT(VARCHAR(10), [BGP_Workforce])) AS [BGP_Workforce]
      ,ISDATE(CONVERT(VARCHAR(10), [BGP_Unknown])) AS [BGP_Unknown]

      ,ISDATE(CONVERT(VARCHAR(10), [HD_P])) AS [HD_P]
      ,ISDATE(CONVERT(VARCHAR(10), [HD_NR])) AS [HD_NR]
      ,ISDATE(CONVERT(VARCHAR(10), [TD_P])) AS [TD_P]
      ,ISDATE(CONVERT(VARCHAR(10), [TD_NR])) AS [TD_NR]
FROM
    (
     SELECT sub.contact_id
           ,sub.academic_year
           ,sub.contact_subject + sub.contact_term AS contact_type
           ,sub.contact_date
     FROM
         (
          SELECT c.contact_c AS contact_id
                ,c.date_c AS contact_date
                ,CASE
                  WHEN c.subject_c LIKE 'SC[0-9]%' THEN 'SC'
                  WHEN c.subject_c LIKE 'Advising Session%' THEN 'AS'
                  WHEN c.subject_c = 'Summer AAS' THEN 'AS'
                  WHEN c.subject_c LIKE 'Grad Plan%' THEN 'GP'
                  WHEN c.subject_c LIKE 'Q%SM%' THEN 'SM' + SUBSTRING(c.subject_c, 7, 1)
                  WHEN c.subject_c LIKE '%HV' THEN 'HV'
                  WHEN c.subject_c LIKE 'DP%' THEN REPLACE(gabby.utilities.STRIP_CHARACTERS(c.subject_c, ':-'), ' ', '_')
                  WHEN c.subject_c LIKE 'BGP%' THEN REPLACE(gabby.utilities.STRIP_CHARACTERS(c.subject_c, ':-'), ' ', '_')
                  WHEN c.subject_c = 'Housing Deposit Paid' THEN 'HD_P'
                  WHEN c.subject_c = 'Housing Deposit Not Required' THEN 'HD_NR'
                  WHEN c.subject_c = 'Tuition Deposit Paid' THEN 'TD_P'
                  WHEN c.subject_c = 'Tuition Deposit Not Required' THEN 'TD_NR'
                  ELSE c.subject_c 
                 END AS contact_subject
                ,CASE
                  WHEN c.subject_c IN ('Summer AAS', 'CCDM', 'PSC', 'BBB') THEN ''
                  WHEN c.subject_c LIKE 'Grad Plan%' THEN ''
                  WHEN c.subject_c LIKE 'Advising Session%' THEN ''
                  WHEN c.subject_c LIKE 'MC%' THEN ''
                  WHEN c.subject_c LIKE '%HV' THEN ''
                  WHEN c.subject_c LIKE 'SC[0-9]%' THEN ''
                  WHEN c.subject_c LIKE 'Housing Deposit%' THEN ''
                  WHEN c.subject_c LIKE 'Tuition Deposit%' THEN ''
                  WHEN c.subject_c LIKE 'Q%' THEN 'Q' + SUBSTRING(c.subject_c, 2, 1)
                  /* catch-all for unspecified subjects */
                  WHEN MONTH(c.date_c) >= 7 THEN 'F'
                  WHEN MONTH(c.date_c) < 7 THEN 'S'
                 END AS contact_term
                ,gabby.utilities.DATE_TO_SY(c.date_c) AS academic_year
          FROM gabby.alumni.contact_note_c c
          WHERE c.is_deleted = 0

          UNION ALL

          SELECT contact_c
                ,benchmark_date_c AS contact_date
                ,'BM' AS contact_subject
                ,'' AS contact_term
                ,gabby.utilities.DATE_TO_SY(benchmark_date_c) AS academic_year
          FROM gabby.alumni.college_persistence_c
          WHERE benchmark_status_c = 'Complete'
            AND benchmark_period_c <> 'Pre-College'
            AND is_deleted = 0
         ) sub
    ) sub
PIVOT(
  MIN(contact_date)
  FOR contact_type IN ([AS1],[AS2],[AS3],[AS4],[AS5],[AS6],[AS7],[AS8],[AS9],[AS10],[AS11],[AS12],
                       [AS13],[AS14],[AS15],[AS16],[AS17],[AS18],[AS19],[AS20],[AS21],[AS22],[AS23],[AS24]
                      ,[SC],[CCDM],[HV],[PSC],[BBB],[BM],[GP],[MC1],[MC2]
                      ,[DP_4year],[DP_2year],[DP_CTE],[DP_Military],[DP_Workforce],[DP_Unknown]
                      ,[BGP_4year],[BGP_2year],[BGP_CTE],[BGP_Military],[BGP_Workforce],[BGP_Unknown]
                      ,[HD_P],[HD_NR],[TD_P],[TD_NR])
 ) p
