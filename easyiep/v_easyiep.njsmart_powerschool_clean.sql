CREATE OR ALTER VIEW easyiep.njsmart_powerschool_clean AS

SELECT [state_studentnumber]
      ,[student_number]
      ,special_education
      ,CONVERT(VARCHAR(2),[nj_se_delayreason]) AS nj_se_delayreason
      ,CONVERT(VARCHAR(2),[nj_se_placement]) AS nj_se_placement
      ,CONVERT(VARCHAR(1),[nj_se_parental_consentobtained]) AS nj_se_parental_consentobtained
      ,CONVERT(VARCHAR(1),[ti_serv_counseling]) AS ti_serv_counseling
      ,CONVERT(VARCHAR(1),[ti_serv_occup]) AS ti_serv_occup
      ,CONVERT(VARCHAR(1),[ti_serv_physical]) AS ti_serv_physical
      ,CONVERT(VARCHAR(1),[ti_serv_speech]) AS ti_serv_speech
      ,CONVERT(VARCHAR(1),[ti_serv_other]) AS ti_serv_other
      ,CONVERT(FLOAT,[nj_timeinregularprogram]) AS nj_timeinregularprogram
      ,CONVERT(DATE,[nj_se_referraldate]) AS nj_se_referraldate
      ,CONVERT(DATE,[nj_se_parentalconsentdate]) AS nj_se_parentalconsentdate
      ,CONVERT(DATE,[nj_se_eligibilityddate]) AS nj_se_eligibilityddate
      ,CONVERT(DATE,[nj_se_initialiepmeetingdate]) AS nj_se_initialiepmeetingdate
      ,CONVERT(DATE,[nj_se_consenttoimplementdate]) AS nj_se_consenttoimplementdate
      ,CONVERT(DATE,[nj_se_lastiepmeetingdate]) AS nj_se_lastiepmeetingdate
      ,CONVERT(DATE,[nj_se_reevaluationdate]) AS nj_se_reevaluationdate
      ,COALESCE(academic_year, gabby.utilities.GLOBAL_ACADEMIC_YEAR()) AS academic_year
      ,CASE
        WHEN special_education = '' THEN NULL
        WHEN special_education IS NULL THEN NULL
        WHEN nj_se_parental_consentobtained = 'R' THEN NULL
        WHEN special_education IN ('00','99') THEN NULL
        WHEN special_education = '17' THEN 'SPED SPEECH'
        ELSE 'SPED'
       END AS spedlep
      ,CASE 
        WHEN nj_se_parental_consentobtained = 'R' THEN NULL
        WHEN special_education = '01' THEN 'AI'
        WHEN special_education = '02' THEN 'AUT'
        WHEN special_education = '03' THEN 'CMI'
        WHEN special_education = '04' THEN 'CMO'
        WHEN special_education = '05' THEN 'CSE'
        WHEN special_education = '06' THEN 'CI'
        WHEN special_education = '07' THEN 'ED'
        WHEN special_education = '08' THEN 'MD'
        WHEN special_education = '09' THEN 'DB'
        WHEN special_education = '10' THEN 'OI'
        WHEN special_education = '11' THEN 'OHI'
        WHEN special_education = '12' THEN 'PSD'
        WHEN special_education = '13' THEN 'SM'
        WHEN special_education = '14' THEN 'SLD'
        WHEN special_education = '15' THEN 'TBI'
        WHEN special_education = '16' THEN 'VI'
        WHEN special_education = '17' THEN 'ESLS'
        WHEN special_education = '99' THEN '99'
        WHEN special_education = '00' THEN '00'
       END AS special_education_code
FROM
    (
     SELECT CONVERT(INT,TRY_PARSE(CONVERT(VARCHAR(25),e.[student_number]) AS INT)) AS [student_number]
           ,e.[state_studentnumber]
           ,e.[nj_se_referraldate]
           ,e.[nj_se_parentalconsentdate]
           ,e.[nj_se_eligibilityddate]
           ,e.[nj_se_initialiepmeetingdate]
           ,e.[nj_se_parental_consentobtained]
           ,e.[nj_se_consenttoimplementdate]
           ,e.[nj_se_lastiepmeetingdate]
           ,e.[nj_se_reevaluationdate]
           ,e.[nj_se_delayreason]
           ,e.[nj_se_placement]
           ,e.[nj_timeinregularprogram]
           ,e.[ti_serv_counseling]
           ,e.[ti_serv_occup]
           ,e.[ti_serv_physical]
           ,e.[ti_serv_speech]
           ,e.[ti_serv_other]
           ,e.academic_year
           ,RIGHT('0' + CONVERT(VARCHAR,e.[special_education]), 2) AS [special_education]
     FROM easyiep.njsmart_powerschool e
    ) sub
