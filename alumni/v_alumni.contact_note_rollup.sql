USE gabby
GO

CREATE OR ALTER VIEW alumni.contact_note_rollup AS

SELECT contact_id
      ,academic_year

      ,ISDATE(CONVERT(VARCHAR(10),[SC])) AS [SC]
      ,ISDATE(CONVERT(VARCHAR(10),[CCDM])) AS [CCDM]

      ,ISDATE(CONVERT(VARCHAR(10),[AS1F])) AS [AS1F]
      ,[AS1F] AS [AS1F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS1S])) AS [AS1S]
      ,[AS1S] AS [AS1S_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS2F])) AS [AS2F]
      ,[AS2F] AS [AS2F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS2S])) AS [AS2S]
      ,[AS2S] AS [AS2S_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS3F])) AS [AS3F]
      ,[AS3F] AS [AS3F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS3S])) AS [AS3S]
      ,[AS3S] AS [AS3S_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS4F])) AS [AS4F]
      ,[AS4F] AS [AS4F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS4S])) AS [AS4S]
      ,[AS4S] AS [AS4S_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS5F])) AS [AS5F]
      ,[AS5F] AS [AS5F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS5S])) AS [AS5S]
      ,[AS5S] AS [AS5S_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS6F])) AS [AS6F]
      ,[AS6F] AS [AS6F_date]
      ,ISDATE(CONVERT(VARCHAR(10), [AS6S])) AS [AS6S]
      ,[AS6S] AS [AS6S_date]


      ,ISDATE(CONVERT(VARCHAR(10) ,[PSCF])) AS [PSCF]
      ,ISDATE(CONVERT(VARCHAR(10) ,[PSCS])) AS [PSCS]

      ,ISDATE(CONVERT(VARCHAR(10) ,[BBBF])) AS [BBBF]
      ,ISDATE(CONVERT(VARCHAR(10) ,[BBBS])) AS [BBBS]

      ,ISDATE(CONVERT(VARCHAR(10) ,[BMF])) AS [BMF]
      ,ISDATE(CONVERT(VARCHAR(10) ,[BMS])) AS [BMS]

      ,ISDATE(CONVERT(VARCHAR(10) ,[GPF])) AS [GPF]
      ,ISDATE(CONVERT(VARCHAR(10) ,[GPS])) AS [GPS]

      ,ISDATE(CONVERT(VARCHAR(10) ,[MC1])) AS [MC1]
      ,ISDATE(CONVERT(VARCHAR(10) ,[MC2])) AS [MC2]

      ,ISDATE(CONVERT(VARCHAR(10) ,[SM1Q1])) AS [SM1Q1]
      ,ISDATE(CONVERT(VARCHAR(10) ,[SM2Q1])) AS [SM2Q1]
      ,ISDATE(CONVERT(VARCHAR(10) ,[SM1Q2])) AS [SM1Q2]
      ,ISDATE(CONVERT(VARCHAR(10) ,[SM2Q2])) AS [SM2Q2]
      ,ISDATE(CONVERT(VARCHAR(10) ,[SM1Q3])) AS [SM1Q3]
      ,ISDATE(CONVERT(VARCHAR(10) ,[SM2Q3])) AS [SM2Q3]
      ,ISDATE(CONVERT(VARCHAR(10) ,[SM1Q4])) AS [SM1Q4]
      ,ISDATE(CONVERT(VARCHAR(10) ,[SM2Q4])) AS [SM2Q4]

      ,ISDATE(CONVERT(VARCHAR(10) ,[HV])) AS [HV]

      ,ISDATE(CONVERT(VARCHAR(10) ,[DP_4yearF])) AS [DP_4yearF]
      ,ISDATE(CONVERT(VARCHAR(10) ,[DP_2yearF])) AS [DP_2yearF]
      ,ISDATE(CONVERT(VARCHAR(10) ,[DP_CTEF])) AS [DP_CTEF]
      ,ISDATE(CONVERT(VARCHAR(10) ,[DP_MilitaryF])) AS [DP_MilitaryF]
      ,ISDATE(CONVERT(VARCHAR(10) ,[DP_WorkforceF])) AS [DP_WorkforceF]
      ,ISDATE(CONVERT(VARCHAR(10) ,[DP_UnknownF])) AS [DP_UnknownF]
      ,ISDATE(CONVERT(VARCHAR(10) ,[DP_4yearS])) AS [DP_4yearS]
      ,ISDATE(CONVERT(VARCHAR(10) ,[DP_2yearS])) AS [DP_2yearS]
      ,ISDATE(CONVERT(VARCHAR(10) ,[DP_CTES])) AS [DP_CTES]
      ,ISDATE(CONVERT(VARCHAR(10) ,[DP_MilitaryS])) AS [DP_MilitaryS]
      ,ISDATE(CONVERT(VARCHAR(10) ,[DP_WorkforceS])) AS [DP_WorkforceS]
      ,ISDATE(CONVERT(VARCHAR(10) ,[DP_UnknownS])) AS [DP_UnknownS]

FROM
    (
     SELECT sub.contact_id
           ,sub.academic_year
           ,sub.contact_subject + sub.contact_term AS contact_type
           ,sub.contact_date
     FROM
         (
          SELECT c.contact_c AS contact_id
                ,gabby.utilities.DATE_TO_SY(c.date_c) AS academic_year
                ,CASE
                  WHEN c.subject_c IN ('Summer AAS', 'CCDM') THEN ''
                  WHEN c.subject_c LIKE 'MC%' THEN ''
                  WHEN c.subject_c LIKE '%HV' THEN ''
                  WHEN c.subject_c LIKE 'SC[0-9]%' THEN ''
                  WHEN c.subject_c LIKE 'Q%' THEN 'Q' + SUBSTRING(c.subject_c, 2, 1)
                  WHEN MONTH(c.date_c) >= 7 THEN 'F'
                  WHEN MONTH(c.date_c) < 7 THEN 'S'
                 END AS contact_term
                ,CASE 
                  WHEN c.subject_c LIKE 'SC[0-9]%' THEN 'SC'
                  WHEN c.subject_c LIKE 'Advising Session%' THEN 'AS'
                  WHEN c.subject_c = 'Summer AAS' THEN 'AS'
                  WHEN c.subject_c LIKE 'Grad Plan%' THEN 'GP'
                  WHEN c.subject_c LIKE 'Q%SM%' THEN 'SM' + SUBSTRING(c.subject_c, 7, 1)
                  WHEN c.subject_c LIKE '%HV' THEN 'HV'
                  WHEN c.subject_c LIKE 'DP%' THEN REPLACE(gabby.utilities.STRIP_CHARACTERS(c.subject_c, ':-'), ' ', '_')
                  ELSE c.subject_c 
                 END AS contact_subject
                ,c.date_c AS contact_date
          FROM gabby.alumni.contact_note_c c
          WHERE c.is_deleted = 0

          UNION ALL

          SELECT contact_c
                ,gabby.utilities.DATE_TO_SY(benchmark_date_c) AS academic_year
                ,CASE
                  WHEN MONTH(benchmark_date_c) >= 7 THEN 'F'
                  WHEN MONTH(benchmark_date_c) < 7 THEN 'S'
                 END AS contact_term
                ,'BM' AS contact_subject
                ,benchmark_date_c AS contact_date
          FROM gabby.alumni.college_persistence_c
          WHERE benchmark_status_c = 'Complete'
            AND benchmark_period_c <> 'Pre-College'
            AND is_deleted = 0
         ) sub
    ) sub
PIVOT(
  MIN(contact_date)
  FOR contact_type IN ([AS1F]
                      ,[AS2F]
                      ,[AS1S]
                      ,[AS2S]
                      ,[AS3F]
                      ,[AS3S]
                      ,[AS4F]
                      ,[AS4S]
                      ,[AS5F]
                      ,[AS6F]
                      ,[AS5S]
                      ,[AS6S]
                      ,[PSCF]
                      ,[PSCS]
                      ,[BBBF]
                      ,[BBBS]
                      ,[BMF]
                      ,[BMS]
                      ,[GPF]
                      ,[GPS]
                      ,[MC1]
                      ,[MC2]
                      ,[SM1Q1]
                      ,[SM1Q2]
                      ,[SM1Q3]
                      ,[SM1Q4]
                      ,[SM2Q1]
                      ,[SM2Q2]
                      ,[SM2Q3]
                      ,[SM2Q4]
                      ,[SC]
                      ,[CCDM]
                      ,[HV]
                      ,[DP_4yearF]
                      ,[DP_2yearF]
                      ,[DP_CTEF]
                      ,[DP_MilitaryF]
                      ,[DP_WorkforceF]
                      ,[DP_UnknownF]
                      ,[DP_4yearS]
                      ,[DP_2yearS]
                      ,[DP_CTES]
                      ,[DP_MilitaryS]
                      ,[DP_WorkforceS]
                      ,[DP_UnknownS])
 ) p
