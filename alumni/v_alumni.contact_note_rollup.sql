USE gabby
GO

CREATE OR ALTER VIEW alumni.contact_note_rollup AS

SELECT contact_id
      ,academic_year

      ,[SC]
      ,[CCDM]

      ,[AASS]
      ,[AASF]
      ,[AAS1F]
      ,[AAS2F]
      ,[AAS3F]
      ,[AAS4F]
      ,[AAS5F]
      ,[AAS6F]
      ,[AAS1S]
      ,[AAS2S]
      ,[AAS3S]
      ,[AAS4S]
      ,[AAS5S]
      ,[AAS6S]

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
      ,[SM2Q1]
      ,[SM1Q2]
      ,[SM2Q2]
      ,[SM1Q3]
      ,[SM2Q3]
      ,[SM1Q4]
      ,[SM2Q4]

      ,[HV]
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
                  WHEN c.subject_c LIKE 'Advising Session%' THEN 'AAS'
                  WHEN c.subject_c = 'Summer AAS' THEN 'AASS'
                  WHEN c.subject_c LIKE 'Grad Plan%' THEN 'GP'
                  WHEN c.subject_c LIKE 'Q%SM%' THEN 'SM' + SUBSTRING(c.subject_c, 7, 1)
                  WHEN c.subject_c LIKE '%HV' THEN 'HV'
                  ELSE c.subject_c 
                 END AS contact_subject
                ,c.date_c AS contact_date
          FROM gabby.alumni.contact_note_c c
          WHERE (c.subject_c IN ('CCDM', 'PSC', 'BBB', 'Summer AAS', 'Pre-CTE Site Visit', 'Pre-CTE Benchmark')
                   OR c.subject_c LIKE 'SC[0-9]%'
                   OR c.subject_c LIKE 'Advising Session%'
                   OR c.subject_c LIKE 'Grad Plan%'
                   OR c.subject_c LIKE 'AAS%'
                   OR c.subject_c LIKE 'MC%'
                   OR c.subject_c LIKE 'Q%SM%'
                   OR c.subject_c LIKE 'Q%Check%In%'
                   OR c.subject_c LIKE '%HV'
                  )
            AND c.is_deleted = 0

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
  COUNT(contact_date)
  FOR contact_type IN ([AASS]
                      ,[AASF]
                      ,[AAS1F]
                      ,[AAS2F]
                      ,[AAS1S]
                      ,[AAS2S]
                      ,[AAS3F]
                      ,[AAS3S]
                      ,[AAS4F]
                      ,[AAS4S]
                      ,[AAS5F]
                      ,[AAS6F]
                      ,[AAS5S]
                      ,[AAS6S]
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
                      ,[HV])
 ) p
