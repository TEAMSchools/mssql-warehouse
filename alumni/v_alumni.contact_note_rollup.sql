USE gabby
GO

--CREATE OR ALTER VIEW alumni.contact_note_rollup AS

SELECT contact_id
      ,academic_year

      ,ISDATE(CONVERT(VARCHAR(10),[SC])) AS [SC]
      ,ISDATE(CONVERT(VARCHAR(10),[CCDM])) AS [CCDM]

      ,ISDATE(CONVERT(VARCHAR(10),[AS1F])) AS [AS1F]
      ,[AS1F] AS [AS1F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS2F])) AS [AS2F]
      ,[AS2F] AS [AS2F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS3F])) AS [AS3F]
      ,[AS3F] AS [AS3F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS4F])) AS [AS4F]
      ,[AS4F] AS [AS4F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS5F])) AS [AS5F]
      ,[AS5F] AS [AS5F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS6F])) AS [AS6F]
      ,[AS6F] AS [AS6F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS7F])) AS [AS7F]
      ,[AS6F] AS [AS6F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS8F])) AS [AS8F]
      ,[AS6F] AS [AS6F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS9F])) AS [AS9F]
      ,[AS6F] AS [AS6F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS10F])) AS [AS10F]
      ,[AS6F] AS [AS6F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS11F])) AS [AS11F]
      ,[AS6F] AS [AS6F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS12F])) AS [AS12F]
      ,[AS6F] AS [AS6F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS13F])) AS [AS13F]
      ,[AS6F] AS [AS6F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS14F])) AS [AS14F]
      ,[AS6F] AS [AS6F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS15F])) AS [AS15F]
      ,[AS6F] AS [AS6F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS16F])) AS [AS16F]
      ,[AS6F] AS [AS6F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS17F])) AS [AS17F]
      ,[AS6F] AS [AS6F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS18F])) AS [AS18F]
      ,[AS6F] AS [AS6F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS19F])) AS [AS19F]
      ,[AS6F] AS [AS6F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS20F])) AS [AS20F]
      ,[AS6F] AS [AS6F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS21F])) AS [AS21F]
      ,[AS6F] AS [AS6F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS22F])) AS [AS22F]
      ,[AS6F] AS [AS6F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS23F])) AS [AS23F]
      ,[AS6F] AS [AS6F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS24F])) AS [AS24F]
      ,[AS6F] AS [AS6F_date]

      ,ISDATE(CONVERT(VARCHAR(10) ,[PSCF])) AS [PSCF]

      ,ISDATE(CONVERT(VARCHAR(10) ,[BBBF])) AS [BBBF]

      ,ISDATE(CONVERT(VARCHAR(10) ,[BMF])) AS [BMF]

      ,ISDATE(CONVERT(VARCHAR(10) ,[GPF])) AS [GPF]

      ,ISDATE(CONVERT(VARCHAR(10) ,[MC1])) AS [MC1]
      ,ISDATE(CONVERT(VARCHAR(10) ,[MC2])) AS [MC2]

      ,ISDATE(CONVERT(VARCHAR(10) ,[HV])) AS [HV]

      ,ISDATE(CONVERT(VARCHAR(10) ,[DP_4yearF])) AS [DP_4yearF]
      ,ISDATE(CONVERT(VARCHAR(10) ,[DP_2yearF])) AS [DP_2yearF]
      ,ISDATE(CONVERT(VARCHAR(10) ,[DP_CTEF])) AS [DP_CTEF]
      ,ISDATE(CONVERT(VARCHAR(10) ,[DP_MilitaryF])) AS [DP_MilitaryF]
      ,ISDATE(CONVERT(VARCHAR(10) ,[DP_WorkforceF])) AS [DP_WorkforceF]
      ,ISDATE(CONVERT(VARCHAR(10) ,[DP_UnknownF])) AS [DP_UnknownF]

      ,ISDATE(CONVERT(VARCHAR(10) ,[BGP_4yearF])) AS [BGP_4yearF]
      ,ISDATE(CONVERT(VARCHAR(10) ,[BGP_2yearF])) AS [BGP_2yearF]
      ,ISDATE(CONVERT(VARCHAR(10) ,[BGP_CTEF])) AS [BGP_CTEF]
      ,ISDATE(CONVERT(VARCHAR(10) ,[BGP_MilitaryF])) AS [BGP_MilitaryF]
      ,ISDATE(CONVERT(VARCHAR(10) ,[BGP_WorkforceF])) AS [BGP_WorkforceF]
      ,ISDATE(CONVERT(VARCHAR(10) ,[BGP_UnknownF])) AS [BGP_UnknownF]

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
           --,sub.contact_comments
           --,sub.contact_next_steps
     FROM
         (
          SELECT c.contact_c AS contact_id
                ,c.date_c AS contact_date
                --,c.comments_c AS contact_comments
                --,c.next_steps_c AS contact_next_steps
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
                  WHEN c.subject_c IN ('Summer AAS', 'CCDM') THEN ''
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
                ,CASE
                  WHEN MONTH(benchmark_date_c) >= 7 THEN 'F'
                  WHEN MONTH(benchmark_date_c) < 7 THEN 'S'
                 END AS contact_term
                ,gabby.utilities.DATE_TO_SY(benchmark_date_c) AS academic_year
          FROM gabby.alumni.college_persistence_c
          WHERE benchmark_status_c = 'Complete'
            AND benchmark_period_c <> 'Pre-College'
            AND is_deleted = 0
         ) sub
    ) sub
PIVOT(
  MIN(contact_date)
  FOR contact_type IN ([AS1F],[AS2F],[AS3F],[AS4F],[AS5F],[AS6F],[AS7F],[AS8F],[AS9F],[AS10F],[AS11F],[AS12F],
                       [AS13F],[AS14F],[AS15F],[AS16F],[AS17F],[AS18F],[AS19F],[AS20F],[AS21F],[AS22F],[AS23F],[AS24F]
                      ,[PSCF]
                      ,[BBBF]
                      ,[BMF]
                      ,[GPF]
                      ,[MC1],[MC2]
                      ,[SC],[CCDM],[HV]
                      ,[DP_4yearF],[DP_2yearF],[DP_CTEF],[DP_MilitaryF],[DP_WorkforceF],[DP_UnknownF]
                      ,[BGP_4yearF],[BGP_2yearF],[BGP_CTEF],[BGP_MilitaryF],[BGP_WorkforceF],[BGP_UnknownF]
                      ,[HD_P],[HD_NR],[TD_P],[TD_NR])
 ) p
